class PokemonApparelMenu_Scene

  attr_reader :p_outfitstate
  attr_reader :prevp_outfitstate

  def pbStartScene(model, outfitstate)
    @model = model
    
    # Outfit state of the player.
    @outfitstate = outfitstate
    
    # Outfit state for the preview. Changes by moving the cursor to other items.
    @p_outfitstate = pbDeepCopy(outfitstate)
    # Previous outfit state for the preview. Only changes when an item change gets applied.
    @prevp_outfitstate = pbDeepCopy(outfitstate)

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

    # The item space.
    @itembox_x = 10
    @itembox_y = 88
    @itembox_w = 272
    @itembox_h = 280
    @ibviewport = Viewport.new(@itembox_x, @itembox_y, @itembox_w, @itembox_h)
    @ibviewport.z = 99999

    # The amount of items that can be displayed
    @displayable_items = 9

    @item_w = @itembox_w
    @item_h = @itembox_h / @displayable_items

    i = 0
    while i < @displayable_items
      @sprites["item" + i.to_s] = IconSprite.new(0, 0 + @item_h * i, @ibviewport)
      @sprites["item" + i.to_s].bitmap = BitmapWrapper.new(@item_w, @item_h)
      
      # Set their fonts.
      pbSetSystemFont(@sprites["item" + i.to_s].bitmap)
      
      echo "Item_H: " + (@item_h * i).to_s + "\n"
      i += 1
    end

    # Defines the item index at which the cursor gets locked in place
    # in case enough apparel exists in a tab to scroll down
    @cursor_lock_threshhold = 3

    # The outfit preview space.
    @preview_x = 305
    @preview_y = 74
    @preview_w = 512
    @preview_h = 226
    @pviewport = Viewport.new(@preview_x, @preview_y, @preview_w, @preview_h)
    @pviewport.z = 99999
    
    # Outfit preview image.
    @sprites["preview"] = AnimatedSprite.new("Graphics/Pictures/Apparel/Base.png", 16, 64, 64, 10, @pviewport)
    @sprites["preview"].x = 72
    @sprites["preview"].y = 36
    @sprites["preview"].visible = true
    @sprites["preview"].frame = 0
    @sprites["preview"].start
    @p_outfitstate.applyToOverworldBitmap(@sprites["preview"].bitmap)

    # Initialize the cursor.
    @sprites["cursor"] = IconSprite.new(0,0, @ibviewport)
    @sprites["cursor"].setBitmap("Graphics/Pictures/Apparel/Cursor.png")
    
    update(self, GenericChangeEvent.new(APPCONST_EVENT::InitMenu, nil))
  end
  
  def updateTabs(event)
  
    echo "Label: " + event.label.to_s + ", TabChange: " + APPCONST_EVENT::TabChange
    if event.label == APPCONST_EVENT::TabChange
      
      # Check whether or not to display the cursor.
      if event.value == APPCONST_TAB::SWITCH
        @sprites["cursor"].visible = false
      else
        @sprites["cursor"].visible = true
      end
    
      # Set the correct background displaying the selected tab
      @sprites["background"].setBitmap("Graphics/Pictures/Apparel/" +
        @model.outfit_mode +
        PokemonApparelMenu.getTabName(@model.selected_tab))

      # Clear all rows
      i = 0
      while i < @displayable_items
        @sprites["item" + i.to_s].bitmap.clear
        i += 1
      end

      # Display the items depending on which tab is selected
      case @model.selected_tab
      when 0 # Favourites
        constructRows("Favourites", @model.apparel_tabs)
      when 1 # Hat
        constructRows("Hat", @model.apparel_tabs)
      when 2 # Hair 
        constructRows("Hair", @model.apparel_tabs)
      when 3 # Face
        constructRows("Face", @model.apparel_tabs)
      when 4 # Torso
        constructRows("Torso", @model.apparel_tabs)
      when 5 # Legs
        constructRows("Legs", @model.apparel_tabs)
      when 6 # Shoes
        constructRows("Shoes", @model.apparel_tabs)
      when 7 # Misc
        # TODO: Only update this when new items get added
        constructRows("Misc", @model.apparel_tabs)
      when 8 # Search
      when 9 # Switch
      end
    end


  end

  def updateCursor(event)

    if @model.selected_tab != APPCONST_TAB::SWITCH # Generic item selection tab.
      if event.label == APPCONST_EVENT::SelectedItemChange
        # Points to which item the cursor is selecting currently
        cursor_selection = @cursor_index + @scroll_index
    
        # TODO: If needed, expand so that we can go up more than 1 position at once
        if(cursor_selection > event.value) # New selected item is further up
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
        elsif(cursor_selection < event.value) # New selected item is further down
    
          apparel_amount = @model.apparel_tabs[pbGetApparelTabName(@model.selected_tab)].length
    
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
      elsif event.label == APPCONST_EVENT::TabChange
        
        # Reset cursor and scroll index.
        @cursor_index = 0
        @scroll_index = 0
        
      end
    end
    
    @sprites["cursor"].y = @cursor_index * @item_h

  end
  
  def updateOutfitMode(event)
    
    echoln "UPDATING OUTFITMODE"
    
    if event.label == APPCONST_EVENT::OutfitModeChange
      # Set the correct background displaying the selected tab
      @sprites["background"].setBitmap("Graphics/Pictures/Apparel/" +
        @model.outfit_mode +
        PokemonApparelMenu.getTabName(@model.selected_tab))
    end

    pbUpdateSpriteHash(@sprites)
    
  end
  
  def updatePreview(event)
  
    case event.label
      when APPCONST_EVENT::TabChange
        
        if @model.selected_tab == APPCONST_TAB::SWITCH
          # Don't display preview on the switch tab.
          @sprites["preview"].visible = false
        else
          # Reset the preview. (De-select unapplied item from previous tab)
          @p_outfitstate = pbDeepCopy(@prevp_outfitstate)
          
          # Apply the newly selected item (due to the tab change) to the preview.
          #updatePOutfitState
          @model.applyTo(@p_outfitstate, false)
          
          @sprites["preview"].visible = true
        end
      when APPCONST_EVENT::SelectedItemChange
        # Set the selected item to be visible on the preview.
        @model.applyTo(@p_outfitstate, false)
        #updatePOutfitState
        
      when APPCONST_EVENT::ApplySelectedItem
        # Update the preview outfit.
        @model.applyTo(@p_outfitstate, false) # YES needed, or else it won't update after unselecting # Not really needed
        @model.applyTo(@prevp_outfitstate, false)
        #updatePrevPOutfitState
        
      when APPCONST_EVENT::OutfitModeChange
      
        echoln "CHANGING OUTFIT MODE"
      
        # Toggle the preview outfit states' outfit modes.
        @p_outfitstate.toggleActiveLayerStates
        @prevp_outfitstate.toggleActiveLayerStates
        
        
      when APPCONST_EVENT::UnselectItem
        if(@model.selected_tab != APPCONST_TAB::FAVOURITES) # Can't unselect entire sets.
          # This assumes that the unselecting already took place.
          # This is different from ApplySelectedItem, because we can't
          # infer whether or not an item has been unselected from
          # the selected_item value.
          @p_outfitstate = pbDeepCopy(@outfitstate)
          @prevp_outfitstate = pbDeepCopy(@outfitstate)
        end
    end
  
    # Apply preview outfit changes.
    @p_outfitstate.applyToOverworldBitmap(@sprites["preview"].bitmap)
  
  end
  

  
  def update(observer, event)

    case event.label
      when APPCONST_EVENT::TabChange
        updateTabs(event)
        # Depending on the tab the cursor might need to change shape or adjust
        # it's position
        updateCursor(event)
        updatePreview(event)
      when APPCONST_EVENT::SelectedItemChange
        updateCursor(event)
        # Set the newly selected item onto the preview.
        updatePreview(event)
        # TODO: Do this to hover over items.
      when APPCONST_EVENT::OutfitModeChange
        updateOutfitMode(event)
        # Change the outfit used 
        updatePreview(event)
      when APPCONST_EVENT::InitMenu
        updateCursor(GenericChangeEvent.new(APPCONST_EVENT::SelectedItemChange, @model.selected_item))
        updateTabs(GenericChangeEvent.new(APPCONST_EVENT::TabChange, @model.selected_tab))
        updateOutfitMode(GenericChangeEvent.new(APPCONST_EVENT::OutfitModeChange, @model.outfit_mode))
        updatePreview(event)
      when APPCONST_EVENT::ApplySelectedItem
        updatePreview(event)
    end
    
    #$Trainer.outfitstate.applyToOverworldBitmap(@sprites["preview"].bitmap)


    # if event.instance_of? TabChangeEvent
      # updateTabs(event)
      # # Depending on the tab the cursor might need to change shape or adjust
      # # it's position
      # updateCursor(event)
    # elsif event.instance_of? SelectedItemChangeEvent
      # updateCursor(event)
    # else # Last possibility is nil class, in that case just update everything
      # updateCursor(SelectedItemChangeEvent.new(@model.selected_item))
      # updateTabs(TabChangeEvent.new(@model.selected_tab))
    # end

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
  
  def constructRows(tab_name, apparel_list)

    # Index of displayed item.
    item_i = 0
  
    while item_i < @displayable_items && item_i < apparel_list[tab_name].length
      
      if(tab_name == "Favourites")
        item_text = apparel_list[tab_name][item_i + @scroll_index]
      else
        # Get data about the current item
        bag_item_data = apparel_list[tab_name][item_i + @scroll_index]
        item = ApparelBag.fetchItem(bag_item_data)
        color = ApparelBag.fetchColor(bag_item_data)

        # Construct the text for our item
        item_text = ""
        # Put the color in front of the apparel name if it has one
        if color != "Default"
          item_text += color + " "
        end
        # Add the apparel name

        #echo "\n\n" +layername +" " + apparel_id.to_s + "\n\n"

        item_text += item.real_name
      end

      @sprites["item" + item_i.to_s].bitmap.clear
      @sprites["item" + item_i.to_s].bitmap.draw_text(10,2, 270, 20, item_text)
      item_i += 1
      #list_i += 1
    end
  end
  
  # Tab types: Regular, Search, Swimsuit selection
  # Based on what type of tab is active, the correct value is returned
  def returnValueBasedOnTabType(val1, val2, val3)
    if @model.selected_tab == 8 # Search
      return val2
    elsif @model.selected_tab == 9 # Switch
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
