module GameData
  class Ribbon
    attr_reader :id
    attr_reader :real_name
    attr_reader :icon_position   # Where this ribbon's graphic is within ribbons.png
    attr_reader :rarity
    attr_reader :small_description
    attr_reader :real_description
    attr_reader :flags

    DATA = {}
    DATA_FILENAME = "ribbons.dat"

    SCHEMA = {
      "Name"         => [:name,          "s"],
      "IconPosition" => [:icon_position, "u"],
      "Rarity"       => [:rarity,        "s"],
      "SmallDescription"  => [:small_description, "q"],
      "Description"  => [:description,   "q"],
      "Flags"        => [:flags,         "*s"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:name]          || "Unnamed"
      @icon_position    = hash[:icon_position] || 0
      @rarity           = hash[:rarity]        || "???"
      @small_description = hash[:small_description] || "???"
      @real_description = hash[:description]   || "???"
      @flags            = hash[:flags]         || []
    end

    # @return [String] the translated name of this ribbon
    def name
      return pbGetMessageFromHash(MessageTypes::RibbonNames, @real_name)
    end

    # @return [String] the translated rarity of this ribbon
    def rarity
      return pbGetMessageFromHash(MessageTypes::RibbonRarities, @rarity)
    end

    # @return [String] the translated small description of this ribbon
    def small_description
      return pbGetMessageFromHash(MessageTypes::RibbonSmallDescriptions, @small_description)
    end

    # @return [String] the translated description of this ribbon
    def description
      return pbGetMessageFromHash(MessageTypes::RibbonDescriptions, @real_description)
    end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end
  end
end
