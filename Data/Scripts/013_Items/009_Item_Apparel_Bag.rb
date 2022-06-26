class ApparelBag

  # Contains all the apparel that the player acquired
  attr_reader :apparel

  def initialize
    # Initialize an empty Array for every layer, except for Base
    @apparel = Hash.new
    for layer_name in $LAYER_NAMES
      next if layer_name == "Base"
      # Arrays will hold Strings with ID + color, representing colored apparel
      @apparel[layer_name] = []
    end
    # Include Rod and Bike as extras.
    @apparel["Bike"] = []
    @apparel["Rod"] = []

  end

  # Clears the entire apparel list.
  def clear
    for layername in $LAYER_NAMES
      @apparel[layername].clear
    end
  end

  # Convert an apparel piece in form of a Symbol or String to an ID, or return
  # it as is if it is an ID already.
  def convertToApparelId(layer, apparel_piece)
  
	# Check if the layer actually exists and throw an error if not.
	if !$LAYER_NAMES.include?(layer)
	  raise "convertToApparelId: \"" + layer + "\" is not an existing layer."
	end
		
    if apparel_piece.is_a?(String) || apparel_piece.is_a?(Symbol)
	  # TODO: Make it so if you pass an invalid apparel name you get a coherent error message. (Do that in PBApparel)
      code = "getID(PBApparel{layer},{apparel})"
      apparel_piece = eval(code)
    end

    return apparel_piece
  end

  # Created this so the first pbStoreApparel can call this and make it uncrashable
  def pbStoreApparel(layer, apparel_piece, color="Default")
	begin
	  pbStoreApparel_safe(layer, apparel_piece, color)
	rescue
	  echo "Error: Couldn't add apparel piece: " + layer + "-" + apparel_piece.to_s + "-" + color + "\n"
	end
  end
  
  def pbStoreApparel_safe(layer, apparel_piece, color="Default")
    apparel_piece = convertToApparelId(layer, apparel_piece)

    # Check if the apparel ID is valid.
    if !apparel_piece || apparel_piece<1
      raise ArgumentError.new(_INTL("The apparel number is invalid."))
      return false
    end

    # Check if the given color is valid.
    if !pbGetApparelColors(layer, apparel_piece).include?(color)
      raise ArgumentError.new(_INTL("The color for the given apparel is invalid."))
      return false
    end

    # Check if the apparel is already being stored
    if pbHasApparel?(layer, apparel_piece, color)
      return false # False means nothing was added
    else
      # Add the layer and return true for successfully adding it
      @apparel[layer].push(apparel_piece.to_s + "-" + color)

      # Additionally add it to the swimsuit apparel list if possible
      #if pbCanSwimWithApparel?(apparel_piece)
      #  @swimsuit_apparel[layer].push(apparel_piece.to_s + color)
      #end

      return true
    end

  end

  def pbHasApparel?(layer, apparel_piece, color="Default")
    apparel_piece = convertToApparelId(layer, apparel_piece)
    return @apparel[layer].include?(apparel_piece.to_s + "-" + color)
  end

end
