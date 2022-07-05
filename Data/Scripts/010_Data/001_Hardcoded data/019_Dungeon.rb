module GameData
  class Dungeon
    attr_reader :id
    attr_reader :real_name
    attr_reader :is_initial
    attr_reader :reward_list
    attr_reader :steps
    attr_reader :gummi_reward
    attr_reader :master_reward_pool
    attr_reader :useful_reward_pool
    attr_reader :valuable_reward_pool
    attr_reader :unlocked
    attr_reader :can_start
  
    DATA = {}
  
    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end
  
    def initialize(hash)
      @id                   = hash[:id]
      @real_name            = hash[:name]                 || "Unnamed"
      @is_initial           = hash[:is_initial]           || false
      @reward_list          = hash[:reward_list]
      @steps                = hash[:steps]
      @gummi_reward         = hash[:gummi_reward]
      @master_reward_pool   = hash[:master_reward_pool]
      @useful_reward_pool   = hash[:useful_reward_pool]
      @valuable_reward_pool = hash[:valuable_reward_pool]
      @unlocked             = hash[:unlocked]
      @can_start            = hash[:can_start]
    end

    # @return [String] the translated name of this dungeon
    def name
      return _INTL(@real_name)
    end

    def unlocked?(guild, show_messages = true)
      return (@unlocked) ? @unlocked.call(guild, show_messages) : false
    end

    def can_start?(guild, show_messages = true)
      return (@can_start) ? @can_start.call(guild, show_messages) : false
    end
  end
end

#===============================================================================

GameData::Dungeon.register({
  :id                => :TinyWoods,
  :name              => _INTL("Tiny Woods"),
  :is_initial        => true,
  # TODO: Change back to this list when gummi items are implemented
  # :reward_list       => [:HERACRONITE, 1, :RARECANDY, 1, :GREATBALL, 10, :WONDERGUMMI, 2],
  :reward_list       => [:HERACRONITE, 1, :RARECANDY, 1, :GREATBALL, 10, :GREATBALL, 2],
  :steps             => 10,
  :gummi_reward      => 20,
  :unlocked          => proc { |guild, show_messages|
    next true
  },
  :can_start         => proc { |guild, show_messages|
    next true
  }
})

GameData::Dungeon.register({
  :id                => :AmpPlains,
  :name              => _INTL("Amp Plains"),
  :is_initial        => true,
  :reward_list       => [:MANECTITE, 1, :BIGNUGGET, 1, :MOONSTONE, 1, :SUPERGUMMI, 1],
  :gummi_reward      => 35,
  :unlocked          => proc { |guild, show_messages|
    if !guild.completedDungeon?(:TinyWoods)
      pbMessage(_INTL("You must clear Tiny Woods first!")) if show_messages
      next false
    end
    next true
  },
  :can_start         => proc { |guild, show_messages|
    if !guild.guildMaster.hasAbility?(:LIGHTNINGROD)
      pbMessage(_INTL("Your Guild Master must have the ability Lightning Rod!")) if show_messages
      next false
    end
    next true
  }
})

GameData::Dungeon.register({
  :id                => :GreatGlacier,
  :name              => _INTL("Great Glacier"),
  :is_initial        => true,
  :reward_list       => [:GLALITITE, 1, :COMETSHARD, 1, :ULTRABALL, 20, :SUPERGUMMI, 2],
  :gummi_reward      => 50,
  :unlocked          => proc { |guild, show_messages|
    if !guild.completedDungeon?(:AmpPlains)
      pbMessage(_INTL("You must clear Amp Plains first!")) if show_messages
      next false
    end
    next true
  },
  :can_start         => proc { |guild, show_messages|
    firetypes = 0
    firetypes += 1 if guild.guildMaster.hasType?(:FIRE)
    firetypes += 1 if guild.guildKeeper.hasType?(:FIRE)
    guild.guildMembers.each {|poke|
      firetypes += 1 if poke.hasType?(:FIRE)
    }
    if firetypes < 2
      pbMessage(_INTL("You must have at least 2 Fire-type Pokemon in the guild!")) if show_messages
      next false
    end
    next true
  }
})

GameData::Dungeon.register({
  :id                => :PrehistoricRuins,
  :name              => _INTL("Prehistoric Ruins"),
  :is_initial        => true,
  :reward_list       => [:AERODACTYLITE, 1, :COMETSHARD, 2, :BIGNUGGET, 3, :NUGGET, 4],
  :gummi_reward      => 75,
  :unlocked          => proc { |guild, show_messages|
    if !guild.completedDungeon?(:GreatGlacier)
      pbMessage(_INTL("You must clear Great Glacier first!")) if show_messages
      next false
    end
    next true
  },
  :can_start         => proc { |guild, show_messages|
    if guild.guildMaster.level < 40
      pbMessage(_INTL("Your Guild Master must be at least level 40!")) if show_messages
      next false
    end
    less_than_40 = false
    guild.guildMembers.each {|poke|
      if poke.level < 40
        less_than_40 = true
        break
      end
    }
    if less_than_40
      pbMessage(_INTL("All of your guild members must be at least level 40!")) if show_messages
      next false
    end
    next true
  }
})

GameData::Dungeon.register({
  :id                => :HiddenLand,
  :name              => _INTL("Hidden Land"),
  :is_initial        => true,
  :reward_list       => [:DUSKNITE, 1, :COMETSHARD, 5, "GEMS", 3, :SUPERGUMMI, 4],
  :gummi_reward      => 111,
  :unlocked          => proc { |guild, show_messages|
    if !guild.completedDungeon?(:PrehistoricRuins)
      pbMessage(_INTL("You must clear Prehistoric Ruins first!")) if show_messages
      next false
    end
    next true
  },
  :can_start         => proc { |guild, show_messages|
    if !guild.guildMaster.isSpecies?(:LAPRAS) && !guild.guildMaster.isSpecies?(:WIGGLYTUFF)
      pbMessage(_INTL("Your Guild Master must be a Lapras or Wigglytuff!")) if show_messages
      next false
    end
    next true
  }
})

GameData::Dungeon.register({
  :id                    => :LittleCave,
  :name                  => _INTL("Little Cave"),
  :steps                 => 10,
  :gummi_reward          => 50,
  :master_reward_pool    => [ [:RARECANDY, 3, 10, :FULLHEAL, 5, 15],
                              [:ULTRABALL, 2, 4],
                              [:MASTERBALL, 1, 1] ],
  :useful_reward_pool    => [ [:POTION, 2, 5],
                              [:SUPERPOTION, 1, 4],
                              [:HYPERPOTION, 1, 2] ],
  :valuable_reward_pool  => [ [:NUGGET, 2, 4],
                              [:EVERSTONE, 1, 1],
                              [:FULLRESTORE, 1, 2] ],
  :unlocked              => proc { |guild, show_messages|
    next true
  },
  :can_start             => proc { |guild, show_messages|
    next true
  }
})

GameData::Dungeon.register({
  :id                    => :GravelCavern,
  :name                  => _INTL("Gravel Cavern"),
  :gummi_reward          => 60,
  :master_reward_pool    => [ [],
                              [],
                              [] ],
  :useful_reward_pool    => [ [],
                              [],
                              [] ],
  :valuable_reward_pool  => [ [],
                              [],
                              [] ],
  :unlocked              => proc { |guild, show_messages|
    if !guild.completedDungeon?(:LittleCave)
      pbMessage(_INTL("You must clear Little Cave first!")) if show_messages
      next false
    end
    next true
  },
  :can_start             => proc { |guild, show_messages|
    above80attack = false
    above80attack = true if guild.guildMaster.attack > 80
    guild.guildMembers.each {|poke|
      above80attack = true if poke.attack > 80
    }
    if !above80attack
      pbMessage(_INTL("You must have a guild Pokemon with at least 80 attack!")) if show_messages
      next false
    end
    next true
  }
})

GameData::Dungeon.register({
  :id                    => :StickySwamps,
  :name                  => _INTL("Sticky Swamps"),
  :gummi_reward          => 75,
  :master_reward_pool    => [ [],
                              [],
                              [] ],
  :useful_reward_pool    => [ [],
                              [],
                              [] ],
  :valuable_reward_pool  => [ [],
                              [],
                              [] ],
  :unlocked              => proc { |guild, show_messages|
    if !guild.completedDungeon?(:LittleCave)
      pbMessage(_INTL("You must clear Little Cave first!")) if show_messages
      next false
    end
    # TODO: Add check for having reached Heliconia town
    next true
  },
  :can_start             => proc { |guild, show_messages|
    # TODO: Add check for slashing moves
    next true
  }
})

GameData::Dungeon.register({
  :id                    => :StaticWildlands,
  :name                  => _INTL("Static Wildlands"),
  :gummi_reward          => 100,
  :master_reward_pool    => [ [],
                              [],
                              [] ],
  :useful_reward_pool    => [ [],
                              [],
                              [] ],
  :valuable_reward_pool  => [ [],
                              [],
                              [] ],
  :unlocked              => proc { |guild, show_messages|
    if !guild.completedDungeon?(:LittleCave)
      pbMessage(_INTL("You must clear Little Cave first!")) if show_messages
      next false
    end
    # TODO: Add check for having obtained 10+ Electric-type Pokemon
    next true
  },
  :can_start             => proc { |guild, show_messages|
    hasgroundtype = false
    hasgroundtype = true if guild.guildMaster.hasType?(:GROUND)
    guild.guildMembers.each {|poke|
      hasgroundtype = true if poke.hasType?(:GROUND)
    }
    if !hasgroundtype
      pbMessage(_INTL("You must have at least one Ground-type guild member!")) if show_messages
      next false
    end
    next true
  }
})
