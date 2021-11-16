module GameData
  class ApparelLayer 
    
    extend ClassMethods
    include InstanceMethods
    
    
  end
	class ApparelBase
		attr_reader :id # Constant? TODO: Should probably match file name.
		attr_reader :id_number 
		attr_reader :real_name
		#attr_reader :real_name_plural # Probably not needed?
    
    DATA = {}
    DATA_FILENAME = ""
    
    extend ClassMethods
    include InstanceMethods
    
    def initialize(hash, data_filename)
      @id                 = hash[:id]
      @id_number          = hash[:id_number]   || -1
      @real_name          = hash[:name]        || "Unnamed"
      self::DATA_FILENAME = data_filename
    end

	end
	class ApparelSpecial
		include ApparelBase
	 
		attr_reader :price
		attr_reader :real_color
		attr_reader :real_description
    
    def initialize(hash, data_filename)
      super(hash, data_filename)
      @price              = hash[:price]       || 0
      @real_color         = hash[:color]       || "Default"
      @real_description   = hash[:description] || ""
    end
    
	end
	class ApparelRegular
		include ApparelSpecial

		attr_reader :type_id
		attr_reader :class_id
		attr_reader :swimsuit # TRUE - Can be worn in water. FALSE - Cannot be worn in water.
		attr_reader :conflicts
		attr_reader :variants

    def initialize(hash, data_filename)
      super(hash, data_filename)
      @type_id            = hash[:type_id]     || 0 # 0 Means no type got assigned to this apparel piece.
      @class_id           = hash[:class_id]    || 0 # 0 Means no class got assigned to this apparel piece.
      @swimsuit           = hash[:swimsuit]    || true
      @conflicts          = hash[:conflicts]   || []
      @variants           = hash[:variants]    || []
    end

	end
	class ApparelClass
		include ApparelBase
		
		attr_reader :layer_list
	end
	class ApparelType
		include ApparelBase
		
		attr_reader :layer
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