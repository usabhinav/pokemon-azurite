module GameData
  class Habitat
    attr_reader :id
    attr_reader :real_name

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id        = hash[:id]
      @real_name = hash[:name] || "Unnamed"
    end

    # @return [String] the translated name of this habitat
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::Habitat.register({
  :id   => :None,
  :name => _INTL("None")
})

GameData::Habitat.register({
  :id   => :Grassland,
  :name => _INTL("Grassland")
})

GameData::Habitat.register({
  :id   => :Forest,
  :name => _INTL("Forest")
})

GameData::Habitat.register({
  :id   => :WatersEdge,
  :name => _INTL("Water's Edge")
})

GameData::Habitat.register({
  :id   => :Sea,
  :name => _INTL("Sea")
})

GameData::Habitat.register({
  :id   => :Cave,
  :name => _INTL("Cave")
})

GameData::Habitat.register({
  :id   => :Mountain,
  :name => _INTL("Mountain")
})

GameData::Habitat.register({
  :id   => :RoughTerrain,
  :name => _INTL("Rough Terrain")
})

GameData::Habitat.register({
  :id   => :Urban,
  :name => _INTL("Urban")
})

GameData::Habitat.register({
  :id   => :Rare,
  :name => _INTL("Rare")
})

GameData::Habitat.register({
  :id   => :Cosmos,
  :name => _INTL("Cosmos")
})

GameData::Habitat.register({
  :id   => :Jungle,
  :name => _INTL("Jungle")
})

GameData::Habitat.register({
  :id   => :Desert,
  :name => _INTL("Desert")
})

GameData::Habitat.register({
  :id   => :Skies,
  :name => _INTL("Skies")
})

GameData::Habitat.register({
  :id   => :Underwater,
  :name => _INTL("Underwater")
})

GameData::Habitat.register({
  :id   => :Tundra,
  :name => _INTL("Tundra")
})

GameData::Habitat.register({
  :id   => :Graveyard,
  :name => _INTL("Graveyard")
})

GameData::Habitat.register({
  :id   => :Volcano,
  :name => _INTL("Volcano")
})