module APPCONST_TAB
  FAVOURITES = 0
  HAT = 1
  HAIR = 2
  FACE = 3
  TORSO = 4
  LEGS = 5
  SHOES = 6
  MISC = 7
  SEARCH = 8
  SWITCH = 9
end

module APPCONST_EVENT
  SelectedItemChange  = "SelectedItemChangeEvent"
  TabChange           = "TabChangeEvent"
  OutfitModeChange    = "OutfitModeChangeEvent"
  InitMenu            = "InitializeMenuEvent"
  ApplySelectedItem   = "ApplySelectedItemEvent"
  UnselectItem        = "UnselectItemEvent"
end

module APPCONST_OUTFITMODE # These correspond to the prefix of the menu image filenames.
  DRYSUIT = "Clothing"
  SWIMSUIT = "Swimsuit"
end

class PokemonApparelMenu

  include Observable

  @@TAB_NAMES = ["Favourites", "Hat", "Hair", "Face", "Torso", "Legs", "Shoes", "Misc", "Search", "Switch"]


  attr_accessor :selected_item #:cursor_index
  attr_reader :apparel
#  attr_reader :item_amount # Moved over to Scene
  attr_reader :apparel_tabs
#  attr_reader :scroll_index # Moved over to Scene
  # Is either set to "Clothing" or "Swimsuit"
  attr_reader :outfit_mode

  # Additional members:
  # selected_tab - index value for which tab is currently selected
  
  def selected_item
    return @selected_item
  end

  def selected_tab
    return @selected_tab
  end
  
  def outfit_mode
    return @outfit_mode
  end

  def selected_item=(value)
    # Only allow a change if it stays within bounds. Don't allow it unless we are in an apparel selection tab.
    if @selected_tab != APPCONST_TAB::SWITCH && (value >= 0) && (value < @apparel_tabs[pbGetApparelTabName(@selected_tab)].length) 
      @selected_item = value
      notify(GenericChangeEvent.new(APPCONST_EVENT::SelectedItemChange, @selected_item))
    end
  end

  def selected_tab=(value)

    if value >= @@TAB_NAMES.length # Restart tab index from the left if the index gets too big
      @selected_tab = 0
    elsif value < 0 # Restart tab index from the right if the index gets too small
      @selected_tab = @@TAB_NAMES.length - 1
    else # Simply apply the value if it is validly indexing a tab name
      @selected_tab = value
    end

    # Adjust the item amount for different tab types
    # @item_amount = returnValueBasedOnTabType(9, 8, 2)



    @selected_item = 0
    # @scroll_index = 0

    notify(GenericChangeEvent.new(APPCONST_EVENT::TabChange, @selected_tab))
    #notify(GenericChangeEvent.new(APPCONST_EVENT::SelectedItemChange, @selected_item))
  end

  def createSet(set_name, outfitstate)
    # Add it to the bag so it gets saved.
    $ApparelBag.sets[outfit_mode][set_name] = outfitstate
    # Add it to the sets tab.
    @apparel_tabs["Favourites"].push(set_name)
  end
  
  def getSet(set_name)
    return $ApparelBag.sets[@outfit_mode][set_name]
  end
  
  def hasSet(set_name)
    return $ApparelBag.sets[@outfit_mode].has_key?(set_name)
  end 
  
  def toggleOutfitMode
    
    if @outfit_mode == APPCONST_OUTFITMODE::DRYSUIT
      @outfit_mode = APPCONST_OUTFITMODE::SWIMSUIT
    else
      @outfit_mode = APPCONST_OUTFITMODE::DRYSUIT
    end
    
    # Different outfit modes have different apparel pieces available.
    updateTabs
    
    notify(GenericChangeEvent.new(APPCONST_EVENT::OutfitModeChange, @outfit_mode))
  end

  alias old_initialize initialize

  def initialize(apparel_bag)#, item_amount=9)
    # First call the init method obtained from including Observable
    old_initialize

    # All the apparel the player has acquired grouped in a Hash by layer
    @apparel_bag = apparel_bag

    # Hash containing lists for apparel for every layer. Some lists directly
    # belong to the ApparelBag by our menu model, others are a collection of
    # multiple elements due to their multi-layered nature (for example Face
    # contains UpperFace and LowerFace apparel)
    @apparel_tabs = Hash.new
    
    #@item_amount = item_amount

    @selected_item = 0
    #@scroll_index = 0
    #@cursor_lock_threshhold = 3

    # Points to which tab is currently selected
    # Set the starting tab to Hairstyles
    @selected_tab = 2

    @outfit_mode = APPCONST_OUTFITMODE::DRYSUIT
    
    updateTabs
  end

  def updateTabs
    # CONSTRUCT:
    # Fill the tabs with items from the apparel bag. Don't use a direct reference but
    # instead copy it, so that we can sort and filter the tabs without changing
    # the bag (duplicating should be enough, since we don't change the values themselves,
    # which also should be strings anyway unless I changed it, 
    # but change to pbDeepCopy if needed in the future).
    @apparel_tabs["Hat"] = @apparel_bag["Hat"].dup
    @apparel_tabs["Hair"] = @apparel_bag["Hair"].dup
    @apparel_tabs["Torso"] = @apparel_bag["Torso"].dup
    @apparel_tabs["Legs"] = @apparel_bag["Legs"].dup
    
    
    # Construct the multilayered tabs. (Same thing applies to here with pbDeepCopy before concatenating)
    @apparel_tabs["Face"] = []
    @apparel_tabs["Face"].concat(@apparel_bag["UpperFace"])
    @apparel_tabs["Face"].concat(@apparel_bag["LowerFace"])
    @apparel_tabs["Face"].concat(@apparel_bag["Eyes"])
    @apparel_tabs["Face"].concat(@apparel_bag["UpperFace"])
    
    # Mix the socks in with the shoes for now.
    @apparel_tabs["Shoes"] = @apparel_bag["Shoes"].dup
    @apparel_tabs["Shoes"].concat(@apparel_bag["Socks"])
    
    @apparel_tabs["Misc"] = []
    @apparel_tabs["Misc"].concat(@apparel_bag["Rod"])
    @apparel_tabs["Misc"].concat(@apparel_bag["Bike"])
    
    @apparel_tabs["Favourites"] = $ApparelBag.sets[@outfit_mode].keys
    @apparel_tabs["Search"] = []
    @apparel_tabs["Switch"] = [] # Not needed but still here so iterating through the tabs is less painful.
    
    echoln "1: THIS IS THE TAB HASH " + @apparel_tabs.to_s
    echoln "AND THIS IS THE APPAREL BAG HASH: " + @apparel_bag.to_s
    
    # FILTER:
    # If we are in swimsuit mode, remove some items.
    if(outfit_mode == APPCONST_OUTFITMODE::SWIMSUIT)
      @apparel_tabs.each do |tab, apparel_list|
        # Use delete_if instead of select here so we don't waste
        # more memory.
        apparel_list.delete_if { |bag_item_data| 
          item = ApparelBag.fetchItem(bag_item_data)
        
          # Don't include the item if it's not a regular apparel piece.
          ret = false
          if(item.class.superclass == GameData::ApparelRegularModel)
            # Now we can check for the swimsuit flag (only regular apparel has that).
            ret = item.swimsuit
          end
          
          #echoln "BAG ITEM DATA: " + bag_item_data.to_s
          #echoln "SUPERCLASS: " + item.class.to_s
          #echoln "RET = :" + ret.to_s
          
          # Is ret true, it means that this item is wearable in water. Therefore, we do
          # not want to delete it.
          !ret
        }
        
      end
    end
    
    echoln "2: THIS IS THE TAB HASH " + @apparel_tabs.to_s
    
    # SORT: (to be continued!)
  end
  

  def applyTo(outfitstate, doNotify = true)

    # Ignore some tabs for now.
    if @selected_tab == APPCONST_TAB::SEARCH || 
       @selected_tab == APPCONST_TAB::FAVOURITES
      echoln "Returning now?"
      return
    end

    tab_name = pbGetApparelTabName(@selected_tab)
    bag_item_data = @apparel_tabs[tab_name][@selected_item] # + @scroll_index].split("-")
    
    if(bag_item_data != nil)
      item = ApparelBag.fetchItem(bag_item_data)
      layer = item.class::LAYER
      color = ApparelBag.fetchColor(bag_item_data)

      #echoln "LAYERNAME: " + layer_name + " COLOR: " + apparel_color

      if @outfit_mode == APPCONST_OUTFITMODE::DRYSUIT
        outfitstate.setDryLayerState(layer, item.id_number, color)
      elsif @outfit_mode ==  APPCONST_OUTFITMODE::SWIMSUIT
        outfitstate.setWetLayerState(layer, item.id_number, color)
      end
      
      if doNotify
        notify(GenericChangeEvent.new(APPCONST_EVENT::ApplySelectedItem, outfitstate))
      end
    end
  end

  def getSelectedItemData
    tab_name = pbGetApparelTabName(@selected_tab)
    return @apparel_tabs[tab_name][@selected_item]
  end

  class << self

    def getTabName(index)
      return @@TAB_NAMES[index]
    end

    def TAB_NAMES
      return @@TAB_NAMES
    end

  end

end

# Only really relevant to access item values from the tab hash. (TODO: Change this to the ItemData model)
def pbGetApparelTabName(index)

  return PokemonApparelMenu.getTabName(index)
end



#===============================================================================
# EVENTS DEFINED FOR UPDATING THE SCENE
#===============================================================================
class TabChangeEvent

  attr_accessor :new_tab_index

  def initialize(new_tab_index)
    @new_tab_index = new_tab_index
  end
end

class SelectedItemChangeEvent
  attr_accessor :new_selected_item

  def initialize(new_selected_item)
    @new_selected_item = new_selected_item
  end
end

class OutfitModeChangeEvent
  attr_accessor :new_selected_item

  def initialize(new_selected_item)
    @new_selected_item = new_selected_item
  end
end

class GenericChangeEvent

  attr_reader :label
  attr_reader :value
  
  def initialize(label, value=nil)
    @label = label
    @value = value
  end

end
