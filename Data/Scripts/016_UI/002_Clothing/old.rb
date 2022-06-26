  # def constructRows(tabname, apparellist)

    # Index of displayed item.
    # item_i = 0
    
    # Index of current element from 'apparellist'.
    # list_i = 0;
  
    # while item_i < @displayable_items &&  item_i < apparellist[tabname].length
      # Get data about the current item
      # item_data = apparellist[tabname][item_i + @scroll_index].split("-")
      
      # if tabname == "Face"
        # echo item_data.inspect + "\n"
      # end
      
      # If result has the length of two:
      # item[0] = ID of apparel piece
      # item[1] = Color of apparel piece
      # if item_data.length == 2
        # layername = tabname
        # apparel_id = item_data[0].to_i
        # apparel_color = item_data[1]
      # If result is longer than two:
      # item[0] = Layer of apparel piece
      # item[1] = ID of apparel piece
      # item[2] = Color of apparel piece
      # else
        # layername = item_data[0]
        # apparel_id = item_data[1].to_i
        # apparel_color = item_data[2]
      # end

      # Skip an element if we are in swimsuit mode and the apparel piece cannot be worn in water.
      # Also make sure we still progress the list.
      # if @model.outfit_mode == APPCONST_OUTFITMODE::SWIMSUIT &&
          # !pbCanSwimWith(layername, apparel_id)
          
          # list_i += 1
          # next
      # end

      # Construct the text for our item
      # item_text = ""
      # Put the color in front of the apparel name if it has one
      # if apparel_color != "Default"
        # item_text += apparel_color + " "
      # end
      # Add the apparel name

      # echo "\n\n" +layername +" " + apparel_id.to_s + "\n\n"

      # item_text += pbGetApparelName(layername, apparel_id)

      # @sprites["item" + item_i.to_s].bitmap.clear
      # @sprites["item" + item_i.to_s].bitmap.draw_text(10,2, 270, 20, item_text)
      # item_i += 1
      # list_i += 1
    # end
  # end
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  # for apparel in @apparel_bag["UpperFace"]
      # #@apparel_tabs["Face"].push("UpperFace-" + apparel)
      # @apparel_tabs["Face"].push(apparel)
      # #@tab_metadata["Misc"].push("UpperFace")
    # end
    # for apparel in @apparel_bag["LowerFace"]
      # @apparel_tabs["Face"].push(apparel)
    # end
    # for apparel in @apparel_bag["Eyes"]
      # @apparel_tabs["Face"].push(apparel)
    # end
    # # Todo: Sort the list afterwards
    # @apparel_tabs["Misc"] = []
    # for apparel in @apparel_bag["Socks"]
      # @apparel_tabs["Misc"].push(apparel)
    # end
    # for apparel in @apparel_bag["Bike"]
      # @apparel_tabs["Face"].push(apparel)
    # end
    # for apparel in @apparel_bag["Rod"]
      # @apparel_tabs["Face"].push(apparel)
    # end
    
        # for apparel in @apparel_bag["Socks"]
      # @apparel_tabs["Misc"].push(apparel)
    # end
    # for apparel in @apparel_bag["Bike"]
      # @apparel_tabs["Face"].push(apparel)
    # end
    # for apparel in @apparel_bag["Rod"]
      # @apparel_tabs["Face"].push(apparel)
    # end
    
    
    
    
      # def updatePOutfitState
  
  # echoln "Updating Preview Outfit State"
  
    # if @model.selected_tab == APPCONST_TAB::FAVOURITES
      # set_name = @model.apparel_tabs["Favourites"][@model.selected_item]
      # @p_outfitstate = pbDeepCopy(@model.getSet(set_name))
    # else
      # @model.applyTo(@p_outfitstate, false)
    # end
  # end
  
  # def updatePrevPOutfitState
    # if @model.selected_tab == APPCONST_TAB::FAVOURITES
      # set_name = @model.apparel_tabs["Favourites"][@model.selected_item]
      # @prevp_outfitstate = pbDeepCopy(@model.getSet(set_name))
    # else
      # @model.applyTo(@prevp_outfitstate, false)
    # end
  # end