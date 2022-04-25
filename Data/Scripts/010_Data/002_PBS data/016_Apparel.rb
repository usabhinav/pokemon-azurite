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
  
	class ApparelBaseModel
		attr_reader :id # Constant? TODO: Should probably match file name.
		attr_reader :id_number 
    attr_reader :id_unique # Another ID that is unique for every apparel item regardless of layer .
                           # (but not color, which is a bit misleading).
                           # Can be used to store and retrieve e.g. messages. 
                           # Can be used any time it is impossible or inconvenient to use
                           # 'layer' + 'id_number' or 'id' as identification.
		attr_reader :real_name
		#attr_reader :real_name_plural # Probably not needed?
   
    include InstanceMethods
    
    def initialize(hash)
      @id                 = hash[:id]
      @id_number          = hash[:id_number]   || -1
      @id_unique          = hash[:id_unique]   || -1
      @real_name          = hash[:name]        || "Unnamed"
    end

    def name
      return real_name
    end
    
    def description
      return real_description
    end

    # Helper method used only by the compiler to complete class specific creation of an apparel hash.
    # Needs to be re-implemented/extended for every class that deviates from its superclass in terms of data.
    def self.completeHash(apparel_hash, line)
      apparel_hash[:name] = line[2]
    end
    
    # This is a class level instance variable and not a class variable? That's pretty neat.
    class << self
      attr_accessor :maxApparelID
    end

	end
	class ApparelSpecialModel < ApparelBaseModel
  
		attr_reader :price
		attr_reader :real_colors
		attr_reader :real_description
    
    def initialize(hash)
      super(hash)
      @price              = hash[:price]       || 0
      @real_colors        = hash[:colors]      || "Default"
      @real_description   = hash[:description] || "This is an apparel piece."
    end
    
    def colors
      return @real_colors
    end
    
    def self.completeHash(apparel_hash, line)
      super(apparel_hash, line)
      apparel_hash[:price] = line[3]
      apparel_hash[:colors] = line[4]
      apparel_hash[:description] = line[5]
    end
    
	end
	class ApparelRegularModel < ApparelSpecialModel

		attr_reader :type_id
		attr_reader :class_id
		attr_reader :swimsuit # TRUE - Can be worn in water. FALSE - Cannot be worn in water.
		attr_reader :conflicts
		attr_reader :variants

    def initialize(hash)
      super(hash)
      @type_id            = hash[:type_id]     || 0 # 0 Means no type got assigned to this apparel piece.
      @class_id           = hash[:class_id]    || 0 # 0 Means no class got assigned to this apparel piece.
      @swimsuit           = hash[:swimsuit]    # || true DO not do this for boolean values.
      @conflicts          = hash[:conflicts]   || []
      @variants           = hash[:variants]    || []
      #echoln "NAME " + @real_name + "VARIANTS: " + @variants.to_s
      #echoln self.conflicts.class.to_s
    end
    
    def self.completeHash(apparel_hash, line)
      super(apparel_hash, line)
      apparel_hash[:type_id] = line[6]
      apparel_hash[:class_id] = line[7]
      apparel_hash[:swimsuit] = line[8]
      #echoln "SWIMSUIT VALUE: " + line[8].to_s
      apparel_hash[:conflicts] = line[9]      
      apparel_hash[:variants] = line[10]
    end

	end
  
      # Current Animation Sheets: Walking, Running, Bicycle, Surfing, Diving.
    LAYER_NAMES = ["Base", "Socks", "Legs", "Shoes", "Torso", "LowerFace", 
    "UpperFace", "Hair", "Hat", "Eyes"]
  
  class ApparelBase < ApparelBaseModel
    extend ClassMethods
    #include ApparelBaseModel
    DATA_FILENAME = "base.dat"
    LAYER = "Base"
    DATA = {}
   
    
  end
  class ApparelSocks < ApparelRegularModel
    extend ClassMethods
    DATA_FILENAME = "socks.dat"
    LAYER = "Socks"
    DATA = {}
  end
  class ApparelLegs < ApparelRegularModel
    extend ClassMethods
    DATA_FILENAME = "legs.dat"
    LAYER = "Legs"
    DATA = {}
  end
  class ApparelShoes < ApparelRegularModel
    extend ClassMethods
    DATA_FILENAME = "shoes.dat"
    LAYER = "Shoes"
    DATA = {} 
  end
  class ApparelTorso < ApparelRegularModel
    extend ClassMethods
    DATA_FILENAME = "torso.dat"
    LAYER = "Torso"
    DATA = {}
  end
  class ApparelLowerFace < ApparelRegularModel
    extend ClassMethods
    DATA_FILENAME = "lowerface.dat"
    LAYER = "LowerFace"
    DATA = {}
  end
  class ApparelUpperFace < ApparelRegularModel
    extend ClassMethods
    DATA_FILENAME = "upperface.dat"
    LAYER = "UpperFace"
    DATA = {}
  end
  class ApparelHair < ApparelRegularModel
    extend ClassMethods
    DATA_FILENAME = "hair.dat"
    LAYER = "Hair"
    DATA = {}
  end 
  class ApparelHat < ApparelRegularModel
    extend ClassMethods
    DATA_FILENAME = "hat.dat"
    LAYER = "Hat"
    DATA = {}
  end
  class ApparelEyes < ApparelRegularModel
    extend ClassMethods
    DATA_FILENAME = "eyes.dat"
    LAYER = "Eyes"
    DATA = {}
  end
  class ApparelBike < ApparelSpecialModel
    extend ClassMethods
    DATA_FILENAME = "bike.dat"
    LAYER = "Bike"
    DATA = {}
  end
  class ApparelRod < ApparelSpecialModel
    extend ClassMethods
    DATA_FILENAME = "rod.dat"
    LAYER = "Rod"
    DATA = {}
  end
  
	class ApparelClass < ApparelBaseModel
		extend ClassMethods
    DATA_FILENAME = "class.dat"
    DATA = {}
	end
	class ApparelType < ApparelBaseModel
		extend ClassMethods
    DATA_FILENAME = "type.dat"
    DATA = {}
	end
  
  # Helper module for working with the compiled/deserialized apparel data.
  # Not designed to be save and deserialized but instead to calculate
  # static data on startup (e.g., a different representation of apparel data).
  module Apparel
    
    COLORCSV = 4
    
    ID    = 0
    CONST = 1
    NAME  = 2
    PRICE = 3
    COLORS = 4
    DESC  = 5
    TYPE  = 6
    CLASS = 7
    SWIMSUIT = 8
    CONFLICTS = 9
    VARIANTS = 10
    
    DRYOUTFIT = "Clothing"
    WETOUTFIT = "Swimsuit"
    
    DELIMITER = ";"
    
    # Current Animation Sheets: Walking, Running, Bicycle, Surfing, Diving.
    LAYER_NAMES = ["Base", "Socks", "Legs", "Shoes", "Torso", "LowerFace", 
    "UpperFace", "Hair", "Hat", "Eyes"]

    # Convert LAYER_NAMES to symbols.
    LAYER_NAMES_SYMS = LAYER_NAMES.map { |name| name.to_sym }

    # Collection of all the names for .dat and .txt files that are used.
    PBS_NAMES = ["Base", "Socks", "Legs", "Shoes", "Torso", "LowerFace", 
    "UpperFace", "Hair", "Hat", "Eyes", "Bike", "Rod", "Type", "Class"]
    
    PBS_NAMES_SYMS = PBS_NAMES.map { |name| name.to_sym }
    
    # A hash containing all class names for apparel for easy access with loops.
    @@class_hash = PBS_NAMES.map { |name| [name.to_sym, Object.const_get(self.to_s + name)] }.to_h
    @@inverted_class_hash = @@class_hash.invert
    
    #echoln "CLASS HASH: " + @@class_hash.to_s
    #echoln "ONE CLASS OBJ: " + @@class_hash[:Base]::DATA.to_s
    
    # A one dimensional list containing all apparel items indexed by their unique id.
    @@all_apparel = {}
    
    
    # Should be treated as a constant and only set by the compiler once.
    # Contains a list of all colors that have been found while compiling.
    COLORS = []
    
    # Return class with the corresponding pbs name.
    def self.getClass(layer_name)
      validate layer_name => [String, Symbol]
      # Make sure name is a symbol.
      layer_name = layer_name.to_sym if layer_name.is_a?(String)
      return @@class_hash[layer_name]
    end
  
    # Return apparel object corresponding to its unique id (or its constant).
    def self.get(id)
      id = id.to_sym if id.is_a?(String)
      return @@all_apparel[id]
    end
  
  
    def self.load
      # Load the apparel game data.
      for pbs_name_sym in PBS_NAMES_SYMS
        @@class_hash[pbs_name_sym].load
      end
      
      all_apparel_list = []
      
      # Compute @@all_apparel
      for pbs_name_sym in PBS_NAMES_SYMS
        #echoln "DATA HASH: " + @@class_hash[pbs_name_sym]::DATA.to_s
        
        all_apparel_list.concat( @@class_hash[pbs_name_sym]::DATA.map{ |apparel_id, apparel_obj| [apparel_obj.id_unique, apparel_obj]})
        all_apparel_list.concat( @@class_hash[pbs_name_sym]::DATA.map{ |apparel_id, apparel_obj| [apparel_obj.id, apparel_obj]})

        #echoln "WARNING: Collision of unique_id's for apparel. Expect problems."
        #echo "ALL APPAREL: " + @@class_hash[pbs_name_sym]::DATA.map{ |apparel_id, apparel_obj|  [apparel_obj.id_unique, apparel_obj]}.to_h.to_s #@@all_apparel.to_s
        #echo all_apparel_list.to_h.to_s
        @@all_apparel = all_apparel_list.to_h
        
        echo "ALL_APPAREL: " + @@all_apparel.to_s
      end
    end
    
    def self.icon_filename(item)
      
      return "Graphics/Items/back" if item.nil?
      item_data = self.get(item)
      return "Graphics/Items/000" if item_data.nil?
      
      colors = pbGetApparelColors(item_data.class::LAYER, item_data.id_number)
      
      if item_data.class.superclass == GameData::ApparelRegularModel
        ret = "Graphics/Characters/Apparel/TrainerID/" + item_data.class::LAYER + "/" + colors[0] + "/" + item_data.class::LAYER + item_data.id_number.to_s + ".png"
      else
        ret = "Graphics/Characters/Apparel/" + item_data.class::LAYER + "/" + item_data.class::LAYER + item_data.id_number.to_s + ".png"
      end
      #echoln "PATH STRING: " + ret
      return ret
    end
    
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


=end

def pbGetApparelName(layer, apparelId)
  #echo "Inspect: " + $ApparelData.inspect + "\n"
  #return $ApparelData[layer][apparelId][CSVCONST::APPARELNAME]
  return GameData::Apparel.getClass(layer).get(apparelId).real_name
end

def pbGetApparelDesc(layer, apparelId)
  #return $ApparelData[layer][apparelId][CSVCONST::APPARELDESC]
  return GameData::Apparel.getClass(layer).get(apparelId).real_description
end

def pbGetApparelConflicts(layer, apparelId)
  if(apparelId == 0)
    echoln "WARNING: Calling pbGetApparelConflicts with ID of 0."
    return []
  end
  
  conflicts = GameData::Apparel.getClass(layer).get(apparelId).conflicts
  
  #echoln "GameData::Apparel.getClass(layer).get(apparelID) = " + GameData::Apparel.getClass(layer).get(apparelId).to_s
  if conflicts != nil && conflicts != []
    echoln "CONFLICTS CLASS: " + GameData::Apparel.getClass(layer).get(apparelId).conflicts.class.to_s
    echoln "CONFLICTS: " + GameData::Apparel.getClass(layer).get(apparelId).conflicts.to_s
    echoln "CONFLICTS SPLIT: " + conflicts.split(GameData::Apparel::DELIMITER).to_s

    return conflicts.split(GameData::Apparel::DELIMITER)
  else
    return []
  end
end

def pbGetApparelColors(layer, apparelId)
  #echo $ApparelData.inspect
  #colors = $ApparelData[layer][apparelId][CSVCONST::APPARELCOLORS]
  colors = GameData::Apparel.getClass(layer).get(apparelId).real_colors
  if colors != nil && colors != ""
    return colors.split(GameData::Apparel::DELIMITER)
  else
    return ["Default"]
  end
end

def pbCanSwimWith(layer, apparelId)
  #return $ApparelData[layer][apparelId][CSVCONST::APPARELSWIMSUIT]
  return GameData::Apparel.getClass(layer).get(apparelId).swimsuit
end

def pbCanPlayerSwim?
  
  #echo "Leg occupation: " + $Trainer.outfitstate.occupiedBy(CSVCONST::WETOUTFIT, "Legs")
  #echo "Torso occupation: " + $Trainer.outfitstate.occupiedBy(CSVCONST::WETOUTFIT, "Legs")

  
  # Check if the leg layer is occupied
  if $Trainer.outfitstate.occupiedBy(GameData::Apparel::WETOUTFIT, "Legs") != ""
    
    # Only legs have to be occupied for male trainers
    if $Trainer.outfitstate.gender == "Male"
      return true
    else
      
      # If trainer is not male, check if torso layer is also occupied
      if $Trainer.outfitstate.occupiedBy(GameData::Apparel::WETOUTFIT, "Torso") != ""
        return true
      else
        return false
      end
    end
  end
end

def pbGetApparelVariants(layer, apparelId)
  
  # The index 0 corresponds to this layer being empty, so there are no variants for it.
  # Additionally, only regular apparel layers have variants.
  if apparelId == 0 || GameData::Apparel.getClass(layer).superclass != GameData::ApparelRegularModel
    return []
  end
  
  variants = GameData::Apparel.getClass(layer).get(apparelId).variants
  #echoln "VARIANTS: " + variants.to_s
  
  if variants != nil && variants != []
    return variants.split(GameData::Apparel::DELIMITER)
  else
    return []
  end
  
end

# Checks if a layer can have conflicts with other layers.
def pbHasApparelConflicts?(layer)
  apparel_class = GameData::Apparel.getClass(layer)
  return apparel_class.superclass == GameData::ApparelRegularModel
end

def pbGetMaxApparelID(layer)
  return GameData::Apparel.getClass(layer).maxApparelID
end
