#============================================================================
# This script emulates the snes mode 7 feature.
# Written by MGCaladtogel
# Neo Mode 7 - 12/05/08
#----------------------------------------------------------------------------
# Instructions :
# You must add to the map's name :
#- [NM7] : to activate Neo Mode 7
#- [#XX] : XX is the angle of slant (in degree) : 0 -> 89
#- [%XXX]: XXX is the angle of rotation (in degree) : 0 -> 359
#- [L]   : to enable map looping
#- [A]   : animated autotiles (with 4 patterns)
#- [H]   : to have a white horizon
#- [RX]  : X = 1 -> high resolution (default)
#        : X = 2 -> medium resolution (to increase performance)
#        : X = 3 -> low resolution (to increase performance)
#- [F]   : activate the filer (to increase performance) : strongly recommanded
#
# OR :
# see the "$mode7_maps_settings" below (l.68) to prepare your settings
#----------------------------------------------------------------------------
# - To set a new angle of slant (0~89) :
# $scene.spriteset.tilemap.set_alpha(new angle)
# To slide progressively into a new angle of slant :
# $scene.spriteset.tilemap.to_alpha(new angle, speed)
# To increase/decrease the slant :
# $scene.spriteset.tilemap.increase_alpha(value)
# - To set a new angle of rotation (0~379) :
# $scene.spriteset.tilemap.set_theta(new angle)
# To slide progressively into a new angle of rotation :
# $scene.spriteset.tilemap.to_theta(angle, speed, dir)
# To increase/decrease the angle of rotation :
# $scene.spriteset.tilemap.increase_theta(value)
# - To set a new zoom level  :
# $scene.spriteset.tilemap.set_zoom(new value)
# To slide progressively into a new zoom level :
# $scene.spriteset.tilemap.to_zoom(value, speed)
# To increase/decrease the zoom level :
# $scene.spriteset.tilemap.increase_zoom(value)
# - The pivot's value (32~480) represents the screenline's number considered
# as the axis for map trasformations.
# By default its value is 256.
# To set a new value :
# $scene.spriteset.tilemap.set_pivot(new value)
# To slide progressively into a new pivot's value :
# $scene.spriteset.tilemap.to_pivot(value, speed)
# To increase/decrease the pivot's value :
# $scene.spriteset.tilemap.increase_pivot(value)
# - Pivot's value and zoom level are saved from
# one map to another. You have to reinitialize
# them manually if you need it.
# 
# - To set the altitude of a vertical event :
# add a comment in the event's commands list with : "Heigth X", where X is the
# height value ("Heigth 2" will draw the event 64 pixels above its original
# position - you can use floats)
# - To set the altitude of the player :
# use : $game_player.height = X
#============================================================================
# The map is drawn from all the tiles of the three layers that do not have a
# terrain_tag's value of 1 or 2.
# The other tiles (terrain_tag = 1 or 2) form elements that are drawn vertically,
# like the 3rd-layer elements in the old version.
# The 2 terrains ID used to form vertical elements
$terrain_tags_vertical_tiles = [1, 2] # You can modify these values
# To access maps names
$data_maps = load_data("Data/MapInfos.rxdata")
$neoM7_maps_settings = {}
# Prepare your own settings for mode7 maps
# Just put the first parameter in a map's name
# For example :
$neoM7_maps_settings["Worldmap"] = ["#60", "L", "A", "H", "F"]
# -> will  be called  when "Worldmap" is included in the name
$neoM7_maps_settings["Smallslant"] = ["#20", "A", "F"]
# Add any number of settings you want

# enable/disable mode7 for mode7 maps (not on the fly, just when the map is loaded), enabled by default
$enable_neoM7_number = 15 # switch number : change this value !

# - Number of directions for the player on mode 7 maps :
$player_directions = 8 # you can change this value !
# the character set used in that case must have the default name + "_m7"
# - To set the number of directions of a vertical event :
# add a comment in the event's commands list with : "Directions X"

# rows of character sets : the first represents the character that faces the screen,
# then the character rotates in the trigonometric direction
$dirs = {}
# 4 directions :
$dirs[4] = [0, 2, 3, 1]
# 8 directions :
$dirs[8] = [0, 6, 2, 7, 3, 5, 1, 4]
# you can change these values or add directions

#============================================================================
# Neo Mode 7
# Written by MGCaladtogel
# 12/05/08
#
# Part 1
#
# class Game_Switches
#   initialize                : aliased
#
# class Game_System
#   initialize                : aliased
#   neoM7_reset               : new method
#
# class Game_Temp
#   initialize                : aliased
#
#============================================================================

#============================================================================
# ■ Game_Switches
#============================================================================

class Game_Switches
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  if !@already_aliased
    alias initialize_neoM7_game_player initialize
    @already_aliased = true
  end
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    initialize_neoM7_game_player
    self[$enable_neoM7_number] = true
  end
end

#============================================================================
# ■ Game_System
#----------------------------------------------------------------------------
# Add attributes to this class
#============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  if !@already_aliased
    alias initialize_neoM7_game_system initialize
    @already_aliased = true
  end
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :neoM7 # true : neo mode 7
  attr_accessor :neoM7_loop # true : map looping in x and y
  attr_accessor :neoM7_animated # true : animated autotiles for neoM7 maps
  attr_accessor :neoM7_white_horizon # true : white line horizon for neoM7 maps
  attr_accessor :neoM7_alpha # angle of slant (in degree)
  attr_accessor :neoM7_theta # angle of rotation (in degree)
  attr_accessor :neoM7_horizon # horizon's distance
  attr_accessor :neoM7_resolution # 1:max, 2:med, 3:low
  attr_accessor :neoM7_filter # true : enable filter (increase perf., blurry when moving)
  attr_accessor :neoM7_pivot # screenline's number of the slant/rotation pivot
  attr_accessor :neoM7_zoom # zoom level (percentage, 100 = no zoom)
  attr_accessor :neoM7_center_y # center screen y-coordinate (depend on pivot)
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    initialize_neoM7_game_system
    self.neoM7 = false
    self.neoM7_loop = false
    self.neoM7_animated = false
    self.neoM7_white_horizon = false
    self.neoM7_alpha = 0
    self.neoM7_theta = 0
    self.neoM7_horizon = 960
    self.neoM7_resolution = 1
    self.neoM7_filter = false
    neoM7_reset
  end
  #--------------------------------------------------------------------------
  # * Reset zoom, pivot, and screen's center_y
  #--------------------------------------------------------------------------
  def neoM7_reset
    self.neoM7_pivot = 256
    self.neoM7_zoom = 100
    self.neoM7_center_y = Game_Player::CENTER_Y
  end
end

#============================================================================
# ■ Game_Temp
#----------------------------------------------------------------------------
# Add attributes to this class / Avoid using too many global variables
#============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  if !@already_aliased
    alias initialize_neoM7_game_temp initialize
    @already_aliased = true
  end
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :pivot # screenline's number of the pivot
  attr_accessor :pivot_map # same as pivot (depend of resolution)
  attr_accessor :neoM7_height_limit # horizon
  attr_accessor :height_limit_sprites # horizon for vertical sprites
  attr_accessor :distance_h # distance between the center of the map (halfwidth, pivot) and the point of view
  attr_accessor :slope_value # intermediate value used to calculate x-coordinate
  attr_accessor :slope_value_map # same as slope_value (depend of resolution) (* 262144)
  attr_accessor :corrective_value # intermediate value used to calculate x-coordinate
  attr_accessor :corrective_value_map # same as corrective_value (depend of resolution) (* 262144)
  attr_accessor :cos_alpha # cosinus of the angle of slant (* 4096)
  attr_accessor :sin_alpha # sinus of the angle of slant (* 4096)
  attr_accessor :cos_theta # cosinus of the angle of rotation (* 4096)
  attr_accessor :sin_theta # sinus of the angle of rotation (* 4096)
  attr_accessor :distance_p # distance between the center of the map (halfwidth, pivot) and the projection plane surface
  attr_accessor :zoom_map # zoom level (map) (percentage * 4096)
  attr_accessor :zoom_sprites # same as zoom_map (ratio)
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    initialize_neoM7_game_temp
    self.pivot = 0
    self.pivot_map = 0
    self.neoM7_height_limit = 0
    self.height_limit_sprites = 0
    self.distance_h = 0
    self.slope_value = 0.0
    self.slope_value = 0
    self.corrective_value = 0.0
    self.corrective_value_map = 0
    self.cos_alpha = 0
    self.sin_alpha = 0
    self.cos_theta = 0
    self.sin_theta = 0
    self.distance_p = 0
    self.zoom_map = 1
    self.zoom_sprites = 1.0
  end
end
