#============================================================================
# Neo Mode 7
# Written by MGCaladtogel
# 12/05/08
#
# Part 4
#
# class Scene_Map             : spriteset = attr_accessor
#
# class Bitmap
#   neoM7                     : new method
#   clean_limit               : new method
#
# class Data_Autotiles        : new class
#
# class Data_Vertical_Sprites : new class
#
# class RPG::Cache_Tile       : new class
#
# class RPG::Cache_Datamap    : new class
#
# class RPG::Cache_Tileset    : new class
#
# class RPG::Cache
#   self.autotile_base        : new method
#   self.save_autotile        : new method
#   self.load_autotile        : new method
#
# class RPG::MapInfo
#   name                      : redefined
#   name2                     : new method
#
#============================================================================

#============================================================================
# ■ Scene_Map
#============================================================================
class Scene_Map
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :spriteset # just need to access the spriteset
end

#============================================================================
# ■ Bitmap
#----------------------------------------------------------------------------
# Add neoM7 functions (dll calls)
#============================================================================

class Bitmap
  #--------------------------------------------------------------------------
  # mode 7 transformation
  #--------------------------------------------------------------------------
  def neoM7(function, tileset, data, map_width, map_height, off_x, off_y)
    raise RGSSError.new("Disposed bitmap") if disposed?
    func=Win32API.new("MGCmode7.dll", function, "llllllllllllllll", "")
    func.call(self.__id__, tileset.__id__, data.__id__, off_x, off_y,
    $game_temp.cos_alpha, $game_temp.sin_alpha, $game_temp.distance_h,
    $game_temp.pivot_map, $game_temp.slope_value_map,
    $game_temp.corrective_value_map, $game_temp.neoM7_height_limit,
    $game_temp.cos_theta, $game_temp.sin_theta, $game_temp.distance_p,
    $game_temp.zoom_map)
  end
  #--------------------------------------------------------------------------
  # delete pixels beyond the horizon
  #--------------------------------------------------------------------------
  def clean_limit(old_limit, new_limit)
    raise RGSSError.new("Disposed bitmap") if disposed?
    func=Win32API.new("MGCmode7.dll", "CleanHeightLimit", "lll", "")
    func.call(self.__id__, old_limit, new_limit)
  end
end

#============================================================================
# ■ Data_Autotiles
#----------------------------------------------------------------------------
# Creates the set of tiles from an autotile's file
#============================================================================

class Data_Autotiles < Bitmap
  # data list to form tiles from an atotiles file
  Data_creation = [[27,28,33,34],[5,28,33,34],[27,6,33,34],[5,6,33,34],
  [27,28,33,12],[5,28,33,12],[27,6,33,12],[5,6,33,12],[27,28,11,34],
  [5,28,11,34],[27,6,11,34],[5,6,11,34],[27,28,11,12],[5,28,11,12],
  [27,6,11,12],[5,6,11,12],[25,26,31,32],[25,6,31,32],[25,26,31,12],
  [25,6,31,12],[15,16,21,22],[15,16,21,12],[15,16,11,22],[15,16,11,12],
  [29,30,35,36],[29,30,11,36],[5,30,35,36],[5,30,11,36],[39,40,45,46],
  [5,40,45,46],[39,6,45,46],[5,6,45,46],[25,30,31,36],[15,16,45,46],
  [13,14,19,20],[13,14,19,12],[17,18,23,24],[17,18,11,24],[41,42,47,48],
  [5,42,47,48],[37,38,43,44],[37,6,43,44],[13,18,19,24],[13,14,43,44],
  [37,42,43,48],[17,18,47,48],[13,18,43,48],[13,18,43,48]]
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :number # autotile's number to identify it
  attr_accessor :animated # TRUE if the autotile is animated
  #--------------------------------------------------------------------------
  # * Initialize Object
  #     file   : autotiles file's bitmap (Bitmap)
  #     l      : 0..3 : pattern's number for animated autotiles
  #--------------------------------------------------------------------------
  def initialize(file, l)
    super(8*32, 6*32)
    create(file, l)
  end
  #--------------------------------------------------------------------------
  # * Create the tiles set
  #     file   : autotiles file's bitmap (Bitmap)
  #     l      : 0..3 : pattern's number for animated autotiles
  #--------------------------------------------------------------------------
  def create(file, l)
    l = (file.width > 96 ? l : 0)
    self.animated = (file.width > 96)
    for i in 0..5
      for j in 0..7
        data = Data_creation[8 * i + j]
        for number in data
          number -= 1
          m = 16 * (number % 6)
          n = 16 * (number / 6)
          blt(32 * j + m % 32, 32 * i + n % 32, file,
          Rect.new(m + 96 * l, n, 16, 16))
        end
      end
    end
  end
end

#============================================================================
# ■ Data_Vertical_Sprites
#----------------------------------------------------------------------------
# Create a list of vertical sprites for the three layers of a map
# "V" for "Vertical" in the script
# "num" for "number"
#============================================================================

class Data_Vertical_Sprites
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor  :list_sprites_V # list of vertical sprites
  attr_accessor  :list_sprites_V_animated # list of animated vertical sprites
  #--------------------------------------------------------------------------
  # * A little method to compare terrain_tags
  #     value  : tile's ID
  #     num    : reference terrain_tag's value
  #--------------------------------------------------------------------------
  def suitable?(value, num)
    return ($game_map.terrain_tags[value] == num)
  end
  #--------------------------------------------------------------------------
  # * This algorithm scans each layer and create a sprites formed by tiles
  #   in contact
  #     viewport : Viewport
  #--------------------------------------------------------------------------
  def initialize(viewport)
    @viewport = viewport
    # lists initialization
    self.list_sprites_V = []
    self.list_sprites_V_animated = []
    # @num_tiles : list of tiles coordinates that form a vertical sprite
    @num_tiles = []
    # create copy of map's data
    @dataV = ($game_map.data).clone
    # scan each layer
    for h in 0..2
      # scan each row
      for i in 0..$game_map.height
        # scan each column
        for j in 0..$game_map.width
          value = @dataV[j, i, h].to_i
          # if tile's terrain tag is declared to give vertical sprites
          if $terrain_tags_vertical_tiles.include?($game_map.terrain_tags[value])
            @reference_terrain_tag = $game_map.terrain_tags[value]
            @num_tiles.push([j, i])
            # the following algorithm is so complex that I really don't know how
            # it works exactly
            list_end = 0
            length = 0
            while j + length + 1 < $game_map.width and
              suitable?(@dataV[j +length+ 1, i, h].to_i, @reference_terrain_tag)
              @num_tiles.push([j + length+ 1,i])
              length += 1
            end
            list_start = j
            list_end = length + j
            indicator = true
            row = 0
            j2 = j
            while indicator
              row += 1
              break if (i + row) == $game_map.height
              list_start2 = j2
              length2 = 0
              indicator = false
              if length >= 2
                for k in (j2 + 1)..(j2 + length -1)
                  if suitable?(@dataV[k, i + row, h].to_i,
                    @reference_terrain_tag)
                    if !indicator
                      list_start2 = k
                    else
                      length2 = k - list_start2
                    end
                    indicator = true
                    @num_tiles.push([k, i + row])
                  elsif !indicator
                    length2 -= 1
                  end
                end
              end
              if suitable?(@dataV[j2 + length, i + row, h].to_i,
                @reference_terrain_tag)
                length2 = j2 + length - list_start2
                indicator = true
                @num_tiles.push([j2 + length, i + row])
                length3 = 1
                while j2 + length + length3 < $game_map.width and
                  suitable?(@dataV[j2 + length + length3, i + row, h].to_i,
                  @reference_terrain_tag)
                  @num_tiles.push([j2 + length + length3, i + row])
                  length3 += 1
                  length2 += 1
                  if j2 + length + length3 > list_end
                    list_end = j2 + length + length3
                  end
                end
              end
              if suitable?(@dataV[j2, i + row, h].to_i, @reference_terrain_tag)
                list_start3 = list_start2 - j2
                length2 = length2 + list_start3
                list_start2 = j2
                indicator = true
                @num_tiles.push([j2, i + row])
                length3 = 1
                while j2 - length3 >= 0 and
                  suitable?(@dataV[j2 - length3, i + row, h].to_i,
                  @reference_terrain_tag)
                  @num_tiles.push([j2 - length3, i + row])
                  length3 += 1
                  length2 += 1
                  list_start2 -= 1
                  if list_start2 < list_start
                    list_start = list_start2
                  end
                end
              end
              length = length2
              j2 = list_start2
            end
            row -= 1
            # create a bitmap and a sprite from the tiles listed in @num_tiles
            create_bitmap(i, list_start, row, list_end - list_start, h)
            # clear the used tiles
            clear_data(h)
            # reinitialize the list of tiles
            @num_tiles = []
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Clear the used data to prevent from reusing them
  #     layer  : current scanned layer
  #--------------------------------------------------------------------------
  def clear_data(layer)
    for num in @num_tiles
      @dataV[num[0], num[1], layer] = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Create a Bitmap from the listed tiles in @num_tiles and its associated
  #   sprite (Sprite_V)
  #     row     : start row's value
  #     column  : start column's value
  #     height  : sprite's height (in tiles)
  #     width   : sprite's width (in tiles)
  #     layer   : current scanned layer
  #--------------------------------------------------------------------------
  def create_bitmap(row, column, height, width, layer)
    bmp = Bitmap.new((1+width)<<5, (1+height)<<5)
    rect = Rect.new(0, 0, 32, 32)
    @num_tiles.sort! {|a, b|  -(a[1] - b[1])}
    sprite = Sprite_V.new(@viewport)
    # initialize sprite's attributes
    sprite.animated = false
    sprite.list_bitmap = []
    # draw the bitmap
    for tile_coordinates in @num_tiles
      value = @dataV[tile_coordinates[0], tile_coordinates[1], layer].to_i
      # if tile is a normal tile
      if value > 383
        bitmap = RPG::Cache.tile($game_map.tileset_name, value, 0)
      else # tile is an autotile
        file = (value / 48) - 1
        num_file = 4 * file
        if !sprite.animated
          autotile_name = $game_map.autotile_names[file]
          fichier = RPG::Cache.autotile(autotile_name)
          sprite.animated = (fichier.width > 96 ? true : false)
        end
        bitmap = RPG::Cache.autotile_base(num_file, value)
      end
      bmp.blt(32 * (tile_coordinates[0] - column),
      32 * (tile_coordinates[1] - row), bitmap, rect)
    end
    sprite.list_bitmap.push(bmp)
    # create 3 additionnal bitmaps for animated sprites
    if sprite.animated
      for j in 1..3
        bmp = Bitmap.new((1 + width)<<5, (1 + height)<<5)
        for tile_coordinates in @num_tiles
          value = @dataV[tile_coordinates[0], tile_coordinates[1], layer].to_i
          if value > 383
            bitmap = RPG::Cache.tile($game_map.tileset_name, value, 0)
          else
            num_file = 4 * ((value / 48) - 1)
            bitmap = RPG::Cache.autotile_base(num_file + j, value)
          end
          bmp.blt((tile_coordinates[0] - column)<<5,
          (tile_coordinates[1] - row)<<5, bitmap, rect)
        end
        sprite.list_bitmap.push(bmp)
      end
    end
    value = @dataV[@num_tiles[0][0], @num_tiles[0][1], layer].to_i
    # set sprite's priority
    sprite.priority = $game_map.priorities[value]
    # set sprite's coordinates (in squares (32 * 32 pixels))
    sprite.x_map = (column.to_f) + ((bmp.width)>>6)
    sprite.x_map += 0.5 if width % 2 == 0
    sprite.y_map = (row + height).to_f + 0.5
    sprite.square_y = sprite.y_map.to_i # Integer
    # set the y_pivot (intersection between the map and the sprite)
    sprite.oy = bmp.height - 16
    sprite.ox = bmp.width / 2
    sprite.height = bmp.height
    sprite.length = bmp.width
    sprite.bitmap = sprite.list_bitmap[0]
    self.list_sprites_V.push(sprite)
    self.list_sprites_V_animated.push(sprite) if sprite.animated
  end
end

#============================================================================
# ■ RPG::Cache_Tile
#----------------------------------------------------------------------------
# The tiles resulting in a superimposing of several tiles are kept in memory
# for a faster call
# valueX : tile's ID
#============================================================================

module RPG
  module Cache_Tile
    @cache = {}
    #------------------------------------------------------------------------
    # * Superimposing of two tiles, offset = pattern's number for animated
    # autotiles
    #------------------------------------------------------------------------
    def self.load(value1, value2, offset=0)
      if not @cache.include?([value1, value2, offset])
        bitmap = Bitmap.new(32, 32)
        rect = Rect.new(0, 0, 32, 32)
        if value1 > 383 # normal tile
          bitmap.blt(0, 0, RPG::Cache.tile($game_map.tileset_name, value1, 0),
          rect)
        else # autotile
          num = ((value1 / 48) - 1)<<2 + offset
          bitmap.blt(0, 0, RPG::Cache.autotile_base(num, value1), rect)
        end
        if value2 > 383 # normal tile
          bitmap.blt(0, 0, RPG::Cache.tile($game_map.tileset_name, value2, 0),
          rect)
        else # autotile
          num = ((value2 / 48) - 1)<<2 + offset
          bitmap.blt(0, 0, RPG::Cache.autotile_base(num, value2), rect)
        end
        @cache[[value1, value2, offset]] = bitmap
      end
      @cache[[value1, value2, offset]]
    end
    #------------------------------------------------------------------------
    # * Superimposing of three tiles
    #------------------------------------------------------------------------
    def self.load2(value1, value2, value3, offset = 0)
      if not @cache.include?([value1, value2, value3, offset])
        bitmap = Bitmap.new(32, 32)
        rect = Rect.new(0, 0, 32, 32)
        if value1 > 383 # normal tile
          bitmap.blt(0, 0, RPG::Cache.tile($game_map.tileset_name, value1, 0),
          rect)
        else # autotile
          num = ((value1 / 48) - 1)<<2 + offset
          bitmap.blt(0, 0, RPG::Cache.autotile_base(num, value1), rect)
        end
        if value2 > 383 # normal tile
          bitmap.blt(0, 0, RPG::Cache.tile($game_map.tileset_name, value2, 0),
          rect)
        else # autotile
          num = ((value2 / 48) - 1)<<2 + offset
          bitmap.blt(0, 0, RPG::Cache.autotile_base(num, value2), rect)
        end
        if value3 > 383 # normal tile
          bitmap.blt(0, 0, RPG::Cache.tile($game_map.tileset_name, value3, 0),
          rect)
        else # autotile
          num = ((value3 / 48) - 1)<<2 + offset
          bitmap.blt(0, 0, RPG::Cache.autotile_base(num, value3), rect)
        end
        @cache[[value1, value2, value3, offset]] = bitmap
      end
      @cache[[value1, value2, value3, offset]]
    end
    #------------------------------------------------------------------------
    # * Clear the Cache
    #------------------------------------------------------------------------
    def self.clear
      @cache = {}
      GC.start
    end
  end
end

#============================================================================
# ■ RPG::Cache_Datamap
#----------------------------------------------------------------------------
# Maps drawn with neoM7 are kept in memory to have a faster call the next
# times they need to be drawn
#============================================================================

module RPG
  module Cache_Datamap
    @cache = {}
    #------------------------------------------------------------------------
    # * Check if the map is in the Cache
    #   map_id : map's ID
    #------------------------------------------------------------------------
    def self.in_cache(map_id)
      return @cache.include?(map_id)
    end
    #------------------------------------------------------------------------
    # * Return the map's drawing (Bitmap)
    #   map_id : map's ID
    #   num    : pattern's number for animated autotiles
    #------------------------------------------------------------------------
    def self.load(map_id, num = 0)
      return @cache[map_id][num]
    end
    #------------------------------------------------------------------------
    # * Save the map's drawing in the Cache
    #   map_id : map's ID
    #   bitmap    : map's drawing (Bitmap)
    #   num    : pattern's number for animated autotiles
    #------------------------------------------------------------------------
    def self.save(map_id, bitmap, num = 0)
      @cache[map_id] = [] if !self.in_cache(map_id)
      @cache[map_id][num] = bitmap
    end
    #------------------------------------------------------------------------
    # * Clear the Cache
    #------------------------------------------------------------------------
    def self.clear
      @cache = {}
      GC.start
    end
  end
end

#============================================================================
# ■ RPG::Cache_Tileset
#----------------------------------------------------------------------------
# Maps drawn with neoM7 are kept in memory to have a faster call the next
# times they need to be drawn
#============================================================================

module RPG
  module Cache_Tileset
    @cache = {}
    #------------------------------------------------------------------------
    # * Check if the map is in the Cache
    #   map_id : map's ID
    #------------------------------------------------------------------------
    def self.in_cache(map_id)
      return @cache.include?(map_id)
    end
    #------------------------------------------------------------------------
    # * Return the map's drawing (Bitmap)
    #   map_id : map's ID
    #   num    : pattern's number for animated autotiles
    #------------------------------------------------------------------------
    def self.load(map_id, num = 0)
      return @cache[map_id][num]
    end
    #------------------------------------------------------------------------
    # * Save the map's drawing in the Cache
    #   map_id : map's ID
    #   bitmap    : map's drawing (Bitmap)
    #   num    : pattern's number for animated autotiles
    #------------------------------------------------------------------------
    def self.save(map_id, bitmap, num = 0)
      @cache[map_id] = [] if !self.in_cache(map_id)
      @cache[map_id][num] = bitmap
    end
    #------------------------------------------------------------------------
    # * Clear the Cache
    #------------------------------------------------------------------------
    def self.clear
      @cache = {}
      GC.start
    end
  end
end

#============================================================================
# ■ RPG::Cache
#----------------------------------------------------------------------------
# The tiles from autotiles files are kept in memory for a faster call
#============================================================================

module RPG
  module Cache
    #------------------------------------------------------------------------
    # * Check if the map is in the Cache
    #   num    : autotiles file's ID
    #   value    : tile's ID
    #------------------------------------------------------------------------
    def self.autotile_base(num, value)
      key = [num, value]
      if not @cache.include?(key) or @cache[key].disposed?
        @cache[key] = Bitmap.new(32, 32)
        num_tile = value % 48
        sx = 32 * (num_tile % 8)
        sy = 32 * (num_tile / 8)
        rect = Rect.new(sx, sy, 32, 32)
        @cache[key].blt(0, 0, self.load_autotile(num), rect)
      end
        @cache[key]
    end
    #------------------------------------------------------------------------
    # * Save the tile's drawing in the Cache
    #   bitmap : tile's drawing (Bitmap)
    #   key    : tile's ID
    #------------------------------------------------------------------------
    def self.save_autotile(bitmap, key)
      @cache[key] = bitmap
    end
    #------------------------------------------------------------------------
    # * Return the tile's drawing (Bitmap)
    #   key    : tile's ID
    #------------------------------------------------------------------------
    def self.load_autotile(key)
      @cache[key]
    end
  end
end

#============================================================================
# ■ RPG::MapInfo
#============================================================================

class RPG::MapInfo
  # defines the map's name as the name without anything within brackets,
  # including brackets
  def name
    return @name.gsub(/\[.*\]/) {""}
  end
  #--------------------------------------------------------------------------
  # the original name with the codes
  def name2
    return @name
  end
end
