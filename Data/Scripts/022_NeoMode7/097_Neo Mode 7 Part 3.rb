#============================================================================
# Neo Mode 7
# Written by MGCaladtogel
# 12/05/08
#
# Part 3
#
# class Sprite
#   neoM7_x                   : new method
#   neoM7_y                   : new method
#   neoM7                     : new method
#   neoM7_zoom                : new method
#   on_screen_x               : new method
#   on_screen_y               : new method
#   neoM7_character_x         : new method
#   neoM7_character_y         : new method
#   neoM7_character           : new method
#
# class RPG::Sprite
#   animation_set_sprites     : redefined
#
# class Sprite_Character
#   update                    : aliased
#   refresh                   : aliased
#
# class Sprite_V              : new class
#
# class Spriteset_Map
#   initialize                : aliased
#   dispose                   : redefined
#   update                    : aliased
#
#============================================================================

#============================================================================
# ■ Sprite
#============================================================================

class Sprite
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :length # sprite's width
  attr_accessor :height # sprite's height
  #--------------------------------------------------------------------------
  # calculate x_coordinate in mode 7 for a vertical sprite
  #--------------------------------------------------------------------------
  def neoM7_x(x_map, y_map)
    x_map = 32 * x_map
    y_map = 32 * y_map
    y_init = $game_temp.zoom_sprites * (y_map - $game_temp.pivot - $game_map.display_y.to_i / 4)
    x_init = $game_temp.zoom_sprites * (x_map - 320 - $game_map.display_x.to_i / 4)
    y_intermediate = (((y_init * $game_temp.cos_theta -
    x_init * $game_temp.sin_theta).to_i) >> 12)
    x_intermediate = (((x_init * $game_temp.cos_theta +
    y_init * $game_temp.sin_theta).to_i) >> 12)
    y_int_2 = $game_temp.pivot + ($game_temp.distance_h * y_intermediate *
    $game_temp.cos_alpha) / ((($game_temp.distance_h) << 12) - y_intermediate *
    $game_temp.sin_alpha)
    return (320 + ($game_temp.slope_value * y_int_2 +
    $game_temp.corrective_value) * x_intermediate)
  end
  #--------------------------------------------------------------------------
  # calculate y_coordinate in mode 7 for a vertical sprite
  #--------------------------------------------------------------------------
  def neoM7_y(x_map, y_map)
    x_map = 32 * x_map
    y_map = 32 * y_map
    y_init = $game_temp.zoom_sprites * (y_map - $game_temp.pivot - $game_map.display_y.to_i / 4)
    x_init = $game_temp.zoom_sprites * (x_map - 320 - $game_map.display_x.to_i / 4)
    y_intermediate = (((y_init * $game_temp.cos_theta -
    x_init * $game_temp.sin_theta).to_i) >> 12)
    return ($game_temp.pivot + ($game_temp.distance_h * y_intermediate *
    $game_temp.cos_alpha) / ((($game_temp.distance_h) << 12) - y_intermediate *
    $game_temp.sin_alpha))
  end
  #--------------------------------------------------------------------------
  # calculate x and y coordinates in mode 7 for a vertical sprite
  #--------------------------------------------------------------------------
  def neoM7(x_map, y_map)
    x_map = 32 * x_map
    y_map = 32 * y_map
    y_init = $game_temp.zoom_sprites * (y_map - $game_temp.pivot - $game_map.display_y.to_i / 4)
    x_init = $game_temp.zoom_sprites * (x_map - 320 - $game_map.display_x.to_i / 4)
    y_intermediate = (((y_init * $game_temp.cos_theta -
    x_init * $game_temp.sin_theta).to_i) >> 12)
    x_intermediate = (((x_init * $game_temp.cos_theta +
    y_init * $game_temp.sin_theta).to_i) >> 12)
    self.y = $game_temp.pivot + ($game_temp.distance_h * y_intermediate *
    $game_temp.cos_alpha) / ((($game_temp.distance_h) << 12) - y_intermediate *
    $game_temp.sin_alpha)
    self.x = (320 + ($game_temp.slope_value * y +
    $game_temp.corrective_value) * x_intermediate)
  end
  #--------------------------------------------------------------------------
  # calculate the zoom level in mode 7 for a vertical sprite
  #--------------------------------------------------------------------------
  def neoM7_zoom(x_screen, y_screen)
    self.zoom_x = $game_temp.zoom_sprites * ($game_temp.slope_value * y +
    $game_temp.corrective_value)
    self.zoom_y = zoom_x
  end
  #--------------------------------------------------------------------------
  # check if value_x (in pixels) is on screen
  #--------------------------------------------------------------------------
  def on_screen_x(value_x)
    return (value_x.between?(- self.length / 2, 640 + self.length / 2))
  end
  #--------------------------------------------------------------------------
  # check if value_y (in pixels) is on screen
  #--------------------------------------------------------------------------
  def on_screen_y(value_y)
    return (value_y.between?($game_temp.height_limit_sprites, 480 + self.height))
  end
  #--------------------------------------------------------------------------
  # calculate x_coordinate in mode 7 for a character sprite
  #--------------------------------------------------------------------------
  def neoM7_character_x(x_screen, y_screen)
    y_init = $game_temp.zoom_sprites * (y_screen - $game_temp.pivot)
    x_init = $game_temp.zoom_sprites * (x_screen - 320)
    y_intermediate = (((y_init * $game_temp.cos_theta -
    x_init * $game_temp.sin_theta).to_i)>>12)
    x_intermediate = (((x_init * $game_temp.cos_theta +
    y_init * $game_temp.sin_theta).to_i)>>12)
    y_int_2 = $game_temp.pivot + ($game_temp.distance_h * y_intermediate *
    $game_temp.cos_alpha) / ((($game_temp.distance_h) << 12) - y_intermediate *
    $game_temp.sin_alpha)
    return (320 + ($game_temp.slope_value * y_int_2 +
    $game_temp.corrective_value) * x_intermediate)
  end
  #--------------------------------------------------------------------------
  # calculate y_coordinate in mode 7 for a character sprite
  #--------------------------------------------------------------------------
  def neoM7_character_y(x_screen, y_screen)
    y_init = $game_temp.zoom_sprites * (y_screen - $game_temp.pivot)
    x_init = $game_temp.zoom_sprites * (x_screen - 320)
    y_intermediate = (((y_init * $game_temp.cos_theta -
    x_init * $game_temp.sin_theta).to_i)>>12)
    return ($game_temp.pivot + ($game_temp.distance_h * y_intermediate *
    $game_temp.cos_alpha) / ((($game_temp.distance_h) << 12) - y_intermediate *
    $game_temp.sin_alpha))
  end
  #--------------------------------------------------------------------------
  # calculate x and y coordinates in mode 7 for a character sprite
  #--------------------------------------------------------------------------
  def neoM7_character(x_screen, y_screen)
    y_init = $game_temp.zoom_sprites * (y_screen - $game_temp.pivot)
    x_init = $game_temp.zoom_sprites * (x_screen - 320)
    y_intermediate = (((y_init * $game_temp.cos_theta -
    x_init * $game_temp.sin_theta).to_i)>>12)
    x_intermediate = (((x_init * $game_temp.cos_theta +
    y_init * $game_temp.sin_theta).to_i)>>12)
    self.y = $game_temp.pivot + ($game_temp.distance_h * y_intermediate *
    $game_temp.cos_alpha) / ((($game_temp.distance_h) << 12) - y_intermediate *
    $game_temp.sin_alpha)
    self.x = (320 + ($game_temp.slope_value * y +
    $game_temp.corrective_value) * x_intermediate)
  end
end

#============================================================================
# ■ RPG::Sprite
#============================================================================
module RPG
  class Sprite < ::Sprite
    #--------------------------------------------------------------------------
    # * Rewritten method : the sprite's zoom level is applied to its animations
    #--------------------------------------------------------------------------
    def animation_set_sprites(sprites, cell_data, position)
      for i in 0..15
        sprite = sprites[i]
        pattern = cell_data[i, 0]
        if sprite == nil or pattern == nil or pattern == -1
          sprite.visible = false if sprite != nil
          next
        end
        sprite.visible = true
        sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)
        if position == 3
          if self.viewport != nil
            sprite.x = self.viewport.rect.width / 2
            sprite.y = self.viewport.rect.height - 160
          else
            sprite.x = 320
            sprite.y = 240
          end
        else
          sprite.x = self.x - self.ox + self.src_rect.width / 2
          sprite.y = self.y - self.oy + self.src_rect.height / 2
          sprite.y -= self.src_rect.height / 4 if position == 0
          sprite.y += self.src_rect.height / 4 if position == 2
        end
        sprite.x += zoom_x * cell_data[i, 1]
        sprite.y += zoom_y * cell_data[i, 2]
        sprite.z = z
        sprite.ox = 96
        sprite.oy = 96
        sprite.zoom_x = zoom_x * cell_data[i, 3] / 100.0
        sprite.zoom_y = zoom_y * cell_data[i, 3] / 100.0
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
        sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
        sprite.blend_type = cell_data[i, 7]
      end
    end
  end
end

#============================================================================
# ■ Sprite_Character
#----------------------------------------------------------------------------
# Calculate x-coordinate and y-coordinate for a neoM7 map 
#============================================================================

class Sprite_Character < RPG::Sprite
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  if !@already_aliased
    alias update_neoM7_sprite_character update
    @already_aliased = true
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    if !$game_system.neoM7
      update_neoM7_sprite_character
      return
    end
    super
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_hue != @character.character_hue
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_hue = @character.character_hue
      if @tile_id >= 384
        self.bitmap = RPG::Cache.tile($game_map.tileset_name,
          @tile_id, @character.character_hue)
        self.src_rect.set(0, 0, 32, 32)
        self.ox = 16
        self.oy = 32
      else
        if @character.is_a?(Game_Player) and FileTest.exist?("Graphics/Characters/" +
          @character.character_name + "_m7.png")
          self.bitmap = RPG::Cache.character(@character.character_name + "_m7",
            @character.character_hue)
        else
          self.bitmap = RPG::Cache.character(@character.character_name,
            @character.character_hue)
        end
        @cw = bitmap.width / 4
        @ch = bitmap.height / @character.directions
        self.ox = @cw / 2
        self.oy = @ch
        # pivot correction (intersection between the map and this sprite)
        self.oy -= 4
      end
    end
    self.visible = (not @character.transparent)
    if @tile_id == 0
      sx = @character.pattern * @cw
      current_direction = (@character.direction - 2) / 2
      if $scene.spriteset != nil and $scene.spriteset.tilemap.is_a?(Tilemap_neoM7)
        directions_list = $dirs[@character.directions]
        list_size = directions_list.size
        current_direction = directions_list[(directions_list.index(current_direction) +
        (($scene.spriteset.tilemap.theta + (180 / list_size)) % 360) / (360 / list_size)) % list_size]
      end
      sy = current_direction * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
      self.length = @cw
      self.height = @ch
    else
      self.length = 32
      self.height = 32
    end
      
    x_intermediate = @character.screen_x
    y_intermediate = @character.screen_y - 4

    if $game_system.neoM7_loop
      diff_y = ($game_player.y - @character.y).to_i
      offset_y = ($game_map.height << 5) * (diff_y >= 0 ?
      (diff_y / ($game_map.height >> 1)) :
      (diff_y / ($game_map.height >> 1)) + 1)
      diff_x = ($game_player.x - @character.x).to_i
      offset_x = ($game_map.width << 5) * (diff_x >= 0 ?
      (diff_x / ($game_map.width >> 1)) :
      (diff_x / ($game_map.width >> 1)) + 1)
      neoM7_character(x_intermediate + offset_x, y_intermediate + offset_y)
    else
      neoM7_character(x_intermediate, y_intermediate)
    end
    if !on_screen_x(x) or !on_screen_y(y)
      self.opacity = 0
      return
    end
    neoM7_zoom(x, y)
    self.opacity = 255
    self.z = 4 * y
    self.y -= 32 * @character.height * zoom_y # height correction

    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end

#============================================================================
# ■ Sprite_V (Vertical Sprites)
#----------------------------------------------------------------------------
#  Sprites corresponding to the vertical elements formed by tiles
#============================================================================

class Sprite_V < Sprite
  attr_accessor :x_map # sprite's x_coordinates (in squares) (Float)
  attr_accessor :y_map # sprite's y_coordinates (in squares) (Float)
  attr_accessor :square_y # sprite's y_coordinates (in squares) (Integer)
  attr_accessor :priority # sprite's priority
  attr_accessor :animated # True if animated
  attr_accessor :list_bitmap # list of sprite's bitmaps (Bitmap)
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    if $game_system.neoM7_loop
      diff_y = ($game_player.y - y_map).to_i
      offset_y = $game_map.height * (diff_y >= 0 ?
      (diff_y / ($game_map.height >> 1)) :
      (diff_y / ($game_map.height >> 1)) + 1)
      diff_x = ($game_player.x - x_map).to_i
      offset_x = $game_map.width * (diff_x >= 0 ?
      (diff_x / ($game_map.width >> 1)) :
      (diff_x / ($game_map.width >> 1)) + 1)
      neoM7(x_map + offset_x, y_map + offset_y)
    else
      neoM7(x_map, y_map)
    end
    if !on_screen_x(x) or !on_screen_y(y)
      self.opacity = 0
      return
    end
    neoM7_zoom(x, y)
    self.opacity = 255
    self.z = 4 * y + 32 * priority
  end
  #--------------------------------------------------------------------------
  # * Update bitmap for animation
  #     index  : 0..3 : animation's index
  #--------------------------------------------------------------------------
  def update_animated(index)
    self.bitmap = @list_bitmap[index]
  end
end

#============================================================================
# ■ Spriteset_Map
#----------------------------------------------------------------------------
#  Modifications to call a neoM7 map
#============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  if !@already_aliased
    alias initialize_neoM7_spriteset_map initialize
    alias update_neoM7_spriteset_map update
    @already_aliased = true
  end
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :tilemap # just to be able to access the tilemap
  #--------------------------------------------------------------------------
  # * Initialize Object
  #   Rewritten to call a map with neoM7
  #--------------------------------------------------------------------------
  def initialize
    if !$game_system.neoM7
      initialize_neoM7_spriteset_map
      return
    end
    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 200
    @viewport3.z = 5000
    # neoM7 map
    @tilemap = Tilemap_neoM7.new(@viewport1, self)
    @panorama = Plane.new(@viewport1)
    # sprites drawn at the horizon's level have a negative z, and with a z value
    # of -100000 the panorama is still below
    @panorama.z = ($game_system.neoM7 ? -100000 : -1000)
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
    @character_sprites = []
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    @weather = RPG::Weather.new(@viewport1)
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_screen.pictures[i]))
    end
    @timer_sprite = Sprite_Timer.new
    update
    update if $game_system.neoM7_filter
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    if @tilemap.tileset != nil
      @tilemap.tileset.dispose
      for i in 0..6
        @tilemap.autotiles[i].dispose
      end
    end
    @tilemap.dispose
    @panorama.dispose
    @fog.dispose
    for sprite in @character_sprites
      sprite.dispose
    end
    @weather.dispose
    for sprite in @picture_sprites
      sprite.dispose
    end
    @timer_sprite.dispose
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    if !$game_system.neoM7
      update_neoM7_spriteset_map
      return
    end
    if @panorama_name != $game_map.panorama_name or
       @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      if @panorama_name != ""
        @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      if @fog.bitmap != nil
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      if @fog_name != ""
        @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end
    # update animated tiles each 20 frames
    if Graphics.frame_count % 20 == 0 and $game_system.neoM7_animated
      @tilemap.update_animated
    end
    @tilemap.update
    # to have a fluent panorama scrolling
    @panorama.ox = 6 * ((tilemap.theta * 4.0 / 3).to_i)
    @panorama.oy = - $game_temp.neoM7_height_limit
    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
    @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
    @fog.tone = $game_map.fog_tone
    for sprite in @character_sprites
      sprite.update
    end
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    for sprite in @picture_sprites
      sprite.update
    end
    @timer_sprite.update
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    @viewport3.color = $game_screen.flash_color
    @viewport1.update
    @viewport3.update
  end
end
