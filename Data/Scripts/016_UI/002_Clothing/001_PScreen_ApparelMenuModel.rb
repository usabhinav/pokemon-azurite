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
  SelectedItemChange = "SelectedItemChangeEvent"
  TabChange = "TabChangeEvent"
  OutfitModeChange = "OutfitModeChangeEvent"
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



    selected_item = 0
    # @scroll_index = 0

    notify(GenericChangeEvent.new(APPCONST_EVENT::TabChange, @selected_tab))
  end

  def toggleOutfitMode
    
    if @outfit_mode == APPCONST_OUTFITMODE::DRYSUIT
      @outfit_mode = APPCONST_OUTFITMODE::SWIMSUIT
    else
      @outfit_mode = APPCONST_OUTFITMODE::DRYSUIT
    end
    
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
    # Make the hash point to the correct lists, leave out the multi-layered ones
    # out for later.
    @apparel_tabs["Hat"] = @apparel_bag["Hat"]
    @apparel_tabs["Hair"] = @apparel_bag["Hair"]
    @apparel_tabs["Torso"] = @apparel_bag["Torso"]
    @apparel_tabs["Legs"] = @apparel_bag["Legs"]
    @apparel_tabs["Shoes"] = @apparel_bag["Shoes"]
    # Construct the multilayered parts of the list
    # TODO: Only update this when new items get added
    @apparel_tabs["Face"] = []
    for apparel in @apparel_bag["UpperFace"]
      @apparel_tabs["Face"].push("UpperFace-" + apparel)
=begin
      @apparel_tabs["Face"].push("UpperFace-" + "1-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "2-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "1-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "2-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "1-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "2-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "1-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "2-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "1-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "2-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "1-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "2-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "1-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "2-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "1-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "2-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "1-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "2-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "1-Default")
      @apparel_tabs["Face"].push("UpperFace-" + "2-Default")
=end

    end
    for apparel in @apparel_bag["LowerFace"]
      @apparel_tabs["Face"].push("LowerFace-" + apparel)
    end
    for apparel in @apparel_bag["Eyes"]
      @apparel_tabs["Face"].push("Eyes-" + apparel)
    end
    # Todo: Sort the list afterwards
    @apparel_tabs["Misc"] = []
    for apparel in @apparel_bag["Socks"]
      @apparel_tabs["Misc"].push("Socks-" + apparel)
    end
    for apparel in @apparel_bag["Bike"]
      @apparel_tabs["Face"].push("Bike-" + apparel)
    end
    for apparel in @apparel_bag["Rod"]
      @apparel_tabs["Face"].push("Rod-" + apparel)
    end

    #@item_amount = item_amount

    @selected_item = 0
    #@scroll_index = 0
    #@cursor_lock_threshhold = 3

    # Points to which tab is currently selected
    # Set the starting tab to Hairstyles
    @selected_tab = 2

    @outfit_mode = APPCONST_OUTFITMODE::DRYSUIT
  end

  def selectApparel(outfitstate)

    tab_name = pbGetApparelTabName(@selected_tab)
    item_data = @apparel_tabs[tab_name][@selected_item].split("-") # + @scroll_index].split("-")
    # If result has the length of two:
    # item[0] = ID of apparel piece
    # item[1] = Color of apparel piece
    if item_data.length == 2
      layer_name = tab_name
      apparel_id = item_data[0].to_i
      apparel_color = item_data[1]
    # If result is longer than two:
    # item[0] = Layer of apparel piece
    # item[1] = ID of apparel piece
    # item[2] = Color of apparel piece
    else
      layer_name = item_data[0]
      apparel_id = item_data[1].to_i
      apparel_color = item_data[2]
    end

    if @outfit_mode == APPCONST_OUTFITMODE::DRYSUIT
      outfitstate.setDryLayerPart(layer_name, apparel_id, apparel_color)
    elsif @outfit_mode ==  APPCONST_OUTFITMODE::SWIMSUIT
      outfitstate.setWetLayerPart(layer_name, apparel_id, apparel_color)
    end

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
  
  def initialize(label, value)
    @label = label
    @value = value
  end

end
