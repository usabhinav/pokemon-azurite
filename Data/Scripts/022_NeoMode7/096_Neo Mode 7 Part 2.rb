#============================================================================
# Neo Mode 7
# Written by MGCaladtogel
# 12/05/08
#
# Part 2
#
# class Game_Map
#   scroll_down               : aliased
#   scroll_left               : aliased
#   scroll_right              : aliased
#   scroll_up                 : aliased
#   valid?                    : aliased
#   passable?                 : aliased
#   setup                     : aliased
#
# class Game_Character
#   initialize                : aliased
#   update                    : aliased
#
# class Game_Event
#   check_commands            : new method
#   refresh                   : aliased
#
# class Game_player
#   initialize                : aliased
#   center                    : aliased
#   update                    : aliased
#
#============================================================================

#============================================================================
# ■ Game_Map
#----------------------------------------------------------------------------
# Methods modifications to handle map looping
#============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  if !@already_aliased
    alias scroll_down_neoM7_game_map scroll_down
    alias scroll_left_neoM7_game_map scroll_left
    alias scroll_right_neoM7_game_map scroll_right
    alias scroll_up_neoM7_game_map scroll_up
    alias valid_neoM7_game_map? valid?
    alias passable_neoM7_game_map? passable?
    alias old_setup_neoM7 setup
    @already_aliased = true
  end
  #--------------------------------------------------------------------------
  # * Scroll Down
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    if !$game_system.neoM7
      scroll_down_neoM7_game_map(distance)
      return
    end
    @display_y = @display_y + distance
  end
  #--------------------------------------------------------------------------
  # * Scroll Left
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    if !$game_system.neoM7
      scroll_left_neoM7_game_map(distance)
      return
    end
    @display_x = @display_x - distance
  end
  #--------------------------------------------------------------------------
  # * Scroll Right
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    if !$game_system.neoM7
      scroll_right_neoM7_game_map(distance)
      return
    end
    @display_x = @display_x + distance
  end
  #--------------------------------------------------------------------------
  # * Scroll Up
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    if !$game_system.neoM7
      scroll_up_neoM7_game_map(distance)
      return
    end
    @display_y = @display_y - distance
  end
  #--------------------------------------------------------------------------
  # * Determine Valid Coordinates
  #     x          : x-coordinate
  #     y          : y-coordinate
  #   Allow the hero to go out of the map when map looping
  #--------------------------------------------------------------------------
  def valid?(x, y)
    if !$game_system.neoM7
      return (valid_neoM7_game_map?(x, y))
    end
    return true if $game_system.neoM7_loop
    return (x >= 0 and x < width and y >= 0 and y < height)
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     x          : x-coordinate
  #     y          : y-coordinate
  #     d          : direction (0,2,4,6,8,10)
  #                  *  0,10 = determine if all directions are impassable
  #     self_event : Self (If event is determined passable)
  #--------------------------------------------------------------------------
  def passable?(x, y, d, self_event = nil)
    if !$game_system.neoM7
      return(passable_neoM7_game_map?(x, y, d, self_event))
    end
    unless valid?(x, y)
      return false
    end
    bit = (1 << (d / 2 - 1)) & 0x0f
    for event in events.values
      if event.tile_id >= 0 and event != self_event and
         event.x == x and event.y == y and not event.through
        if @passages[event.tile_id] & bit != 0
          return false
        elsif @passages[event.tile_id] & 0x0f == 0x0f
          return false
        elsif @priorities[event.tile_id] == 0
          return true
        end
      end
    end
    for i in [2, 1, 0]
      tile_id = data[x % width, y % height, i] # handle map looping
      if tile_id == nil
        return false
      elsif @passages[tile_id] & bit != 0
        return false
      elsif @passages[tile_id] & 0x0f == 0x0f
        return false
      elsif @priorities[tile_id] == 0
        return true
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Setup
  #     map_id : map ID
  #--------------------------------------------------------------------------
  def setup(map_id)
    old_setup_neoM7(map_id)
    if !$game_switches[$enable_neoM7_number]
      $game_system.neoM7 = false
      $game_system.neoM7_loop = false
      $game_system.neoM7_animated = false
      $game_system.neoM7_white_horizon = false
      $game_system.neoM7_alpha = 0
      $game_system.neoM7_theta = 0
      $game_system.neoM7_horizon = 960
      $game_system.neoM7_resolution = 1
      $game_system.neoM7_filter = false
      return
    end
    map_data = $data_maps[$game_map.map_id]
    for keyword in $neoM7_maps_settings.keys
      if map_data.name2.include?(keyword)
        command_list = $neoM7_maps_settings[keyword]
        $game_system.neoM7 = map_data.name2.include?("[NM7]")
        $game_system.neoM7_loop = map_data.name2.include?("[L]")
        $game_system.neoM7_animated = map_data.name2.include?("[A]")
        $game_system.neoM7_white_horizon = map_data.name2.include?("[H]")
        $game_system.neoM7_filter = map_data.name2.include?("[F]")
        for command in command_list
          if command.include?("R")
            $game_system.neoM7_resolution = (command.slice(1, 1)).to_i
            $game_system.neoM7_resolution = [[$game_system.neoM7_resolution, 1].max, 3].min
          end
          if command.include?("#")
            $game_system.neoM7_alpha = (command.slice(1, 2)).to_i
            $game_system.neoM7_alpha = [[$game_system.neoM7_alpha, 0].max, 89].min
          end
          if command.include?("%")
            $game_system.neoM7_theta = (command.slice(1, 3)).to_i
            $game_system.neoM7_theta = [[$game_system.neoM7_theta, 0].max, 359].min
          end
        end
        return
      end
    end
    $game_system.neoM7 = map_data.name2.include?("[NM7]")
    $game_system.neoM7_loop = map_data.name2.include?("[L]")
    $game_system.neoM7_animated = map_data.name2.include?("[A]")
    $game_system.neoM7_white_horizon = map_data.name2.include?("[H]")
    $game_system.neoM7_filter = map_data.name2.include?("[F]")
    if $game_system.neoM7
      map_data.name2 =~ /\[R[ ]*([1-3]+)\]/i
      $game_system.neoM7_resolution = $1.to_i
      $game_system.neoM7_resolution = [[$game_system.neoM7_resolution, 1].max, 3].min
      map_data.name2 =~ /\[#[ ]*([00-99]+)\]/i
      $game_system.neoM7_alpha = $1.to_i
      $game_system.neoM7_alpha = [[$game_system.neoM7_alpha, 0].max, 89].min
      map_data.name2 =~ /\[%[ ]*([000-999]+)\]/i
      $game_system.neoM7_theta = $1.to_i
      $game_system.neoM7_theta = [[$game_system.neoM7_theta, 0].max, 359].min
    end
  end
end

#============================================================================
# ■ Game_Character
#----------------------------------------------------------------------------
# "update" method modifications to handle map looping
#============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  if !@already_aliased
    alias initialize_neoM7_game_character initialize
    alias update_neoM7_game_character update
    @already_aliased = true
  end
  #--------------------------------------------------------------------------
  # * Attributes
  #--------------------------------------------------------------------------
  attr_accessor :x
  attr_accessor :y
  attr_accessor :real_x
  attr_accessor :real_y
  attr_accessor :height # altitude
  attr_accessor :directions # number of directions
  attr_accessor :map_number_x # map's number with X-looping
  attr_accessor :map_number_y # map's number with Y-looping
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    initialize_neoM7_game_character
    self.height = 0.0
    self.map_number_x = 0
    self.map_number_y = 0
    self.directions = 4
  end
  #--------------------------------------------------------------------------
  # * Update : handle map looping
  #--------------------------------------------------------------------------
  def update
    if !$game_system.neoM7
      update_neoM7_game_character
      return
    end
    # if x-coordinate is out of the map
    if !(x.between?(0, $game_map.width - 1))
      difference = 128 * x - real_x
      if self.is_a?(Game_Player)
        # increase or decrease map's number
        self.map_number_x += difference / (difference.abs)
      end
      # x-coordinate is equal to its equivalent in the map
      self.x %= $game_map.width
      self.real_x = 128 * x - difference
    end
    # if y-coordinate is out of the map
    if !(y.between?(0, $game_map.height - 1))
      difference = 128 * y - real_y
      if self.is_a?(Game_Player)
        # increase or decrease map's number
        self.map_number_y += difference / (difference.abs)
      end
      # y-coordinate is equal to its equivalent in the map
      self.y %= $game_map.height
      self.real_y = 128 * y - difference
    end
    update_neoM7_game_character
  end
end

#==============================================================================
# ■ Game_Event
#----------------------------------------------------------------------------
# Add methods to handle altitude and directions number for vertical event
#============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  if !@already_aliased
    alias refresh_neoM7_game_character refresh
    @already_aliased = true
  end
  #--------------------------------------------------------------------------
  # * scan the event's commands list
  #     page : the scanned page (RPG::Event::Page)
  #--------------------------------------------------------------------------
  def check_commands(page)
    @height = 0.0
    command_list = page.list
    for k in 0..command_list.length - 2
      command = command_list[k]
      if (command.parameters[0].to_s).include?("Height")
        @height = (command.parameters[0][7,command.parameters[0].length-1]).to_f
      end
      if (command.parameters[0].to_s).include?("Directions")
        self.directions = (command.parameters[0][11,command.parameters[0].length-1]).to_i
      end
    end
  end
  #--------------------------------------------------------------------------
  # * scan the event's commands list of the current page when refreshed
  #--------------------------------------------------------------------------
  def refresh
    refresh_neoM7_game_character
    check_commands(@page) if @page != nil
  end
end

#============================================================================
# ■ Game_Player
#----------------------------------------------------------------------------
# Add attributes to have a well-working panorama's scrolling
#============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Aliased methods (F12 compatibility)
  #--------------------------------------------------------------------------
  if !@already_aliased
    alias initialize_neoM7_game_player initialize
    alias center_neoM7_game_player center
    alias update_neoM7_game_player update
    @already_aliased = true
  end
  #--------------------------------------------------------------------------
  # * Object Initialization : add "directions" attribute
  #--------------------------------------------------------------------------
  def initialize
    initialize_neoM7_game_player
    self.directions = $player_directions
  end
  #--------------------------------------------------------------------------
  # * Always center around the hero in mode 7
  #--------------------------------------------------------------------------
  def center(x, y)
    if !$game_system.neoM7
      center_neoM7_game_player(x, y)
      return
    end
    $game_map.display_x = x * 128 - CENTER_X
    $game_map.display_y = y * 128 - $game_system.neoM7_center_y
  end
  #--------------------------------------------------------------------------
  # * Frame Update : CENTER_Y replaced by $game_system.neoM7_center_y
  # to handle pivot's values different from 256
  #--------------------------------------------------------------------------
  def update
    if !$game_system.neoM7
      update_neoM7_game_player
      return
    end
    # Remember whether or not moving in local variables
    last_moving = moving?
    # If moving, event running, move route forcing, and message window
    # display are all not occurring
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      # Move player in the direction the directional button is being pressed
      case Input.dir4
      when 2
        move_down
      when 4
        move_left
      when 6
        move_right
      when 8
        move_up
      end
    end
    # Remember coordinates in local variables
    last_real_x = @real_x
    last_real_y = @real_y
    super
    # If character moves down and is positioned lower than the center
    # of the screen
    if @real_y > last_real_y and @real_y - $game_map.display_y > $game_system.neoM7_center_y
      # Scroll map down
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # If character moves left and is positioned more let on-screen than
    # center
    if @real_x < last_real_x and @real_x - $game_map.display_x < CENTER_X
      # Scroll map left
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # If character moves right and is positioned more right on-screen than
    # center
    if @real_x > last_real_x and @real_x - $game_map.display_x > CENTER_X
      # Scroll map right
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # If character moves up and is positioned higher than the center
    # of the screen
    if @real_y < last_real_y and @real_y - $game_map.display_y < $game_system.neoM7_center_y
      # Scroll map up
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # If not moving
    unless moving?
      # If player was moving last time
      if last_moving
        # Event determinant is via touch of same position event
        result = check_event_trigger_here([1,2])
        # If event which started does not exist
        if result == false
          # Disregard if debug mode is ON and ctrl key was pressed
          unless $DEBUG and Input.press?(Input::CTRL)
            # Encounter countdown
            if @encounter_count > 0
              @encounter_count -= 1
            end
          end
        end
      end
      # If C button was pressed
      if Input.trigger?(Input::C)
        # Same position and front event determinant
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
      end
    end
  end
end
