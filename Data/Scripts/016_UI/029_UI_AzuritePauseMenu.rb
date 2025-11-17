# Holds relevant constants
module AzuriteMenuSettings
  FOLDER_PATH = "Graphics/Pictures/Pause Menu/"
end

# Calls the option's "condition" proc if it exists, raises an error otherwise. This is to ensure that the "condition" proc
# only ever returns true or false, and never nil
def call_menu_handler_condition_proc(option)
  if MenuHandlers.call(:pause_menu, option, "condition").nil?
    raise "A condition proc MUST be defined, and the proc must NOT return nil (only true or false) for option #{option}!"
  end
  return MenuHandlers.call(:pause_menu, option, "condition")
end

# Sprite subclass for scrollable button sprite (NOT online, settings, or quit buttons)
class AzuriteMenu_MainButtonSprite < Sprite
  # Defines the x-range that these buttons are visible
  LEFT_CUT = 79
  RIGHT_CUT = 435

  attr_reader :text_row
  attr_reader :text_col

  def initialize(index, text_row, text_col, color_shift, viewport = nil, visible = true)
    super(viewport)
    # Button background bitmap
    @buttonSheetBitmap = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_Button_Def")
    @buttonSheetBitmap.hue_change(color_shift)
    # Text bitmap
    @iconSheetBitmap = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_ButtonText_Def")
    @iconSheetBitmap.hue_change(color_shift)
    # Defines which background to use.
    # 0 - selectable
    # 1 - selected
    # 2 - not selectable
    @index = index
    # Row/col to define which text to display from text bitmap
    @text_row = text_row
    @text_col = text_col
    self.visible = visible
    self.bitmap = Bitmap.new(200, 150)
    refresh
  end

  # Copies this button sprite, initially not visible so that it doesn't show up on the screen for a frame.
  # Used by temp wrapping buttons during left/right animation
  def copy_invisible(color_shift, viewport = nil)
    cloned = AzuriteMenu_MainButtonSprite.new(@index, @text_row, @text_col, color_shift, viewport, false)
    cloned.x = self.x
    cloned.y = self.y
    cloned.z = self.z
    cloned.zoom_x = self.zoom_x
    cloned.zoom_y = self.zoom_y
    return cloned
  end

  # Returns whether or not the player has access to the option represented by this button
  def available?
    case @text_row
    when 0
      case @text_col
      when 0
        # Party
        return call_menu_handler_condition_proc(:party)
      when 1
        # Pokedex
        return call_menu_handler_condition_proc(:pokedex)
      when 2
        # Suite
        return false
      when 3
        # Map
        return call_menu_handler_condition_proc(:town_map)
      end
    when 1
      case @text_col
      when 0
        # Bag
        return call_menu_handler_condition_proc(:bag)
      when 1
        # Mega evo.
        return false
      when 2
        # Guild
        return false
      when 3
        # Scout
        return false
      end
    when 2
      case @text_col
      when 0
        # Save
        return call_menu_handler_condition_proc(:save)
      when 1
        # Cr. record
        return false
      when 2
        # Train
        return false
      when 3
        # Radio
        return false
      end
    end
    # All cases should be covered in the above code
    raise _INTL("Button has invalid text_row or text_col! text_row = #{@text_row}, text_col = #{@text_col}")
  end

  def updateIndex
    # 0 means it can be selected, 2 means it cannot
    self.index = available? ? 0 : 2
  end

  def select
    # 1 means it is in the selected state
    self.index = 1
  end

  def index=(index)
    @index = index
    refresh
  end

  def setTextRowCol(text_row, text_col)
    @text_row = text_row
    @text_col = text_col
    refresh
  end

  # Returns the sprite's effective width
  def width
    return self.bitmap.width * self.zoom_x
  end

  # General function to crop either right or left of button if either applies
  def crop
    cropLeft
    cropRight
  end

  # Crops left side of button by filling it in with transparent pixels. Triggers for buttons on the leftmost side of the UI.
  def cropLeft
    return if self.x >= LEFT_CUT
    refresh
    self.bitmap.fill_rect(0, 0, (LEFT_CUT - self.x) / self.zoom_x, self.bitmap.height, Color.new(0, 0, 0, 0))
  end

  # Crops right side of button by filling it in with transparent pixels. Triggers for buttons on the rightmost side of the UI.
  def cropRight
    return if self.x + self.width <= RIGHT_CUT
    refresh
    cut_x = (RIGHT_CUT - self.x) / self.zoom_x
    self.bitmap.fill_rect(cut_x, 0, self.bitmap.width - cut_x, self.bitmap.height, Color.new(0, 0, 0, 0))
  end

  def refresh
    w = self.bitmap.width
    h = self.bitmap.height
    self.bitmap.clear
    # Apply button background
    self.bitmap.blt(0, 0, @buttonSheetBitmap, Rect.new(@index * w, 0, w, h))
    # Apply text
    self.bitmap.blt(0, 0, @iconSheetBitmap, Rect.new(@text_col * w, @text_row * h, w, h))
  end

  def dispose
    @buttonSheetBitmap.dispose
    @iconSheetBitmap.dispose
    super
  end
end

class AzuriteMenu_Scene
  # Defines number of visible scrollable buttons (NOT online, settings, or quit buttons)
  NUM_MAIN_BUTTON_COLS = 5
  NUM_MAIN_BUTTON_ROWS = 3

  # Defines width/height for button and text sprites
  MISC_BUTTON_WIDTH = 214
  MISC_BUTTON_HEIGHT = 68
  MISC_TEXT_WIDTH = 214
  MISC_TEXT_HEIGHT = 46

  # Currently selected column of text, in other words, text that is in the middle column
  attr_reader :selected_text_col
  # Currently selected row of text
  attr_reader :selected_row
  # Whether online mode is enabled or not
  attr_reader :is_online

  def pbStartScene
    @is_online = false
    @selected_text_col = 0
    @selected_row = 2
    @selected_online_col = 1
    
    @color_shift = 0 # Shifts the UI color by an amount between 0-360.

    # Main button background bitmap
    @buttonSheet = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_Button_Def")
    @buttonSheet.hue_change(@color_shift)
    # Online button background bitmap
    @buttonSheetSmall = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_Button_Online")
    @buttonSheetSmall.hue_change(@color_shift)
    # Main button text bitmap
    @iconSheet = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_ButtonText_Def")
    @iconSheet.hue_change(@color_shift)
    # Settings and Quit text bitmap
    @bottomTextSheet = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_ButtonText_Rest")
    # Online text bitmap
    @bottomTextSheet.hue_change(@color_shift)
    @onlineTextSheet = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_ButtonText_Online")
    @onlineTextSheet.hue_change(@color_shift)

    # Create sprites
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    # Background
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_Back")
    @sprites["bg"].bitmap.hue_change(@color_shift)
    @sprites["bg"].zoom_x = 0.5
    @sprites["bg"].zoom_y = 0.5

    # Right arrow
    @sprites["right_arrow"] = Sprite.new(@viewport)
    @sprites["right_arrow"].bitmap = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_Direction")
    @sprites["right_arrow"].bitmap.hue_change(@color_shift)
    @sprites["right_arrow"].zoom_x = 0.5
    @sprites["right_arrow"].zoom_y = 0.5
    @sprites["right_arrow"].x = 420
    @sprites["right_arrow"].y = Graphics.height/2 - 18 - @sprites["right_arrow"].bitmap.height/2 * @sprites["right_arrow"].zoom_y
    @sprites["right_arrow"].z = 1
    
    # Left arrow
    @sprites["left_arrow"] = Sprite.new(@viewport)
    @sprites["left_arrow"].bitmap = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_Direction")
    @sprites["left_arrow"].bitmap.hue_change(@color_shift)
    @sprites["left_arrow"].zoom_x = 0.5
    @sprites["left_arrow"].zoom_y = 0.5
    @sprites["left_arrow"].x = 23
    @sprites["left_arrow"].y = Graphics.height/2 - 18 - @sprites["left_arrow"].bitmap.height/2 * @sprites["left_arrow"].zoom_y
    @sprites["left_arrow"].z = 1
    @sprites["left_arrow"].mirror = true
    
    # Create main (scrollable) buttons
    for i in 0...NUM_MAIN_BUTTON_COLS
      for j in 0...NUM_MAIN_BUTTON_ROWS
        name = "button_#{i}#{j}"
        # Create button with text
        # Index, row, and col here don't matter because they are updated in update_main_buttons
        @sprites[name] = AzuriteMenu_MainButtonSprite.new(0, 0, 0, @color_shift, @viewport)
        @sprites[name].z = 1
      end
    end
    update_main_buttons

    # Create other buttons

    # Settings button with text
    @sprites["settings_frame"] = Sprite.new(@viewport)
    @sprites["settings_frame"].bitmap = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_onframe_Offline")
    @sprites["settings_frame"].bitmap.hue_change(@color_shift)
    @sprites["settings_frame"].zoom_x = 0.5
    @sprites["settings_frame"].zoom_y = 0.5
    @sprites["settings_frame"].x = Graphics.width/2 - @sprites["settings_frame"].bitmap.width*@sprites["settings_frame"].zoom_x/2
    @sprites["settings_frame"].y = 301
    @sprites["settings_frame"].z = 1
    
    @sprites["settings_button"] = Sprite.new(@viewport)
    @sprites["settings_button"].bitmap = Bitmap.new(MISC_BUTTON_WIDTH, MISC_BUTTON_HEIGHT)
    @sprites["settings_button"].bitmap.blt(0, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    @sprites["settings_button"].zoom_x = 0.5
    @sprites["settings_button"].zoom_y = 0.5
    @sprites["settings_button"].x = Graphics.width/2 - @sprites["settings_button"].bitmap.width*@sprites["settings_button"].zoom_x/2
    @sprites["settings_button"].y = 298
    @sprites["settings_button"].z = 2
    
    @sprites["settings_text"] = Sprite.new(@viewport)
    @sprites["settings_text"].bitmap = Bitmap.new(MISC_TEXT_WIDTH, MISC_TEXT_HEIGHT)
    @sprites["settings_text"].bitmap.blt(0, 0, @bottomTextSheet, @bottomTextSheet.rect)
    @sprites["settings_text"].zoom_x = 0.5
    @sprites["settings_text"].zoom_y = 0.5
    @sprites["settings_text"].x = @sprites["settings_button"].x
    @sprites["settings_text"].y = @sprites["settings_button"].y
    @sprites["settings_text"].z = 3
    
    # Quit button with text
    @sprites["quit_frame"] = Sprite.new(@viewport)
    @sprites["quit_frame"].bitmap = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + "pausemenu_onframe_Offline")
    @sprites["quit_frame"].bitmap.hue_change(@color_shift)
    @sprites["quit_frame"].zoom_x = 0.5
    @sprites["quit_frame"].zoom_y = 0.5
    @sprites["quit_frame"].x = Graphics.width/2 - @sprites["quit_frame"].bitmap.width*@sprites["quit_frame"].zoom_x/2
    @sprites["quit_frame"].y = 342
    @sprites["quit_frame"].z = 1
    
    @sprites["quit_button"] = Sprite.new(@viewport)
    @sprites["quit_button"].bitmap = Bitmap.new(MISC_BUTTON_WIDTH, MISC_BUTTON_HEIGHT)
    @sprites["quit_button"].bitmap.blt(0, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    @sprites["quit_button"].zoom_x = 0.5
    @sprites["quit_button"].zoom_y = 0.5
    @sprites["quit_button"].x = Graphics.width/2 - @sprites["quit_button"].bitmap.width*@sprites["quit_button"].zoom_x/2
    @sprites["quit_button"].y = @sprites["quit_frame"].y - 4
    @sprites["quit_button"].z = 2
    
    @sprites["quit_text"] = Sprite.new(@viewport)
    @sprites["quit_text"].bitmap = Bitmap.new(MISC_TEXT_WIDTH, MISC_TEXT_HEIGHT)
    @sprites["quit_text"].bitmap.blt(-MISC_TEXT_WIDTH, 0, @bottomTextSheet, @bottomTextSheet.rect)
    @sprites["quit_text"].zoom_x = 0.5
    @sprites["quit_text"].zoom_y = 0.5
    @sprites["quit_text"].x = @sprites["quit_button"].x
    @sprites["quit_text"].y = @sprites["quit_button"].y
    @sprites["quit_text"].z = 3
    
    # Online buttons with text
    @sprites["online_frame"] = Sprite.new(@viewport)
    @sprites["online_mid_button"] = Sprite.new(@viewport)
    @sprites["online_mid_button"].bitmap = Bitmap.new(MISC_BUTTON_WIDTH, MISC_BUTTON_HEIGHT)
    @sprites["online_mid_button"].bitmap.blt(0, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    @sprites["online_mid_button"].zoom_x = 0.5
    @sprites["online_mid_button"].zoom_y = 0.5
    @sprites["online_mid_button"].x = Graphics.width/2 - @sprites["online_mid_button"].bitmap.width*@sprites["online_mid_button"].zoom_x/2
    @sprites["online_mid_button"].z = 2
    @sprites["online_mid_text"] = Sprite.new(@viewport)
    update_online_frame_and_text
    
    @sprites["online_left_button"] = Sprite.new(@viewport)
    @sprites["online_left_button"].bitmap = Bitmap.new(MISC_BUTTON_WIDTH, MISC_BUTTON_HEIGHT)
    @sprites["online_left_button"].bitmap.blt(0, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    @sprites["online_left_button"].zoom_x = 0.5
    @sprites["online_left_button"].zoom_y = 0.5
    @sprites["online_left_button"].x = Graphics.width/2 - @sprites["online_left_button"].bitmap.width*@sprites["online_left_button"].zoom_x/2 - 103
    @sprites["online_left_button"].y = @sprites["online_frame"].y - 4
    @sprites["online_left_button"].visible = false
    @sprites["online_left_button"].z = 2

    @sprites["online_left_text"] = Sprite.new(@viewport)
    @sprites["online_left_text"].bitmap = Bitmap.new(MISC_TEXT_WIDTH, MISC_TEXT_HEIGHT)
    @sprites["online_left_text"].bitmap.blt(0, -MISC_TEXT_HEIGHT, @onlineTextSheet, @onlineTextSheet.rect)
    @sprites["online_left_text"].zoom_x = 0.5
    @sprites["online_left_text"].zoom_y = 0.5
    @sprites["online_left_text"].x = @sprites["online_left_button"].x
    @sprites["online_left_text"].y = @sprites["online_frame"].y + 2
    @sprites["online_left_text"].visible = false
    @sprites["online_left_text"].z = 3
    
    @sprites["online_right_button"] = Sprite.new(@viewport)
    @sprites["online_right_button"].bitmap = Bitmap.new(MISC_BUTTON_WIDTH, MISC_BUTTON_HEIGHT)
    @sprites["online_right_button"].bitmap.blt(0, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    @sprites["online_right_button"].zoom_x = 0.5
    @sprites["online_right_button"].zoom_y = 0.5
    @sprites["online_right_button"].x = Graphics.width/2 - @sprites["online_right_button"].bitmap.width*@sprites["online_right_button"].zoom_x/2 + 103
    @sprites["online_right_button"].y = @sprites["online_frame"].y - 4
    @sprites["online_right_button"].visible = false
    @sprites["online_right_button"].z = 2
    
    @sprites["online_right_text"] = Sprite.new(@viewport)
    @sprites["online_right_text"].bitmap = Bitmap.new(MISC_TEXT_WIDTH, MISC_TEXT_HEIGHT)
    @sprites["online_right_text"].bitmap.blt(-2 * MISC_TEXT_WIDTH, -MISC_TEXT_HEIGHT, @onlineTextSheet, @onlineTextSheet.rect)
    @sprites["online_right_text"].zoom_x = 0.5
    @sprites["online_right_text"].zoom_y = 0.5
    @sprites["online_right_text"].x = @sprites["online_right_button"].x
    @sprites["online_right_text"].y = @sprites["online_frame"].y + 2
    @sprites["online_right_text"].visible = false
    @sprites["online_right_text"].z = 3

    update_sel
  end

  # Retained for compatiblity with menu handlers
  def pbHideMenu

  end

  # Retained for compatiblity with menu handlers
  def pbShowMenu

  end
  
  # Retained for compatiblity with menu handlers, updates each button being selectable or not
  def pbRefresh
    update_main_buttons
    update_sel
  end
  
  # Disposes all sprites
  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  # If current selected row in middle column is not selectable, chooses next best option, or nil if entire column is unselectable
  def get_selectable_row_for_middle_col
    # If current selected row is selectable, just return itself
    if @sprites["button_2#{@selected_row - 1}"].available?
      return @selected_row
    end
    # Choose next best option if any other buttons in column are selectable
    # Top row
    if @selected_row == 1
      return 2 if @sprites["button_21"].available? # Middle
      return 3 if @sprites["button_22"].available? # Bottom
    # Middle row
    elsif @selected_row == 2
      return 1 if @sprites["button_20"].available? # Top
      return 3 if @sprites["button_22"].available? # Bottom
    # Bottom row
    elsif @selected_row == 3
      return 2 if @sprites["button_21"].available? # Middle
      return 1 if @sprites["button_20"].available? # Top
    end
    # Entire middle column is unselectable
    return nil
  end

  # Animates scrollable button movement when left or right buttons are pressed
  def animate(direction)
    # Keeps shifting columns until it finds one with at least one selectable button
    while true
      animate_one_col(direction)
      new_row = get_selectable_row_for_middle_col
      if !new_row.nil?
        @selected_row = new_row
        break
      end
    end
  end

  # Animates scrollable button movement when left or right buttons are pressed by one column
  def animate_one_col(direction)
    # Parameter check for direction
    if direction != "left_pressed" && direction != "right_pressed"
      raise _INTL("Direction must be one of: \"left_pressed\", \"right_pressed\". Direction provided was: #{direction}")
    end
    pbPlayCursorSE
    # Number of frames to play animation for
    frames = 9
    # Stores temporary button sprites to animate while movement is happening. For example, if buttons are moving to the left,
    # these would show up on the right side, and vice versa.
    wrapped_buttons = []
    if direction == "right_pressed"
      # Copy right-side buttons (col 4)
      for j in 0...NUM_MAIN_BUTTON_ROWS
        src_button = @sprites["button_#{NUM_MAIN_BUTTON_COLS - 1}#{j}"]
        copied_button = src_button.copy_invisible(@color_shift, @viewport)
        text_col = src_button.text_col + 1
        text_col = 0 if text_col > 3
        copied_button.setTextRowCol(src_button.text_row, text_col)
        copied_button.x += src_button.width
        copied_button.crop
        copied_button.visible = true
        wrapped_buttons.push(copied_button)        
      end
    else
      # Copy left-side buttons (col 0)
      for j in 0...NUM_MAIN_BUTTON_ROWS
        src_button = @sprites["button_0#{j}"]
        copied_button = src_button.copy_invisible(@color_shift, @viewport)
        text_col = src_button.text_col - 1
        text_col = 3 if text_col < 0
        copied_button.setTextRowCol(src_button.text_row, text_col)
        copied_button.x -= copied_button.width
        copied_button.crop
        copied_button.visible = true
        wrapped_buttons.push(copied_button)
      end
    end
    # Main animation loop
    loop do
      Graphics.update
      Input.update
      # If right is pressed, buttons move to the left
      if direction == "right_pressed" && frames >= 0
        for i in 0...NUM_MAIN_BUTTON_COLS
          # Defines how much to move in the x direction
          dx = [-6.1, -6.6, -8.1, -9.5, -7.9][i]
          # Defines how much to shift the zoom_x and zoom_y factors by
          dz = [0, -0.0065, -0.007, 0.007, 0.0058][i]
          for j in 0...NUM_MAIN_BUTTON_ROWS
            name = "button_#{i}#{j}"
            @sprites[name].updateIndex
            @sprites[name].x += dx
            @sprites[name].zoom_x += dz
            @sprites[name].zoom_y += dz
            @sprites[name].y = Graphics.height/2 - @sprites[name].bitmap.height*@sprites[name].zoom_y/2 - 18 + (j - 1)*160*@sprites[name].zoom_y
            @sprites[name].crop
          end
        end
        wrapped_buttons.each do |wrapped_button|
          wrapped_button.updateIndex
          wrapped_button.x -= 6.1
          wrapped_button.crop
        end
      # If left is pressed, buttons move to the right
      elsif direction == "left_pressed" && frames >= 0
        for i in 0...NUM_MAIN_BUTTON_COLS
          # Defines how much to move in the x direction
          dx = [7, 8.1, 9.5, 7.9, 7][i]
          # Defines how much to shift the zoom_x and zoom_y factors by
          dz = [0.006, 0.007, -0.0074, -0.0064, 0][i]
          for j in 0...NUM_MAIN_BUTTON_ROWS
            name = "button_#{i}#{j}"
            @sprites[name].updateIndex
            @sprites[name].x += dx
            @sprites[name].zoom_x += dz
            @sprites[name].zoom_y += dz
            @sprites[name].y = Graphics.height/2 - @sprites[name].bitmap.height*@sprites[name].zoom_y/2 - 18 + (j - 1)*160*@sprites[name].zoom_y
            @sprites[name].crop
          end
        end
        wrapped_buttons.each do |wrapped_button|
          wrapped_button.updateIndex
          wrapped_button.x += 7
          wrapped_button.crop
        end
      end
      # If animation is ending, dispose of temp buttons and update everything again
      if frames == 0
        wrapped_buttons.each do |wrapped_button|
          wrapped_button.dispose
        end
        wrapped_buttons.clear
        if direction == "left_pressed"
          @selected_text_col -= 1
          @selected_text_col = 3 if @selected_text_col < 0
        else
          @selected_text_col += 1
          @selected_text_col = 0 if @selected_text_col > 3
        end
        update_main_buttons
      end
      # Reduce frame counter
      frames -= 1
      break if frames < 0
    end
  end
  
  # Shows left and right online buttons
  def go_online
    @is_online = true
    @sprites["online_left_button"].visible = true
    @sprites["online_left_text"].visible = true
    @sprites["online_right_button"].visible = true
    @sprites["online_right_text"].visible = true
    update_online_frame_and_text
  end

  # Updates the online buttons based on is_online
  def update_online_frame_and_text
    # Online mode frame has 3 spaces, offline mode only has one
    filename = @is_online ? "pausemenu_onframe_Online" : "pausemenu_onframe_Offline"
    old_bitmap = @sprites["online_frame"].bitmap
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed?
    @sprites["online_frame"].bitmap = Bitmap.new(AzuriteMenuSettings::FOLDER_PATH + filename)
    @sprites["online_frame"].bitmap.hue_change(@color_shift)
    @sprites["online_frame"].zoom_x = 0.5
    @sprites["online_frame"].zoom_y = 0.5
    @sprites["online_frame"].x = Graphics.width/2 - @sprites["online_frame"].bitmap.width*@sprites["online_frame"].zoom_x/2
    @sprites["online_frame"].y = 15
    @sprites["online_frame"].z = 1

    @sprites["online_mid_button"].y = @sprites["online_frame"].y - 4

    # Online mode shows options "Trade", "Battle", "Social", while offline mode shows just "Go Online"
    onlineTextSheet_rect_x = @is_online ? @onlineTextSheet.width/3 : 0
    onlineTextSheet_rect_y = @is_online ? @onlineTextSheet.height/2 : 0
    old_bitmap = @sprites["online_mid_text"].bitmap
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed?
    @sprites["online_mid_text"].bitmap = Bitmap.new(@onlineTextSheet.width/3, @onlineTextSheet.height/2)
    @sprites["online_mid_text"].bitmap.blt(0, 0, @onlineTextSheet,
      Rect.new(onlineTextSheet_rect_x, onlineTextSheet_rect_y, @onlineTextSheet.width/3, @onlineTextSheet.height/2))
    @sprites["online_mid_text"].zoom_x = 0.5
    @sprites["online_mid_text"].zoom_y = 0.5
    @sprites["online_mid_text"].x = @sprites["online_mid_button"].x
    @sprites["online_mid_text"].y = @sprites["online_frame"].y + 2
    @sprites["online_mid_text"].z = 3
  end
  
  # Updates all scrollable buttons (NOT online, settings, or quit buttons)
  def update_main_buttons
    # Gets text col starting from the leftmost buttons
    cur_text_col = @selected_text_col - 3
    cur_text_col += 4 if cur_text_col < 0
    for i in 0...NUM_MAIN_BUTTON_COLS
      cur_text_col += 1
      cur_text_col -= 4 if cur_text_col > 3
      for j in 0...NUM_MAIN_BUTTON_ROWS
        name = "button_#{i}#{j}"
        y_offset = 18
        zoom = [0.35, 0.42, 0.5, 0.42, 0.35][i]
        x_offset = [-177, -97, 0, 97, 177][i]
        @sprites[name].zoom_x = zoom
        @sprites[name].zoom_y = zoom
        @sprites[name].x = Graphics.width/2 - @sprites[name].bitmap.width*@sprites[name].zoom_x/2 + x_offset
        @sprites[name].y = Graphics.height/2 - @sprites[name].bitmap.height*@sprites[name].zoom_y/2 - y_offset + (j - 1)*160*@sprites[name].zoom_y
        @sprites[name].setTextRowCol(j, cur_text_col)
        @sprites[name].updateIndex
        @sprites[name].crop
      end
    end
  end

  # Updates which online button is selected
  def update_selected_online_button(direction)
    # Parameter check for direction
    if direction != "left_pressed" && direction != "right_pressed"
      raise _INTL("Direction must be one of: \"left_pressed\", \"right_pressed\". Direction provided was: #{direction}")
    end
    return if !@is_online
    if direction == "left_pressed"
      @selected_online_col -= 1
      @selected_online_col = 2 if @selected_online_col < 0
    else
      @selected_online_col += 1
      @selected_online_col = 0 if @selected_online_col > 2
    end
    update_sel
  end
  
  # If any scrollable buttons are currently selected, un-selects it
  def hide_sel
    for j in 0...NUM_MAIN_BUTTON_ROWS
      @sprites["button_2#{j}"].updateIndex
    end
  end
  
  # Moves cursor up
  def move_cursor_up
    while true
      @selected_row -= 1
      @selected_row = 5 if @selected_row < 0
      # Skip over unselectable buttons
      name = "button_2#{@selected_row - 1}"
      break if @selected_row == 0 || @selected_row > 3 || @sprites[name].nil? || @sprites[name].available?
    end
    update_sel
  end
  
  # Moves cursor down
  def move_cursor_down
    while true
      @selected_row += 1
      @selected_row = 0 if @selected_row > 5
      # Skip over unselectable buttons
      name = "button_2#{@selected_row - 1}"
      break if @selected_row == 0 || @selected_row > 3 || @sprites[name].nil? || @sprites[name].available?
    end
    update_sel
  end
  
  # Updates selected button
  def update_sel
    # Reset cursor
    for j in 0...NUM_MAIN_BUTTON_ROWS
      @sprites["button_2#{j}"].updateIndex
    end
    @sprites["online_left_button"].bitmap.clear
    @sprites["online_left_button"].bitmap.blt(0, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    @sprites["online_mid_button"].bitmap.clear
    @sprites["online_mid_button"].bitmap.blt(0, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    @sprites["online_right_button"].bitmap.clear
    @sprites["online_right_button"].bitmap.blt(0, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    @sprites["settings_button"].bitmap.clear
    @sprites["settings_button"].bitmap.blt(0, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    @sprites["quit_button"].bitmap.clear
    @sprites["quit_button"].bitmap.blt(0, 0, @buttonSheetSmall, @buttonSheetSmall.rect)

    # If a scrollable button is selected
    if @selected_row >= 1 && @selected_row <= 3
      @sprites["button_2#{@selected_row - 1}"].select
    # Online button
    elsif @selected_row == 0
      if !@is_online || @selected_online_col == 1
        @sprites["online_mid_button"].bitmap.clear
        @sprites["online_mid_button"].bitmap.blt(-MISC_BUTTON_WIDTH, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
      elsif @selected_online_col == 0
        @sprites["online_left_button"].bitmap.clear
        @sprites["online_left_button"].bitmap.blt(-MISC_BUTTON_WIDTH, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
      elsif @selected_online_col == 2
        @sprites["online_right_button"].bitmap.clear
        @sprites["online_right_button"].bitmap.blt(-MISC_BUTTON_WIDTH, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
      end
    # Settings button
    elsif @selected_row == 4
      @sprites["settings_button"].bitmap.clear
      @sprites["settings_button"].bitmap.blt(-MISC_BUTTON_WIDTH, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    # Quit button
    elsif @selected_row == 5
      @sprites["quit_button"].bitmap.clear
      @sprites["quit_button"].bitmap.blt(-MISC_BUTTON_WIDTH, 0, @buttonSheetSmall, @buttonSheetSmall.rect)
    end
  end
end

class AzuriteMenu
  def initialize(scene)
    @scene = scene
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
  end

  # Calls pause menu handler "effect" proc if "condition" proc returns true.
  def pbCallPauseMenu(option, unallowed_text)
    # If condition is true, call the effect, else display message to player
    if call_menu_handler_condition_proc(option)
      return MenuHandlers.call(:pause_menu, option, "effect", @scene)
    else
      pbMessage(unallowed_text)
      return false
    end
  end

  def pbStartPokemonMenu
    @scene.pbStartScene
    $player.pokedex.refresh_accessible_dexes
    # Quick validation that player object exists
    if !$player
      if $DEBUG
        pbMessage(_INTL("The player trainer was not defined, so the menu can't be displayed."))
        pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    # Main animation loop
    loop do
      Graphics.update
      Input.update
      # Update selected button
      if Input.repeat?(Input::LEFT)
        # Online buttons
        if @scene.selected_row == 0 && @scene.is_online
          @scene.update_selected_online_button("left_pressed")
        # Scrollable buttons
        elsif @scene.selected_row >= 1 && @scene.selected_row <= 3
          @scene.hide_sel
          @scene.animate("left_pressed")
          @scene.update_sel
        end
      end
      if Input.repeat?(Input::RIGHT)
        # Online buttons
        if @scene.selected_row == 0 && @scene.is_online
          @scene.update_selected_online_button("right_pressed")
        # Scrollable buttons
        elsif @scene.selected_row >= 1 && @scene.selected_row <= 3
          @scene.hide_sel
          @scene.animate("right_pressed")
          @scene.update_sel
        end
      end
      if Input.repeat?(Input::UP)
        @scene.move_cursor_up
        pbPlayCursorSE
      end
      if Input.repeat?(Input::DOWN)
        @scene.move_cursor_down
        pbPlayCursorSE
      end
      # Handle button being clicked on
      # TODO: Some of these menu handlers need to be filled in after they've been created.
      if Input.trigger?(Input::C)
        case @scene.selected_row
        when 0
          # Online
          @scene.go_online if !@scene.is_online
        when 1
          case @scene.selected_text_col
          when 0
            # Party
            break if pbCallPauseMenu(:party, _INTL("You don't have any Pokémon with you!"))
          when 1
            # Pokedex
            break if pbCallPauseMenu(:pokedex, _INTL("The Pokédex is not accessible at this time!"))
          when 2
            # Suite

          when 3
            # Map
            break if pbCallPauseMenu(:town_map, _INTL("The map is not accessible at this time!"))
          end
        when 2
          case @scene.selected_text_col
          when 0
            # Bag
            break if pbCallPauseMenu(:bag, _INTL("The bag is not accessible at this time!"))
          when 1
            # Mega evo.

          when 2
            # Guild
            pbFadeOutIn {
              pbStartGuildScreen
            }
          when 3
            # Scout

          end
        when 3
          case @scene.selected_text_col
          when 0
            # Save
            break if pbCallPauseMenu(:save, _INTL("Saving is not allowed at this time!"))
          when 1
            # Cr. record

          when 2
            # Train

          when 3
            # Radio
            
          end
        when 4
          # Settings
          if $DEBUG && pbConfirmMessage(_INTL("Open Debug menu?"))
            break if MenuHandlers.call(:pause_menu, :debug, "effect", @scene)
          else
            break if MenuHandlers.call(:pause_menu, :options, "effect", @scene)
          end
        when 5
          # Exit
          break if MenuHandlers.call(:pause_menu, :quit_game, "effect", @scene)
        end
      end
      if Input.trigger?(Input::B)
        break
      end
    end
    @scene.pbEndScene
  end
end