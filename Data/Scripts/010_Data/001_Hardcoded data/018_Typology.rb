module GameData
  class Typology
    attr_reader :id
    attr_reader :real_name
    attr_reader :damage_boost_type
  
    DATA = {}
  
    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end
  
    def initialize(hash)
      @id                = hash[:id]
      @real_name         = hash[:name]              || "Unnamed"
      @damage_boost_type = hash[:damage_boost_type]
    end

    # @return [String] the translated name of this typology
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::Typology.register({
  :id                => :BASIC,
  :name              => _INTL("Basic"),
  :damage_boost_type => :NORMAL
})

GameData::Typology.register({
  :id                => :POWER,
  :name              => _INTL("Power"),
  :damage_boost_type => :FIGHTING
})

GameData::Typology.register({
  :id                => :WIND,
  :name              => _INTL("Wind"),
  :damage_boost_type => :FLYING
})

GameData::Typology.register({
  :id                => :TOXIC,
  :name              => _INTL("Toxic"),
  :damage_boost_type => :POISON
})

GameData::Typology.register({
  :id                => :EARTH,
  :name              => _INTL("Earth"),
  :damage_boost_type => :GROUND
})

GameData::Typology.register({
  :id                => :STONE,
  :name              => _INTL("Stone"),
  :damage_boost_type => :ROCK
})

GameData::Typology.register({
  :id                => :INSECT,
  :name              => _INTL("Insect"),
  :damage_boost_type => :BUG
})

GameData::Typology.register({
  :id                => :HAUNTED,
  :name              => _INTL("Haunted"),
  :damage_boost_type => :GHOST
})

GameData::Typology.register({
  :id                => :METAL,
  :name              => _INTL("Metal"),
  :damage_boost_type => :STEEL
})

GameData::Typology.register({
  :id                => :CINDER,
  :name              => _INTL("Cinder"),
  :damage_boost_type => :FIRE
})

GameData::Typology.register({
  :id                => :HYDRO,
  :name              => _INTL("Hydro"),
  :damage_boost_type => :WATER
})

GameData::Typology.register({
  :id                => :SPROUT,
  :name              => _INTL("Sprout"),
  :damage_boost_type => :GRASS
})

GameData::Typology.register({
  :id                => :LIGHTNING,
  :name              => _INTL("Lightning"),
  :damage_boost_type => :ELECTRIC
})

GameData::Typology.register({
  :id                => :WISDOM,
  :name              => _INTL("Wisdom"),
  :damage_boost_type => :PSYCHIC
})

GameData::Typology.register({
  :id                => :CHILL,
  :name              => _INTL("Chill"),
  :damage_boost_type => :ICE
})

GameData::Typology.register({
  :id                => :SCALE,
  :name              => _INTL("Scale"),
  :damage_boost_type => :DRAGON
})

GameData::Typology.register({
  :id                => :SINISTER,
  :name              => _INTL("Sinister"),
  :damage_boost_type => :DARK
})

GameData::Typology.register({
  :id                => :PIXIE,
  :name              => _INTL("Pixie"),
  :damage_boost_type => :FAIRY
})

GameData::Typology.register({
  :id                => :ILLUSION,
  :name              => _INTL("Illusion"),
  :damage_boost_type => :MYSTIC
})

GameData::Typology.register({
  :id                => :NOISE,
  :name              => _INTL("Noise"),
  :damage_boost_type => :SOUND
})

GameData::Typology.register({
  :id                => :SHINE,
  :name              => _INTL("Shine"),
  :damage_boost_type => :LIGHT
})

GameData::Typology.register({
  :id                => :GALAXY,
  :name              => _INTL("Galaxy"),
  :damage_boost_type => :COSMIC
})

GameData::Typology.register({
  :id                => :PRISM,
  :name              => _INTL("Prism"),
  :damage_boost_type => :CRYSTAL
})