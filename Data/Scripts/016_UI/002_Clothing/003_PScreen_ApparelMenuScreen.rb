class PokemonApparelMenu_Screen

  def initialize(scene, model, outfitstate)
    @scene = scene
    @model = model
    @outfitstate = outfitstate

    @model.attach(@scene)
  end

  def pbStartScreen
    @scene.pbStartScene(@model, @outfitstate)
    loop do
      
      # Input behaviour for every tab.
      if Input.trigger?(Input::RIGHT)
        @model.selected_tab += 1
      elsif Input.trigger?(Input::LEFT)
        @model.selected_tab -= 1
      elsif Input.trigger?(Input::B)
        break
      
      # Input behaviour for specific tabs.
      else
        case @model.selected_tab
          when APPCONST_TAB::SWITCH # Input behaviour for outfit mode toggle tab.
            
            if Input.trigger?(Input::C)
              echoln "A was pressed! Toggling!"
              @model.toggleOutfitMode
            end
            
          else # Input behaviour for generic apparel selection.

            if Input.trigger?(Input::DOWN)
              @model.selected_item += 1
            elsif Input.trigger?(Input::UP)
              @model.selected_item -= 1
            elsif Input.trigger?(Input::C)
              if @model.selected_tab != APPCONST_TAB::FAVOURITES
                selected_bag_data = @model.getSelectedItemData
                
                # Cancel this if nothing is selected.
                if selected_bag_data != nil
                  item = ApparelBag.fetchItem(selected_bag_data)
                  color = ApparelBag.fetchColor(selected_bag_data)
                  layer = item.class::LAYER
                
                  # if @model.outfit_mode == APPCONST_OUTFITMODE::DRYSUIT
                    # current_layer_parts = @outfitstate.dry_layer_parts
                  # else
                    # current_layer_parts = @outfitstate.wet_layer_parts
                  # end
                  
                  layer_state = @outfitstate.getLayerState(@model.outfit_mode, layer)
                  
                  # If we select the same item that is already selected, simply unselect
                  # it (if possible).
                  echoln "SELECTED_PART_ID: " + layer_state.selected_part.to_s + ", ITEM_ID_NUMBER: " + item.id_number.to_s
                  
                  if(layer_state.selected_part == item.id_number &&
                     layer_state.color == color)
                    @outfitstate.setLayerState(@model.outfit_mode, layer, 0)
                    @scene.updatePreview(GenericChangeEvent.new(APPCONST_EVENT::UnselectItem))
                    echoln "UNAPPLY"
                  else # Otherwise, we apply the menu model to the outfit.
                    @model.applyTo(@outfitstate)
                    echoln "APPLY"
                  end
                end
              else # Selecting a whole set
                #set_name = @model.getSelectedItemData
                #outfit_set = @model.getSet(set_name) # $ApparelBag.sets[set_name]
                #$Trainer.outfitstate = pbDeepCopy(outfit_set)
                echoln "GONNA APPLY SET TO OUTFITSTATE NOW!"
                @model.applyTo(@outfitstate)
              end
                
            elsif Input.trigger?(Input::SHIFT) # Add Set
              set_name = pbMessageFreeText(_INTL("Now enter the set's name."), "", false, 30)
                
              if(@model.hasSet(set_name)) # Don't add if set name exists already.

              else
                new_outfitstate = pbDeepCopy($Trainer.outfitstate)
                @model.createSet(set_name, new_outfitstate)
              end
            
            elsif Input.trigger?(Input::ALT) # Alter Set
              echoln $Trainer.outfitstate.active_layer_states["Hair"].selected_part.to_s
            elsif Input.trigger?(Input::CTRL) # Delete Set
            end
        end
      end
      
      # Empty update to refresh animations.
      @scene.update(self, GenericChangeEvent.new("", nil))
      
      Input.update
      Graphics.update
      
    end
    @scene.pbEndScene
  end
end
