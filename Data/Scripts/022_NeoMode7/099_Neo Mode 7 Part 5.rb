#============================================================================
# Neo Mode 7
# Written by MGCaladtogel
# 12/05/08
#
# Part 5
#
# class Tilemap_neoM7         : new class
#
#============================================================================

#============================================================================
# ■ Tilemap_neoM7
#----------------------------------------------------------------------------
# This new Tilemap class handles the drawing of a neo neoM7 map
#============================================================================

class Tilemap_neoM7
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor  :tilesets_list # contains tilesets graphics
  attr_reader :spriteset # spriteset that called this class
  attr_accessor  :sprite # sprite used to contain the map's drawing
  attr_accessor  :alpha # angle of slant
  attr_accessor  :theta # angle of rotation
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport  : viewport
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset)
    @even = true
    @viewport = viewport
    @spriteset = spriteset
    @id = $game_map.map_id # map's ID : used to load or save the map in Cache
    self.tilesets_list = [] # contains tilesets (Bitmap)
    @height = $game_map.height << 5 # @height : map's height (in pixel)
    @width = $game_map.width << 5 # @width : map's width (in pixel)
    @function_name = "BitmapMode7" # dll's function called to apply mode 7
    @function_name += "Loop" if $game_system.neoM7_loop
    @current_function_name = @function_name
    @zoom = $game_system.neoM7_zoom # zoom level of the map
    $game_temp.zoom_sprites = @zoom.to_f / 100
    $game_temp.zoom_map = (4096 * (1.0 / $game_temp.zoom_sprites)).to_i

    # tilesets graphics and data map are loaded if already in Cache
    if RPG::Cache_Datamap.in_cache(@id)
      @bitmap_data = RPG::Cache_Datamap.load(@id)
      @map_tileset = RPG::Cache_Tileset.load(@id)
      self.tilesets_list.push(@map_tileset)
      if $game_system.neoM7_animated
        @map_tileset_2 = RPG::Cache_Tileset.load(@id, 1)
        @map_tileset_3 = RPG::Cache_Tileset.load(@id, 2)
        @map_tileset_4 = RPG::Cache_Tileset.load(@id, 3)
        self.tilesets_list.push(@map_tileset_2)
        self.tilesets_list.push(@map_tileset_3)
        self.tilesets_list.push(@map_tileset_4)
      end
    else # draw the data map and the tileset and save them in the Cache
      draw_map
    end

    # create vertical elements from tiles
    data_V = Data_Vertical_Sprites.new(viewport)
    # @vertical_sprites : list of vertical sprites (Sprite_V)
    @vertical_sprites = data_V.list_sprites_V
    # @vertical_sprites_animated : list of animated vertical sprites (Sprite_V)
    @vertical_sprites_animated = data_V.list_sprites_V_animated
    
    # angle of rotation (theta)
    self.theta = $game_system.neoM7_theta
    theta_rad = (Math::PI * theta) / 180
    # easier to work with integer value than floats ('>>' and '<<' operations)
    $game_temp.cos_theta = (4096 * Math.cos(theta_rad)).to_i
    $game_temp.sin_theta = (4096 * Math.sin(theta_rad)).to_i
    
    # offsets : equivalent to display_x and display_y
    @offset_x = 0
    @offset_y = 0

    $game_temp.distance_h = 480 # distance between the center of the map (halfwidth, pivot) and the point of view
    # screenline's number of the slant's pivot = y-coordinate of the rotation center
    $game_temp.pivot = $game_system.neoM7_pivot # character sprites
    $game_temp.pivot_map = $game_temp.pivot /
    ($game_system.neoM7_resolution == 1 ? 1 :
    ($game_system.neoM7_resolution == 2 ? 1.33 : 2)) # map sprite
     # distance between the center of the map (halfwidth, pivot) and the projection plane surface
    $game_temp.distance_p = $game_temp.distance_h - $game_temp.distance_h /
    ($game_system.neoM7_resolution == 1 ? 1 :
    ($game_system.neoM7_resolution == 2 ? 1.334 :  2))
    # zoom value of the map sprite
    @coeff_resolution = ($game_system.neoM7_resolution == 1 ? 1 :
    ($game_system.neoM7_resolution == 2 ? 1.334 : 2))
    # x-offset for the 3 resolutions
    @offset_x_res = ($game_system.neoM7_resolution == 1 ? 0 :
    ($game_system.neoM7_resolution == 2 ? 80 : 160))
    # y-offset for the 3 resolutions
    @offset_y_res = $game_temp.pivot - $game_temp.pivot_map
    @index_animated = 0 # 0..3 : index of animated tiles pattern

    # map sprite
    self.sprite = Sprite.new(@viewport)
    self.sprite.x = 0
    self.sprite.y = 0
    self.sprite.z = - 99999 # map must not mask vertical elements
    if $game_system.neoM7_resolution != 1
      self.sprite.bitmap = ($game_system.neoM7_resolution == 2 ?
      Bitmap.new(480, 360) : Bitmap.new(320, 240))
    else
      self.sprite.bitmap = Bitmap.new(640, 480) # screen dimensions
    end

    # angle of slant (alpha)
    self.alpha = $game_system.neoM7_alpha
    refresh_alpha

  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    # dispose of map sprite and vertical sprites
    self.sprite.dispose
    for sprite in @vertical_sprites + @vertical_sprites_animated
      sprite.dispose
    end
    @vertical_sprites.clear
    @vertical_sprites_animated.clear
    @tilesets_list.clear
  end
  #--------------------------------------------------------------------------
  # * Refresh all the parameters dependent on the angle of slant
  #--------------------------------------------------------------------------
  def refresh_alpha
    # angle of slant
    alpha_rad = (Math::PI * alpha) / 180
    $game_temp.cos_alpha = (4096 * Math.cos(alpha_rad)).to_i
    $game_temp.sin_alpha = (4096 * Math.sin(alpha_rad)).to_i
    $game_system.neoM7_alpha = alpha
    $game_system.neoM7_pivot = $game_temp.pivot
    # h0,  z0 : intermediate values used to calculate the slope
    h0 = (- ($game_temp.distance_h) * $game_temp.pivot *
    $game_temp.cos_alpha) / ((($game_temp.distance_h) << 12) +
    $game_temp.pivot * $game_temp.sin_alpha) + $game_temp.pivot
    z0 = (($game_temp.distance_h) << 12).to_f /
    ((($game_temp.distance_h) << 12) + $game_temp.pivot * $game_temp.sin_alpha)
    # slope
    $game_temp.slope_value = (1.0 - z0) / ($game_temp.pivot - h0)
    $game_temp.slope_value_map = (262144 * $game_temp.slope_value).to_i
    $game_temp.corrective_value = 1.0 - $game_temp.pivot * $game_temp.slope_value
    $game_temp.corrective_value_map = (262144 * $game_temp.corrective_value / @coeff_resolution).to_i
    last_line = - $game_temp.pivot_map - $game_system.neoM7_horizon
    old_limit = $game_temp.neoM7_height_limit
    $game_temp.neoM7_height_limit = (($game_temp.distance_h - $game_temp.distance_p) *
    last_line * $game_temp.cos_alpha) / ((($game_temp.distance_h) << 12) -
    last_line * $game_temp.sin_alpha) + $game_temp.pivot_map
    if $game_system.neoM7_white_horizon
      @current_function_name = @function_name +
      ($game_temp.neoM7_height_limit > 0 ? "H" : "")
    end
    $game_temp.neoM7_height_limit = [$game_temp.neoM7_height_limit.to_i, 0].max
    $game_temp.height_limit_sprites = $game_temp.neoM7_height_limit * @coeff_resolution
    @even = ((old_limit - $game_temp.neoM7_height_limit) % 2 == 0 ? @even : !@even)
    # delete lines beyond the new horizon
    self.sprite.bitmap.clean_limit(old_limit,
    $game_temp.neoM7_height_limit) if old_limit < $game_temp.neoM7_height_limit
  end
  #--------------------------------------------------------------------------
  # * Increase (or decrease) the angle of slant
  #--------------------------------------------------------------------------
  def increase_alpha(value)
    self.alpha = [[alpha + value, 89].min, 0].max
    refresh_alpha
  end
  #--------------------------------------------------------------------------
  # * Increase (or decrease) the angle of rotation
  #--------------------------------------------------------------------------
  def increase_theta(value)
    self.theta += value
    self.theta %= 360
    theta_rad = (Math::PI * theta) / 180
    $game_temp.cos_theta = (4096 * Math.cos(theta_rad)).to_i
    $game_temp.sin_theta = (4096 * Math.sin(theta_rad)).to_i
    $game_system.neoM7_theta = theta
  end
  #--------------------------------------------------------------------------
  # * Increase (or decrease) the zoom level
  #--------------------------------------------------------------------------
  def increase_zoom(value)
    value = value.to_f / 100
    @zoom = [[@zoom * (2 ** value), 10000].min, 1].max
    $game_temp.zoom_sprites = @zoom.to_f / 100
    $game_temp.zoom_map = (4096 * (1.0 / $game_temp.zoom_sprites)).to_i
    $game_system.neoM7_zoom = @zoom
  end
  #--------------------------------------------------------------------------
  # * Increase the pivot's value
  #--------------------------------------------------------------------------
  def increase_pivot(value)
    res = [[$game_temp.pivot + value, 480].min, 32].max
    $game_map.display_y -= ((res - $game_temp.pivot) << 2)
    $game_system.neoM7_center_y += ((res - $game_temp.pivot) << 2)
    $game_temp.pivot = res
    $game_temp.pivot_map = $game_temp.pivot /
    ($game_system.neoM7_resolution == 1 ? 1 :
    ($game_system.neoM7_resolution == 2 ? 1.33 : 2))
    @offset_y_res = $game_temp.pivot - $game_temp.pivot_map
    refresh_alpha
  end
  #--------------------------------------------------------------------------
  # * Set the angle of slant
  #--------------------------------------------------------------------------
  def set_alpha(value)
    self.alpha = [[value, 89].min, 0].max
    refresh_alpha
  end
  #--------------------------------------------------------------------------
  # * Set the angle of rotation
  #--------------------------------------------------------------------------
  def set_theta(value)
    self.theta = value % 360
    theta_rad = (Math::PI * theta) / 180
    $game_temp.cos_theta = (4096 * Math.cos(theta_rad)).to_i
    $game_temp.sin_theta = (4096 * Math.sin(theta_rad)).to_i
    $game_system.neoM7_theta = theta
  end
  #--------------------------------------------------------------------------
  # * Set the zoom level
  #--------------------------------------------------------------------------
  def set_zoom(value)
    @zoom = [[value, 10000].min, 1].max
    $game_temp.zoom_sprites = @zoom.to_f / 100
    $game_temp.zoom_map = (4096 * (1.0 / $game_temp.zoom_sprites)).to_i
    $game_system.neoM7_zoom = @zoom
  end
  #--------------------------------------------------------------------------
  # * Set the pivot's value
  #--------------------------------------------------------------------------
  def set_pivot(value)
    res = [[value, 480].min, 32].max
    $game_map.display_y -= ((res - $game_temp.pivot) << 2)
    $game_system.neoM7_center_y += ((res - $game_temp.pivot) << 2)
    $game_temp.pivot = res
    $game_temp.pivot_map = $game_temp.pivot /
    ($game_system.neoM7_resolution == 1 ? 1 :
    ($game_system.neoM7_resolution == 2 ? 1.33 : 2))
    @offset_y_res = $game_temp.pivot - $game_temp.pivot_map
    refresh_alpha
  end
  #--------------------------------------------------------------------------
  # * Slide from the current alpha into the target value
  #--------------------------------------------------------------------------
  def to_alpha(value, speed)
    value = [[value, 89].min, 0].max
    while value > alpha
      increase_alpha([speed, value - alpha].min)
      spriteset.update
      Graphics.update
    end
    while value < alpha
      increase_alpha(-([speed, alpha - value].min))
      spriteset.update
      Graphics.update
    end
  end
  #--------------------------------------------------------------------------
  # * Slide from the current theta into the target value
  #--------------------------------------------------------------------------
  def to_theta(value, speed, direction)
    value %= 360
    while value != theta
      increase_theta(direction * ([(value - theta).abs, speed].min))
      spriteset.update
      Graphics.update
    end
  end
  #--------------------------------------------------------------------------
  # * Slide from the current zoom level into the target value
  #--------------------------------------------------------------------------
  def to_zoom(value, speed)
    value = [[value, 10000].min, 1].max
    while value > @zoom
      increase_zoom(speed)
      if value < @zoom
        set_zoom(value)
      end
      spriteset.update
      Graphics.update
    end
    while value < @zoom
      increase_zoom(-speed)
      if value > @zoom
        set_zoom(value)
      end
      spriteset.update
      Graphics.update
    end
  end
  #--------------------------------------------------------------------------
  # * Slide from the current pivot's value into the target value
  #--------------------------------------------------------------------------
  def to_pivot(value, speed)
    value = [[value, 480].min, 32].max
    while value > $game_temp.pivot
      increase_pivot([speed, value - $game_temp.pivot].min)
      spriteset.update
      Graphics.update
    end
    while value < $game_temp.pivot
      increase_pivot(-([speed, $game_temp.pivot - value].min))
      spriteset.update
      Graphics.update
    end
  end
  #--------------------------------------------------------------------------
  # * Update the map sprite and the vertical sprites
  #--------------------------------------------------------------------------
  def update
    # update map sprite
    @offset_x = $game_map.display_x / 4 + @offset_x_res
    @offset_y = $game_map.display_y / 4 + @offset_y_res
    current_function_name = @current_function_name
    if $game_system.neoM7_filter
      current_function_name += (@even ? "Even" : "Odd")
      @even = !@even
    end
    self.sprite.bitmap.neoM7(current_function_name, @map_tileset,
    @bitmap_data, @width, @height, @offset_x, @offset_y)
    self.sprite.zoom_x = @coeff_resolution
    self.sprite.zoom_y = @coeff_resolution
    # update vertical sprites
    for vertical_sprite in @vertical_sprites
      vertical_sprite.update
    end
  end
  #--------------------------------------------------------------------------
  # * Update animation for animated tiles
  #--------------------------------------------------------------------------
  def update_animated
    @index_animated += 1
    @index_animated %= 4
    @map_tileset = tilesets_list[@index_animated]
    # update vertical sprites
    for vertical_sprite in @vertical_sprites_animated
      vertical_sprite.update_animated(@index_animated)
    end
  end
  #--------------------------------------------------------------------------
  # * Create a data bitmap representing the map, and its associated tilesets
  #--------------------------------------------------------------------------
  def draw_map
    data = $game_map.data
    # Table where animated tiles are flagged
    data_animated = []
    # Bitmap that will be filled with the 3-layers map data
    @bitmap_data = Bitmap.new(@width / 32, @height / 32)
    color = Color.new(0,0,0) 
    rect = Rect.new(0, 0, 32, 32)
    
    # Create autotiles graphics
    RPG::Cache.clear
    @autotiles = []
    for i in 0..6
      autotile_name = $game_map.autotile_names[i]
      fichier = RPG::Cache.autotile(autotile_name)
      for l in 0..3
        data_autotile = Data_Autotiles.new(fichier,l)
        data_autotile.number = 4*i + l
        RPG::Cache.save_autotile(data_autotile, data_autotile.number)
        @autotiles.push(data_autotile)
      end
    end
    
    # Create a list of used terrain tiles (3 layers), and fill the data bitmap
    tiles_list = {}
    tiles_count = 0
    for i in 0...$game_map.height
      for j in 0...$game_map.width
        value1 = ($terrain_tags_vertical_tiles.include?(
        $game_map.terrain_tags[data[j, i, 0]]) ? 0 : data[j, i, 0])
        value2 = ($terrain_tags_vertical_tiles.include?(
        $game_map.terrain_tags[data[j, i, 1]]) ? 0 : data[j, i, 1])
        value3 = ($terrain_tags_vertical_tiles.include?(
        $game_map.terrain_tags[data[j, i, 2]]) ? 0 : data[j, i, 2])
        if !tiles_list.has_key?([value1, value2, value3])
          tiles_count += 1
          tiles_list[[value1, value2, value3]] = tiles_count
        end
        count = tiles_list[[value1, value2, value3]]
        color.set(count % 256, count / 256, 0) # up to 65536 different tiles for one map (should be sufficient)
        @bitmap_data.set_pixel(j, i, color)
      end
    end
    
    # Create a specific tileset (using the 3 layers) for the map
    tileset_height = (1 + (tiles_count / 8)) * 32
    @map_tileset = Bitmap.new(256, tileset_height)
    @tilesets_list.push(@map_tileset)
    for k in 1..tiles_count
      list_values = tiles_list.index(k)
      value1 = list_values[0]
      value2 = list_values[1]
      value3 = list_values[2]
      if value1 != 0
        if value2 == 0
          if value3 == 0
            if value1 > 383
              bitmap = RPG::Cache.tile($game_map.tileset_name, value1, 0)
            else
              num = 4*((value1 / 48) - 1)
              bitmap = RPG::Cache.autotile_base(num, value1)
              data_animated.push(k) if @autotiles[num].animated
            end
          else
            bitmap = RPG::Cache_Tile.load(value1, value3)
            animated = false
            if value1 < 384
              num = 4*((value1 / 48) - 1)
              animated = @autotiles[num].animated
            end
            if value3 < 384
              num = 4*((value3 / 48) - 1)
              animated = @autotiles[num].animated
            end
            data_animated.push(k) if animated
          end
        else
          if value3 == 0
            bitmap = RPG::Cache_Tile.load(value1, value2)
            animated = false
            if value1 < 384
              num = 4*((value1 / 48) - 1)
              animated = @autotiles[num].animated
            end
            if value2 < 384
              num = 4*((value2 / 48) - 1)
              animated = @autotiles[num].animated
            end
            data_animated.push(k) if animated
          else
            bitmap = RPG::Cache_Tile.load2(value1, value2, value3)
            animated = false
            if value1 < 384
              num = 4*((value1 / 48) - 1)
              animated = @autotiles[num].animated
            end
            if value2 < 384
              num = 4*((value2 / 48) - 1)
              animated = @autotiles[num].animated
            end
            if value3 < 384
              num = 4*((value3 / 48) - 1)
              animated = @autotiles[num].animated
            end
            data_animated.push(k) if animated
          end
        end
      else
        if value2 == 0
          if value3 != 0
            if value3 > 383
              bitmap = RPG::Cache.tile($game_map.tileset_name, value3, 0)
            else
              num = 4*((value3 / 48) - 1)
              bitmap = RPG::Cache.autotile_base(num, value3)
              data_animated.push(k) if @autotiles[num].animated
            end
          end
        else
          if value3 == 0
            if value2 > 383
              bitmap = RPG::Cache.tile($game_map.tileset_name, value2, 0)
            else
              num = 4*((value2 / 48) - 1)
              bitmap = RPG::Cache.autotile_base(num, value2)
              data_animated.push(k) if @autotiles[num].animated
            end
          else
            bitmap = RPG::Cache_Tile.load(value2, value3)
            animated = false
            if value2 < 384
              num = 4*((value2 / 48) - 1)
              animated = @autotiles[num].animated
            end
            if value3 < 384
              num = 4*((value3 / 48) - 1)
              animated = @autotiles[num].animated
            end
            data_animated.push(k) if animated
          end
        end
      end
      @map_tileset.blt(32 * ((k - 1) % 8), 32 * ((k - 1) / 8), bitmap, rect)
    end
    
    # save the data map and the tileset in the Cache
    RPG::Cache_Datamap.save(@id, @bitmap_data)
    RPG::Cache_Tileset.save(@id, @map_tileset)

    # create 3 other tilesets in case of animated tiles (4 patterns)
    if !$game_system.neoM7_animated
      tiles_list.clear
      return
    end
    @map_tileset_2 = @map_tileset.clone
    @map_tileset_3 = @map_tileset.clone
    @map_tileset_4 = @map_tileset.clone
    @tilesets_list.push(@map_tileset_2)
    @tilesets_list.push(@map_tileset_3)
    @tilesets_list.push(@map_tileset_4)
    for k in data_animated
      list_values = tiles_list.index(k)
      value1 = list_values[0]
      value2 = list_values[1]
      value3 = list_values[2]
      if value1 != 0
        if value2 == 0
          if value3 == 0
            num = 4*((value1 / 48) - 1)
            bitmap_2 = RPG::Cache.autotile_base(num+1, value1)
            bitmap_3 = RPG::Cache.autotile_base(num+2, value1)
            bitmap_4 = RPG::Cache.autotile_base(num+3, value1)
          else
            bitmap_2 = RPG::Cache_Tile.load(value1, value3, 1)
            bitmap_3 = RPG::Cache_Tile.load(value1, value3, 2)
            bitmap_4 = RPG::Cache_Tile.load(value1, value3, 3)
          end
        else
          if value3 == 0
            bitmap_2 = RPG::Cache_Tile.load(value1, value2, 1)
            bitmap_3 = RPG::Cache_Tile.load(value1, value2, 2)
            bitmap_4 = RPG::Cache_Tile.load(value1, value2, 3)
          else
            bitmap_2 = RPG::Cache_Tile.load2(value1, value2, value3, 1)
            bitmap_3 = RPG::Cache_Tile.load2(value1, value2, value3, 2)
            bitmap_4 = RPG::Cache_Tile.load2(value1, value2, value3, 3)
          end
        end
      else
        if value2 != 0
          if value3 == 0
            bitmap_2 = RPG::Cache.autotile_base(num+1, value2)
            bitmap_3 = RPG::Cache.autotile_base(num+2, value2)
            bitmap_4 = RPG::Cache.autotile_base(num+3, value2)
          else
            bitmap_2 = RPG::Cache_Tile.load(value2, value3, 1)
            bitmap_3 = RPG::Cache_Tile.load(value2, value3, 2)
            bitmap_4 = RPG::Cache_Tile.load(value2, value3, 3)
          end
        else
          if value3 != 0
            bitmap_2 = RPG::Cache.autotile_base(num+1, value3)
            bitmap_3 = RPG::Cache.autotile_base(num+2, value3)
            bitmap_4 = RPG::Cache.autotile_base(num+3, value3)
          end
        end
      end
      @map_tileset_2.blt(32 * ((k - 1) % 8), 32 * ((k - 1) / 8), bitmap_2, rect)
      @map_tileset_3.blt(32 * ((k - 1) % 8), 32 * ((k - 1) / 8), bitmap_3, rect)
      @map_tileset_4.blt(32 * ((k - 1) % 8), 32 * ((k - 1) / 8), bitmap_4, rect)
    end
    # save the three additional maps in the Cache
    RPG::Cache_Tileset.save(@id, @map_tileset_2, 1)
    RPG::Cache_Tileset.save(@id, @map_tileset_3, 2)
    RPG::Cache_Tileset.save(@id, @map_tileset_4, 3)
    tiles_list.clear
  end
  #--------------------------------------------------------------------------
  # * no tileset for neoM7 maps
  #--------------------------------------------------------------------------
  def tileset
    return nil
  end
end
