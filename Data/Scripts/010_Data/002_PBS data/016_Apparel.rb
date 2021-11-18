module GameData

=begin
  module Apparel
    
    # The core location of the outfit files.
    APPAREL_DIR  = "Graphics/Characters/Apparel/"

    # Current Animation Sheets: Walking, Running, Bicycle, Surfing, Diving.
    LAYER_NAMES = ["Base", "Socks", "Legs", "Shoes", "Torso", "LowerFace", 
    "UpperFace", "Hair", "Hat", "Eyes"]

    # Collection of all the names for .dat and .txt files that are used.
    PBS_NAMES = ["Base", "Socks", "Legs", "Shoes", "Torso", "LowerFace", 
    "UpperFace", "Hair", "Hat", "Eyes", "Bike", "Rod", "Type", "Class"]

    # Defines which layers will definitely be changed when entering water, but does
    # not change layers if the part defined as wearable in water.
    SWIMSUIT_LAYERS = ["Legs", "Torso"]

    # Defines a seperate set of layers for the mugshot.
    LAYER_NAMES_MUGSHOT = ["Base", "Torso", "Hair", "Hat", "Eyes"]
    
    data_hash = {}
    
    self.setup_apparel
      data_hash = 
    end
    
  end
  Apparel.setup_apparel
=end
  
	module ApparelBaseModel
		attr_reader :id # Constant? TODO: Should probably match file name.
		attr_reader :id_number 
    attr_reader :id_unique # Another ID that is unique for every apparel item regardless of layer.
                           # Can be used to store and retrieve e.g. messages. 
                           # Can be used any time it is impossible or inconvenient to use
                           # 'layer' + 'id_number' or 'id' as identification.
		attr_reader :real_name
		#attr_reader :real_name_plural # Probably not needed?
   
    include InstanceMethods
    
    def initialize(hash)
      @id                 = hash[:id]
      @id_number          = hash[:id_number]   || -1
      @real_name          = hash[:name]        || "Unnamed"
    end

	end
	module ApparelSpecialModel
		include ApparelBaseModel
	 
		attr_reader :price
		attr_reader :real_color
		attr_reader :real_description
    
    def initialize(hash)
      super(hash, )
      @price              = hash[:price]       || 0
      @real_color         = hash[:color]       || "Default"
      @real_description   = hash[:description] || ""
    end
    
	end
	module ApparelRegularModel
		include ApparelSpecialModel

		attr_reader :type_id
		attr_reader :class_id
		attr_reader :swimsuit # TRUE - Can be worn in water. FALSE - Cannot be worn in water.
		attr_reader :conflicts
		attr_reader :variants

    def initialize(hash)
      super(hash)
      @type_id            = hash[:type_id]     || 0 # 0 Means no type got assigned to this apparel piece.
      @class_id           = hash[:class_id]    || 0 # 0 Means no class got assigned to this apparel piece.
      @swimsuit           = hash[:swimsuit]    || true
      @conflicts          = hash[:conflicts]   || []
      @variants           = hash[:variants]    || []
    end

	end
  
      # Current Animation Sheets: Walking, Running, Bicycle, Surfing, Diving.
    LAYER_NAMES = ["Base", "Socks", "Legs", "Shoes", "Torso", "LowerFace", 
    "UpperFace", "Hair", "Hat", "Eyes"]
  
  class ApparelBase
    extend ClassMethods
    include ApparelBaseModel
    DATA = {}
  end
  class ApparelSocks
    extend ClassMethods
    include ApparelRegularModel
    DATA = {}
  end
  class ApparelLegs
    extend ClassMethods
    include ApparelRegularModel
    DATA = {}
  end
  class ApparelShoes
    extend ClassMethods
    include ApparelRegularModel
    DATA = {}
  end
  class ApparelTorso
    extend ClassMethods
    include ApparelRegularModel
    DATA = {}
  end
  class ApparelLowerFace
    extend ClassMethods
    include ApparelRegularModel
    DATA = {}
  end
  class ApparelUpperFace
    extend ClassMethods
    include ApparelRegularModel
    DATA = {}
  end
  class ApparelHair
    extend ClassMethods
    include ApparelRegularModel
    DATA = {}
  end
  class ApparelHat
    extend ClassMethods
    include ApparelRegularModel
    DATA = {}
  end
  class ApparelEyes
    extend ClassMethods
    include ApparelRegularModel
    DATA = {}
  end
  class ApparelBike
    extend ClassMethods
    include ApparelSpecialModel
    DATA = {}
  end
  class ApparelRod
    extend ClassMethods
    include ApparelSpecialModel
    DATA = {}
  end
  
	class ApparelClass
		extend ClassMethods
    include ApparelBaseModel
    DATA = {}
	end
	class ApparelType
		extend ClassMethods
    include ApparelBaseModel
    DATA = {}
	end
end


=begin 
module CSVCONST
  
  # Constants that dictate the order of data inside the recrods written to .dat
  # files (not fully corresponding to the records inside .txt files, as the
  # constant is intentionally left out of the .dat file)
  APPARELID    = 0
  APPARELCONST = 1
  APPARELNAME  = 2
  APPARELPRICE = 3
  APPARELCOLORS = 4
  APPARELDESC  = 5
  APPARELTYPE  = 6
  APPARELCLASS = 7
  APPARELSWIMSUIT = 8
  APPARELCONFLICTS = 9
  APPARELVARIANTS = 10
  
  DRYOUTFIT = 0
  WETOUTFIT = 1
  
end

$APPAREL_DELIMITER = ";"

def pbGetApparelName(layer, apparelId)
  echo "Inspect: " + $ApparelData.inspect + "\n"
  return $ApparelData[layer][apparelId][CSVCONST::APPARELNAME]
end

def pbGetApparelDesc(layer, apparelId)
  return $ApparelData[layer][apparelId][CSVCONST::APPARELDESC]
end

def pbGetApparelConflicts(layer, apparelId)
  conflicts = $ApparelData[layer][apparelId][CSVCONST::APPARELCONFLICTS]
  if conflicts != nil
    return conflicts.split($APPAREL_DELIMITER)
  else
    return []
  end
end

def pbGetApparelColors(layer, apparelId)
  #echo $ApparelData.inspect
  colors = $ApparelData[layer][apparelId][CSVCONST::APPARELCOLORS]
  if colors != nil && colors != ""
    return colors.split($APPAREL_DELIMITER)
  else
    return ["Default"]
  end
end

def pbCanSwimWithApparel?(layer, apparelId)
  return $ApparelData[layer][apparelId][CSVCONST::APPARELSWIMSUIT]
end

def pbCanPlayerSwim?
  
  #echo "Leg occupation: " + $Trainer.outfitstate.occupiedBy(CSVCONST::WETOUTFIT, "Legs")
  #echo "Torso occupation: " + $Trainer.outfitstate.occupiedBy(CSVCONST::WETOUTFIT, "Legs")

  
  # Check if the leg layer is occupied
  if $Trainer.outfitstate.occupiedBy(CSVCONST::WETOUTFIT, "Legs") != ""
    
    # Only legs have to be occupied for male trainers
    if $Trainer.outfitstate.gender == "Male"
      return true
    else
      
      # If trainer is not male, check if torso layer is also occupied
      if $Trainer.outfitstate.occupiedBy(CSVCONST::WETOUTFIT, "Torso") != ""
        return true
      else
        return false
      end
    end
  end
end

def pbGetApparelVariants(layer, apparelId)
  if apparelId = 0
    return []
  end
  
  variants = $ApparelData[layer][apparelId][CSVCONST::APPARELVARIANTS]
  if variants != nil
    return variants.split($APPAREL_DELIMITER)
  else
    return []
  end
  
end
=end