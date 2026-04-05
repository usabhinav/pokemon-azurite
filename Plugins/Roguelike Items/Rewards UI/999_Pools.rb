#-----------------------------------------------------------------------------
# Base pools (always shown)
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :base_pools,
  :common    => [
    :POTION, :POKEBALL, :ORANBERRY,
    # Added
    :NUGGET
  ],
  :rare      => [
    :SUPERPOTION, :GREATBALL, :REVIVE, :SITRUSBERRY, :LUMBERRY, :FOCUSBAND,
    :LANSATBERRY, :STARFBERRY,
    # Added
    :BIGNUGGET, :RISCIBERRY
  ],
  :epic      => [
    :HYPERPOTION, :ULTRABALL, :FULLHEAL, :PPUP, :EJECTBUTTON, :POWERHERB,
    :PROTECTIVEPADS, :SAFETYGOGGLES, :HEAVYDUTYBOOTS, :WEAKNESSPOLICY,
    :EJECTPACK, :REDCARD, :COVERTCLOAK, :LOADEDDICE, :KEEBERRY, :MARANGABERRY,
    :CUSTAPBERRY,
    # Added
    :SYNCHROPENDANT, :SPEEDINGTICKET, :AWFULCOLLAR, :CRUSHINGHAMMER, :CRYSTALHAMMER,
    :DIZZYSPECS, :FRIENDLYCOLLAR, :GREATSHIELD, :IRONSHELL, :PECULIARMIRROR,
    :QUICKSWITCH, :REVENGEBELT, :SHODDYSLINGSHOT, :HEALTHYSPONGE, :REVERSALHERB,
    :CRACKEDMULTIPLATE, :WEIRDTRINKET, :COUNTERFORMAMULET, :ADRENALINERING,
    :RIDDLESBOOK, :BERSERKERBRACELET, :RETREATORDER, :UMBRELLA, :HAILGLOBE,
    :BERSERKGENE, :REVERSALCARD, :EXPERTBALL
  ],
  :legendary => [
    :FULLRESTORE, :RARECANDY, :ABILITYPATCH, :PPMAX, :LIFEORB, :ABILITYSHIELD,
    :CHOICEBAND, :CHOICESPECS, :CHOICESCARF, :ASSAULTVEST, :FOCUSSASH,
    :CLEARAMULET, :MIRRORHERB, :BOOSTERENERGY, :MASTERBALL,
    # Added
    :CHOICESCOPE, :PLATEBODY, :FOCUSBELT
  ]
})

#-----------------------------------------------------------------------------
# Pools if you have Eggs and Baby Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :breeder_pools,
  :condition => proc {
    next true if $player.pokemon_party.any?(&:egg?)
    found = false
    $player.pokemon_party.each do |pkmn|
      found = true if pkmn.species == pkmn.species_data.get_baby_species
    end
    next found
  },
  :common    => [:EVERSTONE],
  :rare      => [:SOOTHEBELL],
  :epic      => [:DESTINYKNOT]
})

#-----------------------------------------------------------------------------
# Pools if you have Normal type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :normal_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:NORMAL) },
  :common    => [:SILKSCARF],
  :rare      => [:CHOPLEBERRY, :JOYFULGLOBE],
  :epic      => [:TM15, :NORMALTERASHARD],
  :legendary => [:TM68]
})

#-----------------------------------------------------------------------------
# Pools if you have Fire type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :fire_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:FIRE) },
  :common    => [:CHARCOAL],
  :rare      => [:PASSHOBERRY, :RINDOBERRY, :CHARTIBERRY, :FLAMEORB, :FIREREDMEDAL],
  :epic      => [:TM35, :FIRETERASHARD],
  :legendary => [:TM38]
})

#-----------------------------------------------------------------------------
# Pools if you have Water type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :water_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:WATER) },
  :common    => [:MYSTICWATER],
  :rare      => [:WACANBERRY, :RINDOBERRY, :AQUABLUEMEDAL],
  :epic      => [:TM49, :WATERTERASHARD],
  :legendary => [:TM95]
})

#-----------------------------------------------------------------------------
# Pools if you have Grass type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :grass_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:GRASS) },
  :common    => [:MIRACLESEED],
  :rare      => [:OCCABERRY, :YACHEBERRY, :KEBIABERRY, :COBABERRY, :TANGABERRY, :ABSORBBULB, :LEAFGREENMEDAL],
  :epic      => [:BIGROOT, :TM53, :GRASSTERASHARD],
  :legendary => [:TM22]
})

#-----------------------------------------------------------------------------
# Pools if you have Electric type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :electric_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:ELECTRIC) },
  :common    => [:MAGNET],
  :rare      => [:SHUCABERRY, :CELLBATTERY, :INTERCEPTOR, :VOLTYELLOWMEDAL],
  :epic      => [:TM24, :ELECTRICTERASHARD],
  :legendary => [:TM25]
})

#-----------------------------------------------------------------------------
# Pools if you have Ice type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :ice_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:ICE) },
  :common    => [:NEVERMELTICE],
  :rare      => [:OCCABERRY, :CHOPLEBERRY, :CHARTIBERRY, :BABIRIBERRY, :SNOWBALL, :WETICECHARM],
  :epic      => [:TM13, :ICETERASHARD],
  :legendary => [:TM14]
})

#-----------------------------------------------------------------------------
# Pools if you have Fighting type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :fighting_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:FIGHTING) },
  :common    => [:BLACKBELT],
  :rare      => [:COBABERRY, :PAYAPABERRY, :ROSELIBERRY, :EXPERTBELT, :MASTERSBELT],
  :epic      => [:MUSCLEBAND, :PUNCHINGGLOVE, :FIGHTINGTERASHARD],
  :legendary => [:TM52]
})

#-----------------------------------------------------------------------------
# Pools if you have Poison type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :poison_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:POISON) },
  :common    => [:POISONBARB],
  :rare      => [:SHUCABERRY, :PAYAPABERRY, :TOXICORB, :STENCHDOLL],
  :epic      => [:BLACKSLUDGE, :TM06, :POISONTERASHARD],
  :legendary => [:TM36]
})

#-----------------------------------------------------------------------------
# Pools if you have Ground type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :ground_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:GROUND) },
  :common    => [:SOFTSAND],
  :rare      => [:PASSHOBERRY, :RINDOBERRY, :YACHEBERRY, :GROUNDEDBOOTS],
  :epic      => [:TM83, :GROUNDTERASHARD],
  :legendary => [:TM26]
})

#-----------------------------------------------------------------------------
# Pools if you have Flying type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :flying_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:FLYING) },
  :common    => [:SHARPBEAK],
  :rare      => [:WACANBERRY, :YACHEBERRY, :CHARTIBERRY, :AIRBALLOON, :FLYINGVEST],
  :epic      => [:UTILITYUMBRELLA, :TM51, :FLYINGTERASHARD],
  :legendary => [:TM94]
})

#-----------------------------------------------------------------------------
# Pools if you have Psychic type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :psychic_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:PSYCHIC) },
  :common    => [:TWISTEDSPOON],
  :rare      => [:TANGABERRY, :KASIBBERRY, :COLBURBERRY, :WISEGLASSES, :CLEARMINDTIARA],
  :epic      => [:TM04, :PSYCHICTERASHARD],
  :legendary => [:TM29]
})

#-----------------------------------------------------------------------------
# Pools if you have Bug type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :bug_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:BUG) },
  :common    => [:SILVERPOWDER],
  :rare      => [:OCCABERRY, :COBABERRY, :CHARTIBERRY, :LEECHTOOTH],
  :epic      => [:SHEDSHELL, :TM81, :BUGTERASHARD],
  :legendary => [:TM89]
})

#-----------------------------------------------------------------------------
# Pools if you have Rock type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :rock_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:ROCK) },
  :common    => [:HARDSTONE],
  :rare      => [:PASSHOBERRY, :RINDOBERRY, :CHOPLEBERRY, :SHUCABERRY, :BABIRIBERRY, :TM76, :ROUGHROCK],
  :epic      => [:ROCKYHELMET, :ROCKTERASHARD],
  :legendary => [:TM71]
})

#-----------------------------------------------------------------------------
# Pools if you have Ghost type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :ghost_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:GHOST) },
  :common    => [:SPELLTAG],
  :rare      => [:KASIBBERRY, :COLBURBERRY, :RINGTARGET, :PHANTOMMASK],
  :epic      => [:REAPERCLOTH, :GHOSTTERASHARD],
  :legendary => [:TM30]
})

#-----------------------------------------------------------------------------
# Pools if you have Dragon type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :dragon_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:DRAGON) },
  :common    => [:DRAGONFANG],
  :rare      => [:YACHEBERRY, :HABANBERRY, :ROSELIBERRY, :DRAGONHEARTGEM],
  :epic      => [:DRAGONSCALE, :DRAGONTERASHARD],
  :legendary => [:TM59]
})

#-----------------------------------------------------------------------------
# Pools if you have Dark type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :dark_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:DARK) },
  :common    => [:BLACKGLASSES],
  :rare      => [:CHOPLEBERRY, :TANGABERRY, :ROSELIBERRY, :VANTABLACKCLOAK],
  :epic      => [:RAZORCLAW, :BLUNDERPOLICY, :DARKTERASHARD],
  :legendary => [:TM79]
})

#-----------------------------------------------------------------------------
# Pools if you have Steel type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :steel_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:STEEL) },
  :common    => [:METALCOAT],
  :rare      => [:OCCABERRY, :CHOPLEBERRY, :SHUCABERRY, :REFLECTIVEMETAL],
  :epic      => [:IRONBALL, :TM91, :STEELTERASHARD],
  :legendary => [:LEFTOVERS]
})

#-----------------------------------------------------------------------------
# Pools if you have Fairy type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :fairy_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:FAIRY) },
  :common    => [:PIXIEPLATE],
  :rare      => [:KEBIABERRY, :BABIRIBERRY, :PIXIEDUST],
  :epic      => [:TM92, :FAIRYTERASHARD],
  :legendary => [:TM21]
})

#-----------------------------------------------------------------------------
# Pools if you have Mystic type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :mystic_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:MYSTIC) },
  :rare      => [:BIZARREBAND],
})

#-----------------------------------------------------------------------------
# Pools if you have Sound type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :sound_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:SOUND) },
  :rare      => [:AMPLIFIER],
})

#-----------------------------------------------------------------------------
# Pools if you have Light type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :light_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:LIGHT) },
  :rare      => [:HEALINGCROWN],
})

#-----------------------------------------------------------------------------
# Pools if you have Cosmic type Pokemon
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :cosmic_type_pools,
  :condition => proc { $player.has_pokemon_of_type?(:COSMIC) },
  :rare      => [:COSMOCUBE],
})

#-----------------------------------------------------------------------------
# Pools to add evolution items
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :evolution_item_pools,
  :condition => proc {
    evo_item_rarities = {
      :FIRESTONE          => :epic, :WATERSTONE         => :epic,
      :LEAFSTONE          => :epic, :THUNDERSTONE       => :epic,
      :SUNSTONE           => :epic, :MOONSTONE          => :epic,
      :SHINYSTONE         => :epic, :DUSKSTONE          => :epic,
      :DAWNSTONE          => :epic, :ICESTONE           => :epic,
      :LEADERSCREST       => :legendary, :SYRUPYAPPLE        => :legendary,
      :UNREMARKABLETEACUP => :legendary, :AUSPICIOUSARMOR    => :legendary,
      :MALICIOUSARMOR     => :legendary, :MASTERPIECETEACUP  => :legendary,
      :METALALLOY         => :legendary
    }
    dynamic_items = {:epic => [], :legendary => []}
    $player.pokemon_party.each do |pkmn|
      evo_item_rarities.each do |item, rarity|
        dynamic_items[rarity] << item if pkmn.check_evolution_on_use_item(item)
      end
    end
    next false if dynamic_items.values.all?(&:empty?)
    dynamic_items.each_value(&:uniq!)
    next dynamic_items
  }
})

#-----------------------------------------------------------------------------
# Pools to add Trade evolution items
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :trade_item_pools,
  :condition => proc {
    evo_item_rarities = {
      :PROTECTOR    => :legendary, :ELECTIRIZER => :legendary,
      :MAGMARIZER   => :legendary, :UPGRADE     => :legendary,
      :DUBIOUSDISC  => :legendary, :SACHET      => :legendary,
      :WHIPPEDDREAM => :legendary, :METALCOAT   => :legendary
    }
    dynamic_items = {:epic => [], :legendary => []}
    $player.pokemon_party.each do |pkmn|
      evo_item_rarities.each do |item, rarity|
        pkmn.check_evolution_internal do |_, new_species, method, parameter|
          next if item != parameter
          old_item = pkmn.item
          pkmn.item = item
          next if !GameData::Evolution.get(method).call_on_trade(pkmn, parameter, nil)
          pkmn.item = old_item
          dynamic_items[rarity] << item
        end
      end
    end
    next false if dynamic_items.values.all?(&:empty?)
    dynamic_items.each_value(&:uniq!)
    next dynamic_items
  }
})

#-----------------------------------------------------------------------------
# Pools to add Mega stones
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :mega_stone_pools,
  :condition => proc {
    items_to_add = []
    $player.pokemon_party.each do |pkmn|
      mega_stone = nil
      GameData::Species.each do |data|
        next if data.species != pkmn.species || data.unmega_form != pkmn.form_simple
        next if !data.mega_stone
        mega_stone = data.mega_stone
        break
      end
      next if !mega_stone
      items_to_add << mega_stone
    end
    next (items_to_add.empty?) ? false : {:legendary => items_to_add.uniq}
  }
})

#-----------------------------------------------------------------------------
# Pools to add Weather rocks
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :weather_ability_pools,
  :condition => proc {
    weather_items = {
      :DROUGHT     => :HEATROCK,
      :DRIZZLE     => :DAMPROCK,
      :SANDSTREAM  => :SMOOTHROCK,
      :SNOWWARNING => :ICYROCK
    }
    items_to_add = []
    $player.pokemon_party.each do |pkmn|
      weather_items.each do |ability, item|
        items_to_add << item if pkmn.hasAbility?(ability)
      end
    end
    next (items_to_add.empty?) ? false : {:epic => items_to_add.uniq}
  }
})

#-----------------------------------------------------------------------------
# Pools to add Terrain Seed and extender
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :terrain_ability_pools,
  :condition => proc {
    terrain_seeds = {
      :ELECTRICSURGE => :ELECTRICSEED,
      :GRASSYSURGE   => :GRASSYSEED,
      :MISTYSURGE    => :MISTYSEED,
      :PSYCHICSURGE  => :PSYCHICSEED
    }
    dynamic_items = {:rare => [], :epic => []}
    $player.pokemon_party.each do |pkmn|
      terrain_seeds.each do |ability, seed|
        dynamic_items[:rare] << seed if pkmn.hasAbility?(ability)
      end
    end
    dynamic_items[:epic] << :TERRAINEXTENDER if !dynamic_items[:rare].empty?
    next false if dynamic_items[:rare].empty? && dynamic_items[:epic].empty?
    dynamic_items[:rare].uniq!
    next dynamic_items
  }
})

#-----------------------------------------------------------------------------
# Pools for specific species
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :combee_pool,
  :condition => proc { $player.has_species?(:COMBEE) },
  :rare      => [:ROYALHONEY],
})

GameData::RewardPool.register({
  :id        => :plusle_pool,
  :condition => proc { $player.has_species?(:PLUSLE) },
  :rare      => [:LIGHTBATTERY],
})

GameData::RewardPool.register({
  :id        => :minun_pool,
  :condition => proc { $player.has_species?(:MINUN) },
  :rare      => [:LIGHTBATTERY],
})

GameData::RewardPool.register({
  :id        => :symphy_pool,
  :condition => proc { $player.has_species?(:SYMPHY) },
  :rare      => [:LIGHTBELL],
})

GameData::RewardPool.register({
  :id        => :emolga_pool,
  :condition => proc { $player.has_species?(:EMOLGA) },
  :rare      => [:LIGHTGOGGLES],
})

GameData::RewardPool.register({
  :id        => :pachirisu_pool,
  :condition => proc { $player.has_species?(:PACHIRISU) },
  :rare      => [:LIGHTNUT],
})

GameData::RewardPool.register({
  :id        => :dedenne_pool,
  :condition => proc { $player.has_species?(:DEDENNE) },
  :rare      => [:LIGHTSEED],
})

GameData::RewardPool.register({
  :id        => :togedemaru_pool,
  :condition => proc { $player.has_species?(:TOGEDEMARU) },
  :rare      => [:LIGHTROD],
})

GameData::RewardPool.register({
  :id        => :eevee_pool,
  :condition => proc { $player.has_species?(:EEVEE) },
  :rare      => [:EONGENE],
})

GameData::RewardPool.register({
  :id        => :pikachu_pool,
  :condition => proc { $player.has_species?(:PIKACHU) },
  :rare      => [:ALOLANPANCAKES],
})

#-----------------------------------------------------------------------------
# Pools to add Z-items
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :trade_item_pools,
  :condition => proc {
    z_items = [:ZATTACK, :ZDEFENSE, :ZSPATK, :ZSPDEF, :ZSPEED, :ZACCURACY]
    dynamic_items = {:rare => []}
    dynamic_items[:rare].push(z_items.sample)
    next dynamic_items
  }
})

#-----------------------------------------------------------------------------
# Pools to add Pokeballs
#-----------------------------------------------------------------------------
GameData::RewardPool.register({
  :id        => :trade_item_pools,
  :condition => proc {
    items = [:DIVEBALL, :NETBALL, :REPEATBALL, :TIMERBALL, :LUXURYBALL, :PREMIERBALL, :HEALBALL, :QUICKBALL,
      :CHERISHBALL, :FASTBALL, :LEVELBALL, :HEAVYBALL, :LOVEBALL, :FRIENDBALL, :MOONBALL, :DREAMBALL, :RICHBALL,
      :PSYCHOBALL, :JINGLEBALL, :CRYSTALBALL, :DEITYBALL, :NESTBALL]
    dynamic_items = {:rare => []}
    dynamic_items[:rare].push(items.sample)
    next dynamic_items
  }
})
