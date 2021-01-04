class PokemonApparelMenu_Scene

  def pbStartScene(menumodel, outfitstate)
    @menumodel = menumodel
    @outfitstate = outfitstate


    # The index of the cursor, stays the same per (normal) tab
    @cursor_index = 0
    @scroll_index = 0

    
    
    # Have a scroll index for every tab and start them all at 0
    #@scroll_indices = []
    #until @scroll_indices.length < PokemonApparelMenu.TAB_NAMES.length do
    #  @scroll_indices[@scroll_indices.length] = 0
    #end

    # Contains all graphical components for the menu
    @sprites = {}

    # The background
    @bgviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @bgviewport.z = 99999
    @sprites["background"] = IconSprite.new(0,0,@bgviewport)
#    @sprites["background"].setBitmap("Graphics/Pictures/Apparel/" +
#      @apparelbag.outfit_mode +
#      ApparelBag.getTabName(@apparelbag.selected_tab))

    # The item space
    @itembox_x = 10
    @itembox_y = 88
    @itembox_w = 272
    @itembox_h = 280

    # The amount of items that can be displayed
    @displayable_items = 9

    @ibviewport = Viewport.new(@itembox_x, @itembox_y, @itembox_w, @itembox_h)
    @ibviewport.z = 99999

    @item_w = @itembox_w
    @item_h = @itembox_h / @displayable_items

    i = 0
    while i < @displayable_items
      @sprites["item" + i.to_s] = IconSprite.new(0, 0 + @item_h * i, @ibviewport)
      @sprites["item" + i.to_s].bitmap = BitmapWrapper.new(@item_w, @item_h)

      echo "Item_H: " + (@item_h * i).to_s + "\n"
      i += 1
    end

    # Defines the item index at which the cursor gets locked in place
    # in case enough apparel exists in a tab to scroll down
    @cursor_lock_threshhold = 3

    # Initialize the cursor
    @sprites["cursor"] = IconSprite.new(0,0, @ibviewport)
    @sprites["cursor"].setBitmap("Graphics/Pictures/Apparel/Cursor.png")
    
    update(self)
  end
  
  def updateTabs(event=nil)

    # Set the correct background displaying the selected tab
    @sprites["background"].setBitmap("Graphics/Pictures/Apparel/" +
      @menumodel.outfit_mode +
      PokemonApparelMenu.getTabName(@menumodel.selected_tab))

    # Clear all rows
    i = 0
    while i < @displayable_items
      @sprites["item" + i.to_s].bitmap.clear
      i += 1
    end

    # Display the items depending on which tab is selected
    case @menumodel.selected_tab
    when 0 # Favourites
    when 1 # Hat
      constructRows("Hat", @menumodel.apparel_tabs)
    when 2 # Hair
      constructRows("Hair", @menumodel.apparel_tabs)
    when 3 # Face
      constructRows("Face", @menumodel.apparel_tabs)
    when 4 # Torso
      constructRows("Torso", @menumodel.apparel_tabs)
    when 5 # Legs
      constructRows("Legs", @menumodel.apparel_tabs)
    when 6 # Shoes
      constructRows("Shoes", @menumodel.apparel_tabs)
    when 7 # Misc
      # TODO: Only update this when new items get added
      constructRows("Misc", @menumodel.apparel_tabs)
    when 8 # Search
    when 9 # Switch
    end
  end

  def updateCursor(event)
    
    if event.instance_of?(SelectedItemChangeEvent)
      # Points to which item the cursor is selecting currently
      cursor_selection = @cursor_index + @scroll_index
  
      # TODO: If needed, expand so that we can go up more than 1 position at once
      if(cursor_selection > event.new_selected_item) # New selected item is further up
        # Do we have to scroll up or move the cursor up?
        # Check if cursor reached the cursor lock threshhold from the top side,
        # and if we still have elements at the top we can scroll up for
        if @cursor_index <= @cursor_lock_threshhold && @scroll_index != 0
  
          # Calculate the amount we have to go up
          #cursor_movement = cursor_selection - event.new_selected_item
  
          # If the amount we try to go up exceeds the amount we can scroll up,
          # set the scroll index to 0 and lower the movement that is left
          #if
  
  
          @scroll_index -= 1
        else
          @cursor_index -= 1 if @cursor_index > 0
        end
      elsif(cursor_selection < event.new_selected_item) # New selected item is further down
  
        apparel_amount = @menumodel.apparel_tabs[pbGetApparelTabName(@menumodel.selected_tab)].length
  
        # Do we have to scroll down or move the cursor down?
        # Check if cursor reached the cursor lock threshhold from the bottom side,
        # and if we still have elements at the bottom we can scroll down for
        if @cursor_index >= (@displayable_items-1) - @cursor_lock_threshhold &&
           @scroll_index + @displayable_items < apparel_amount
          @scroll_index += 1
        else
          # Check if the cursor stays within the item box but also if we still have
          # an item left to move the cursor to
          if @cursor_index < @displayable_items - 1 && @cursor_index + @scroll_index < (apparel_amount-1)
            @cursor_index += 1
          end
        end
      end
    elsif event.instance_of?(TabChangeEvent)
      
      if @menumodel.selected_tab == APPCONST_TAB::SEARCH
        @displayable_items = 8
      end
      
    end
        
    @sprites["cursor"].y = @cursor_index * @item_h

  end
  
  def update(observer, event=nil)

    if event.instance_of? TabChangeEvent
      updateTabs(event)
      # Depending on the tab the cursor might need to change shape or adjust
      # it's position
      updateCursor(event)
    elsif event.instance_of? SelectedItemChangeEvent
      updateCursor(event)
    else # Last possibility is nil class, in that case just update everything
      updateCursor(SelectedItemChangeEvent.new(@menumodel.selected_item))
      updateTabs(TabChangeEvent.new(@menumodel.selected_tab))
    end

    #@sprites["item1"].bitmap = BitmapWrapper.new(@item_w, @item_h)
   # pbDrawTextPositions(@sprites["item1"].bitmap,
   #   [_INTL("CLOSE BAG"), 0, 0, 0, Color.new(0,0,255), Color.new(0,0,255)])

    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @bgviewport.dispose
    @ibviewport.dispose
  end

  private
  
  def constructRows(tabname, apparellist)

    item_i = 0

    while item_i < @displayable_items && item_i < apparellist[tabname].length
      # Get data about the current item
      item_data = apparellist[tabname][item_i + @scroll_index].split("-")
      if tabname == "Face"
        echo item_data.inspect + "\n"
      end
      # If result has the length of two:
      # item[0] = ID of apparel piece
      # item[1] = Color of apparel piece
      if item_data.length == 2
        layername = tabname
        apparel_id = item_data[0].to_i
        apparel_color = item_data[1]
      # If result is longer than two:
      # item[0] = Layer of apparel piece
      # item[1] = ID of apparel piece
      # item[2] = Color of apparel piece
      else
        layername = item_data[0]
        apparel_id = item_data[1].to_i
        apparel_color = item_data[2]
      end

      # Construct the text for our item
      item_text = ""
      # Put the color in front of the apparel name if it has one
      if apparel_color != "Default"
        item_text += apparel_color + " "
      end
      # Add the apparel name

      echo "\n\n" +layername +" " + apparel_id.to_s + "\n\n"

      item_text += pbGetApparelName(layername, apparel_id)

      @sprites["item" + item_i.to_s].bitmap.clear
      @sprites["item" + item_i.to_s].bitmap.draw_text(0,0, 100, 20, item_text)
      item_i += 1
    end
  end
  
  # Tab types: Regular, Search, Swimsuit selection
  # Based on what type of tab is active, the correct value is returned
  def returnValueBasedOnTabType(val1, val2, val3)
    if @menumodel.selected_tab == 8 # Search
      return val2
    elsif @menumodel.selected_tab == 9 # Switch
      return val3
    else # Regular
      return val1
    end
  end
  
end

=begin
class ApparelMenuCursor
  include Observable

  attr_reader :cursor_index
  attr_reader :scroll_index

  alias old_initialize initialize

  def moveUp
    # Do we have to scroll up or move the cursor up?
    # Check if cursor reached the cursor lock threshhold from the top side,
    # and if we still have elements at the top we can scroll up for
    if @cursor_index <= @cursor_lock_threshhold && @scroll_index != 0
      @scroll_index -= 1
    else
      @cursor_index -= 1 if @cursor_index > 0
    end

    notify
  end

  def moveDown

    apparel_amount = @apparel_model.apparel_tabs[pbGetApparelTabName(@apparel_model.selected_tab)].length

    # Do we have to scroll down or move the cursor down?
    # Check if cursor reached the cursor lock threshhold from the bottom side,
    # and if we still have elements at the bottom we can scroll down for
    if @cursor_index >= (@displayable_items-1) - @cursor_lock_threshhold &&
       @scroll_index + @displayable_items < apparel_amount
      @scroll_index += 1
    else
      # Check if the cursor stays within the item box but also if we still have
      # an item left to move the cursor to
      if @cursor_index < @displayable_items - 1 && @cursor_index + @scroll_index < (apparel_amount-1)
        @cursor_index += 1
      end
    end

    notify
  end

  def initialize(apparel_model)
    old_initialize
    @apparel_model = apparel_model

  end
end
=end
