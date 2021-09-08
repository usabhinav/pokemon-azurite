#===============================================================================
# SpeedCalcAbility handlers
#===============================================================================

BattleHandlers::SpeedCalcAbility.add(:CHLOROPHYLL,
  proc { |ability,battler,mult|
    next mult * 2 if [:Sun, :HarshSun].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:QUICKFEET,
  proc { |ability,battler,mult|
    next mult*1.5 if battler.pbHasAnyStatus?
  }
)

BattleHandlers::SpeedCalcAbility.add(:SANDRUSH,
  proc { |ability,battler,mult|
    next mult * 2 if [:Sandstorm].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLOWSTART,
  proc { |ability,battler,mult|
    next mult/2 if battler.effects[PBEffects::SlowStart]>0
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLUSHRUSH,
  proc { |ability,battler,mult|
    next mult * 2 if [:Hail].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SURGESURFER,
  proc { |ability,battler,mult|
    next mult*2 if battler.battle.field.terrain == :Electric
  }
)

BattleHandlers::SpeedCalcAbility.add(:SWIFTSWIM,
  proc { |ability,battler,mult|
    next mult * 2 if [:Rain, :HeavyRain, :Thunderstorm].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:UNBURDEN,
  proc { |ability,battler,mult|
    next mult*2 if battler.effects[PBEffects::Unburden] && !battler.item
  }
)

BattleHandlers::SpeedCalcAbility.add(:PRODIGY,
  proc { |ability,battler,mult|
    # Validate if any foes have higher total stats
    abilityTriggered = false
    userTotalStats = battler.getTotalStats
    battler.eachOpposing do |b|
      abilityTriggered = true if b.getTotalStats > userTotalStats
    end
    next mult if !abilityTriggered
    # Calculate speed mult
    next mult * (1 + ([battler.getTotalEVs, 500].min / 150.0))
  }
)

BattleHandlers::SpeedCalcAbility.add(:DARKDUALITY,
  proc { |ability,battler,mult|
    next mult * 2 if battler.isSpecies?(:NOCTOA) && battler.form == 1
    next mult
  }
)

#===============================================================================
# WeightCalcAbility handlers
#===============================================================================

BattleHandlers::WeightCalcAbility.add(:HEAVYMETAL,
  proc { |ability,battler,w|
    next w*2
  }
)

BattleHandlers::WeightCalcAbility.add(:LIGHTMETAL,
  proc { |ability,battler,w|
    next [w/2,1].max
  }
)

#===============================================================================
# AbilityOnHPDroppedBelowHalf handlers
#===============================================================================

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:EMERGENCYEXIT,
  proc { |ability,battler,battle|
    next false if battler.effects[PBEffects::SkyDrop]>=0 || battler.inTwoTurnAttack?("0CE")   # Sky Drop
    # In wild battles
    if battle.wildBattle?
      next false if battler.opposes? && battle.pbSideBattlerCount(battler.index)>1
      next false if !battle.pbCanRun?(battler.index)
      battle.pbShowAbilitySplash(battler,true)
      battle.pbHideAbilitySplash(battler)
      pbSEPlay("Battle flee")
      battle.pbDisplay(_INTL("{1} fled from battle!",battler.pbThis))
      battle.decision = 3   # Escaped
      next true
    end
    # In trainer battles
    next false if battle.pbAllFainted?(battler.idxOpposingSide)
    next false if !battle.pbCanSwitch?(battler.index)   # Battler can't switch out
    next false if !battle.pbCanChooseNonActive?(battler.index)   # No Pokémon can switch in
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} activated!",battler.pbThis,battler.abilityName))
    end
    battle.pbDisplay(_INTL("{1} went back to {2}!",
       battler.pbThis,battle.pbGetOwnerName(battler.index)))
    if battle.endOfRound   # Just switch out
      battle.scene.pbRecall(battler.index) if !battler.fainted?
      battler.pbAbilitiesOnSwitchOut   # Inc. primordial weather check
      next true
    end
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next false if newPkmn<0   # Shouldn't ever do this
    battle.pbRecallAndReplace(battler.index,newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    next true
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.copy(:EMERGENCYEXIT,:WIMPOUT)

#===============================================================================
# StatusCheckAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatusCheckAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability,battler,status|
    next false if !battler.isSpecies?(:KOMALA)
    next true if status.nil? || status == :SLEEP
  }
)

#===============================================================================
# StatusImmunityAbility handlers
#===============================================================================

BattleHandlers::StatusImmunityAbility.add(:FLOWERVEIL,
  proc { |ability,battler,status|
    next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAbility.add(:IMMUNITY,
  proc { |ability,battler,status|
    next true if status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:INSOMNIA,
  proc { |ability,battler,status|
    next true if status == :SLEEP
  }
)

BattleHandlers::StatusImmunityAbility.copy(:INSOMNIA,:SWEETVEIL,:VITALSPIRIT)

BattleHandlers::StatusImmunityAbility.add(:LEAFGUARD,
  proc { |ability,battler,status|
    next true if [:Sun, :HarshSun].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::StatusImmunityAbility.add(:LIMBER,
  proc { |ability,battler,status|
    next true if status == :PARALYSIS
  }
)

BattleHandlers::StatusImmunityAbility.add(:MAGMAARMOR,
  proc { |ability,battler,status|
    next true if status == :FROZEN
  }
)

BattleHandlers::StatusImmunityAbility.add(:WATERVEIL,
  proc { |ability,battler,status|
    next true if status == :BURN
  }
)

BattleHandlers::StatusImmunityAbility.copy(:WATERVEIL,:WATERBUBBLE,:SPICETANK)

#===============================================================================
# StatusImmunityAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatusImmunityAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability,battler,status|
    next true if battler.isSpecies?(:KOMALA)
  }
)

BattleHandlers::StatusImmunityAbilityNonIgnorable.add(:SHIELDSDOWN,
  proc { |ability,battler,status|
    next true if battler.isSpecies?(:MINIOR) && battler.form<7
  }
)

#===============================================================================
# StatusImmunityAllyAbility handlers
#===============================================================================

BattleHandlers::StatusImmunityAllyAbility.add(:FLOWERVEIL,
  proc { |ability,battler,status|
    next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAbility.add(:SWEETVEIL,
  proc { |ability,battler,status|
    next true if status == :SLEEP
  }
)

#===============================================================================
# AbilityOnStatusInflicted handlers
#===============================================================================

BattleHandlers::AbilityOnStatusInflicted.add(:SYNCHRONIZE,
  proc { |ability,battler,user,status|
    next if !user || user.index==battler.index
    case status
    when :POISON
      if user.pbCanPoisonSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} poisoned {3}!",battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbPoison(nil,msg,(battler.statusCount>0))
        battler.battle.pbHideAbilitySplash(battler)
      end
    when :BURN
      if user.pbCanBurnSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} burned {3}!",battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbBurn(nil,msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    when :PARALYSIS
      if user.pbCanParalyzeSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
             battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbParalyze(nil,msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    end
  }
)

#===============================================================================
# StatusCureAbility handlers
#===============================================================================

BattleHandlers::StatusCureAbility.add(:IMMUNITY,
  proc { |ability,battler|
    next if battler.status != :POISON
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:INSOMNIA,
  proc { |ability,battler|
    next if battler.status != :SLEEP
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:INSOMNIA,:VITALSPIRIT)

BattleHandlers::StatusCureAbility.add(:LIMBER,
  proc { |ability,battler|
    next if battler.status != :PARALYSIS
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:MAGMAARMOR,
  proc { |ability,battler|
    next if battler.status != :FROZEN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:OBLIVIOUS,
  proc { |ability,battler|
    next if battler.effects[PBEffects::Attract]<0 &&
            (battler.effects[PBEffects::Taunt]==0 || Settings::MECHANICS_GENERATION <= 5)
    battler.battle.pbShowAbilitySplash(battler)
    if battler.effects[PBEffects::Attract]>=0
      battler.pbCureAttract
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battler.battle.pbDisplay(_INTL("{1} got over its infatuation.",battler.pbThis))
      else
        battler.battle.pbDisplay(_INTL("{1}'s {2} cured its infatuation status!",
           battler.pbThis,battler.abilityName))
      end
    end
    if battler.effects[PBEffects::Taunt]>0 && Settings::MECHANICS_GENERATION >= 6
      battler.effects[PBEffects::Taunt] = 0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battler.battle.pbDisplay(_INTL("{1}'s Taunt wore off!",battler.pbThis))
      else
        battler.battle.pbDisplay(_INTL("{1}'s {2} made its taunt wear off!",
           battler.pbThis,battler.abilityName))
      end
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:OWNTEMPO,
  proc { |ability,battler|
    next if battler.effects[PBEffects::Confusion]==0
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureConfusion
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis))
    else
      battler.battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",
         battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:WATERVEIL,
  proc { |ability,battler|
    next if battler.status != :BURN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:WATERVEIL,:WATERBUBBLE)

#===============================================================================
# StatLossImmunityAbility handlers
#===============================================================================

BattleHandlers::StatLossImmunityAbility.add(:BIGPECKS,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=:DEFENSE
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:CLEARBODY,
  proc { |ability,battler,stat,battle,showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:WHITESMOKE)

BattleHandlers::StatLossImmunityAbility.add(:FLOWERVEIL,
  proc { |ability,battler,stat,battle,showMessages|
    next false if !battler.pbHasType?(:GRASS)
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:HYPERCUTTER,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=:ATTACK
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:KEENEYE,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=:ACCURACY
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.copy(:KEENEYE, :SENSORYAWARENESS)

BattleHandlers::StatLossImmunityAbility.add(:VICTORYRUSH,
  proc { |ability,battler,stat,battle,showMessages|
    next false if !battler.effects[PBEffects::VictoryRush]
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is on its {2}!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

#===============================================================================
# StatLossImmunityAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatLossImmunityAbilityNonIgnorable.add(:FULLMETALBODY,
  proc { |ability,battler,stat,battle,showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

#===============================================================================
# StatLossImmunityAllyAbility handlers
#===============================================================================

BattleHandlers::StatLossImmunityAllyAbility.add(:FLOWERVEIL,
  proc { |ability,bearer,battler,stat,battle,showMessages|
    next false if !battler.pbHasType?(:GRASS)
    if showMessages
      battle.pbShowAbilitySplash(bearer)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s stat loss!",
           bearer.pbThis,bearer.abilityName,battler.pbThis(true)))
      end
      battle.pbHideAbilitySplash(bearer)
    end
    next true
  }
)

#===============================================================================
# AbilityOnStatGain handlers
#===============================================================================

# There aren't any!

#===============================================================================
# AbilityOnStatLoss handlers
#===============================================================================

BattleHandlers::AbilityOnStatLoss.add(:COMPETITIVE,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,battler)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:DEFIANT,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(:ATTACK,2,battler)
  }
)

#===============================================================================
# PriorityChangeAbility handlers
#===============================================================================

BattleHandlers::PriorityChangeAbility.add(:GALEWINGS,
  proc { |ability,battler,move,pri|
    next pri+1 if battler.hp==battler.totalhp && move.type == :FLYING
  }
)

BattleHandlers::PriorityChangeAbility.add(:PRANKSTER,
  proc { |ability,battler,move,pri|
    if move.statusMove?
      battler.effects[PBEffects::Prankster] = true
      next pri+1
    end
  }
)

BattleHandlers::PriorityChangeAbility.add(:TRIAGE,
  proc { |ability,battler,move,pri|
    next pri+3 if move.healingMove?
  }
)

BattleHandlers::PriorityChangeAbility.add(:SPEEDBALL,
  proc { |ability,battler,move,pri|
    next pri+1 if move.rollingBasedMove? || battler.usingMultiTurnAttack?
  }
)

BattleHandlers::PriorityChangeAbility.add(:FREESTYLE,
  proc { |ability,battler,move,pri|
    next pri+1 if move.type == :SOUND || move.pbSoundMove?(battler)
  }
)

BattleHandlers::PriorityChangeAbility.add(:RAPIDSTREAM,
  proc { |ability,battler,move,pri|
    next pri+1 if move.type == :WATER && battler.hp == battler.totalhp
  }
)

# Lowest possible bracket
BattleHandlers::PriorityChangeAbility.add(:IMMOVABLE,
  proc { |ability,battler,move,pri|
    next -7
  }
)

BattleHandlers::PriorityChangeAbility.add(:QUICKBLADE,
  proc { |ability,battler,move,pri|
    next pri+1 if move.slashingMove?
  }
)

#===============================================================================
# PriorityBracketChangeAbility handlers
#===============================================================================

BattleHandlers::PriorityBracketChangeAbility.add(:STALL,
  proc { |ability,battler,subPri,battle|
    next -1 if subPri==0
  }
)

# Last within bracket
BattleHandlers::PriorityBracketChangeAbility.copy(:STALL, :IMMOVABLE)

#===============================================================================
# PriorityBracketUseAbility handlers
#===============================================================================

# There aren't any!

#===============================================================================
# AbilityOnFlinch handlers
#===============================================================================

BattleHandlers::AbilityOnFlinch.add(:STEADFAST,
  proc { |ability,battler,battle|
    battler.pbRaiseStatStageByAbility(:SPEED,1,battler)
  }
)

#===============================================================================
# MoveBlockingAbility handlers
#===============================================================================

BattleHandlers::MoveBlockingAbility.add(:DAZZLING,
  proc { |ability,bearer,user,targets,move,battle|
    next false if battle.choices[user.index][4]<=0
    next false if !bearer.opposes?(user)
    ret = false
    targets.each do |b|
      next if !b.opposes?(user)
      ret = true
    end
    next ret
  }
)

BattleHandlers::MoveBlockingAbility.copy(:DAZZLING,:QUEENLYMAJESTY)

#===============================================================================
# MoveImmunityTargetAbility handlers
#===============================================================================

BattleHandlers::MoveImmunityTargetAbility.add(:BULLETPROOF,
  proc { |ability,user,target,move,type,battle|
    next false if !move.bombMove?
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
         target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,type,battle|
    next false if user.index==target.index
    next false if type != :FIRE
    battle.pbShowAbilitySplash(target)
    if !target.effects[PBEffects::FlashFire]
      target.effects[PBEffects::FlashFire] = true
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!",target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose because of its {2}!",
           target.pbThis(true),target.abilityName))
      end
    else
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           target.pbThis,target.abilityName,move.name))
      end
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,:SPECIAL_ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MOTORDRIVE,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,:SPEED,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:CLOUDFLUFF,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,:SPECIAL_ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SAPSIPPER,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:GRASS,:ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SOUNDPROOF,
  proc { |ability,user,target,move,type,battle|
    next false if !move.pbSoundMove?(user) && move.type != :SOUND
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true

  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STORMDRAIN,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:WATER,:SPECIAL_ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:TELEPATHY,
  proc { |ability,user,target,move,type,battle|
    next false if move.statusMove?
    next false if user.index==target.index || target.opposes?(user)
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon with {2}!",
         target.pbThis,target.abilityName))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VOLTABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:ELECTRIC,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:WATER,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WATERABSORB,:DRYSKIN)

BattleHandlers::MoveImmunityTargetAbility.add(:WONDERGUARD,
  proc { |ability,user,target,move,type,battle|
    next false if move.statusMove?
    next false if !type || Effectiveness.super_effective?(target.damageState.typeMod)
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1} avoided damage with {2}!",target.pbThis,target.abilityName))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

# To make target immune to contact moves
BattleHandlers::MoveImmunityTargetAbility.add(:IMMATERIAL,
  proc { |ability,user,target,move,type,battle|
    next false if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
         target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:THERMALPOWER,
  proc { |ability,user,target,move,type,battle|
    next false if type != :FIRE
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
         target.pbThis,target.abilityName,move.name))
    end
    if target.pbCanRaiseStatStage?(:SPEED,target)
      target.pbRaiseStatStageByAbility(:SPEED,1,target,false)
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:HUMIDIFY,
  proc { |ability,user,target,move,type,battle|
    next false if type != :WATER
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
         target.pbThis,target.abilityName,move.name))
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
      target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target,false)
    end
    target.eachAlly do |b|
      if b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
        b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target,false)
      end
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:QUARTZARMOR,
  proc { |ability,user,target,move,type,battle|
    next false if type != :WATER
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
        target.pbThis,target.abilityName,move.name))
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,target)
      target.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,target,false)
    end
    if target.pbCanLowerStatStage?(:SPEED,target)
      target.pbLowerStatStageByAbility(:SPEED,1,target,false)
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WINTERSPIRIT,
  proc { |ability,user,target,move,type,battle|
    next false if type != :NORMAL && type != :FIGHTING
    next false if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
        target.pbThis,target.abilityName,move.name))
    end
    if user.pbCanFreeze?(target, false) && user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.pbFreeze
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FIRMLYPLANTED,
  proc { |ability,user,target,move,type,battle|
    next false if !move.throwingMove?
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} stayed firmly planted!",target.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
        target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:DARKDUALITY,
  proc { |ability,user,target,move,type,battle|
    next false if !target.isSpecies?(:NOCTOA) || target.form != 1
    next false if type != :GHOST
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
        target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

#===============================================================================
# MoveBaseTypeModifierAbility handlers
#===============================================================================

BattleHandlers::MoveBaseTypeModifierAbility.add(:AERILATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:FLYING)
    move.powerBoost = true
    next :FLYING
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:GALVANIZE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:ELECTRIC)
    move.powerBoost = true
    next :ELECTRIC
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:LIQUIDVOICE,
  proc { |ability,user,move,type|
    next :WATER if GameData::Type.exists?(:WATER) && move.pbSoundMove?(user)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:NORMALIZE,
  proc { |ability,user,move,type|
    next if !GameData::Type.exists?(:NORMAL)
    move.powerBoost = true if Settings::MECHANICS_GENERATION >= 7
    next :NORMAL
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:PIXILATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:FAIRY)
    move.powerBoost = true
    next :FAIRY
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:REFRIGERATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:ICE)
    move.powerBoost = true
    next :ICE
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:CRYSTALATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:CRYSTAL)
    move.powerBoost = true
    next :CRYSTAL
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:SAKURA,
  proc { |ability,user,move,type|
    next if type != :GRASS || !GameData::Type.exists?(:FAIRY)
    move.powerBoost = true
    next :FAIRY
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:MINDTRICK,
  proc { |ability,user,move,type|
    next if type != :PSYCHIC || !GameData::Type.exists?(:MYSTIC)
    move.powerBoost = true
    next :MYSTIC
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:GALAXYBRAIN,
  proc { |ability,user,move,type|
    next if type != :PSYCHIC || !GameData::Type.exists?(:COSMIC)
    move.powerBoost = true
    next :COSMIC
  }
)

#===============================================================================
# AccuracyCalcUserAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAbility.add(:COMPOUNDEYES,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.3
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:HUSTLE,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 0.8 if move.pbPhysicalMove?(user)
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:KEENEYE,
  proc { |ability,mods,user,target,move,type|
    mods[:evasion_stage] = 0 if mods[:evasion_stage] > 0 && Settings::MECHANICS_GENERATION >= 6
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:NOGUARD,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:UNAWARE,
  proc { |ability,mods,user,target,move,type|
    mods[:evasion_stage] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:VICTORYSTAR,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.1
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:DARKLIGHT,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.1 if target.pbHasType?(:DARK)
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:LUNARBLESSING,
  proc { |ability,mods,user,target,move,type|
    next if !move.pbDamagingMove?
    mods[:accuracy_multiplier] *= 1.25
  }
)

#===============================================================================
# AccuracyCalcUserAllyAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAllyAbility.add(:VICTORYSTAR,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.1
  }
)

BattleHandlers::AccuracyCalcUserAllyAbility.add(:DARKLIGHT,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.1 if target.pbHasType?(:DARK)
  }
)

#===============================================================================
# AccuracyCalcTargetAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0 if type == :ELECTRIC
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:NOGUARD,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:SANDVEIL,
  proc { |ability,mods,user,target,move,type|
    mods[:evasion_multiplier] *= 1.25 if target.battle.pbWeather == :Sandstorm
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:SNOWCLOAK,
  proc { |ability,mods,user,target,move,type|
    mods[:evasion_multiplier] *= 1.25 if target.battle.pbWeather == :Hail
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:STORMDRAIN,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0 if type == :WATER
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:TANGLEDFEET,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] /= 2 if target.effects[PBEffects::Confusion] > 0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:UNAWARE,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_stage] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:WONDERSKIN,
  proc { |ability,mods,user,target,move,type|
    if move.statusMove? && user.opposes?(target)
      mods[:base_accuracy] = 50 if mods[:base_accuracy] > 50
    end
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:AVOID,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 0.85 if move.pbSpecialMove?(user)
  }
)

#===============================================================================
# DamageCalcUserAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAbility.add(:AERILATE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if move.powerBoost
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:AERILATE, :PIXILATE, :REFRIGERATE, :GALVANIZE, :NORMALIZE, :CRYSTALATE, :MINDTRICK, :GALAXYBRAIN)

BattleHandlers::DamageCalcUserAbility.add(:SAKURA,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.1 if move.powerBoost
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ANALYTIC,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if (target.battle.choices[target.index][0]!=:UseMove &&
       target.battle.choices[target.index][0]!=:Shift) ||
       target.movedThisRound?
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BLAZE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp <= user.totalhp / 3 && type == :FIRE
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DEFEATIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] /= 2 if user.hp <= user.totalhp / 2
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLAREBOOST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.burned? && move.pbSpecialMove?(user)
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.effects[PBEffects::FlashFire] && type == :FIRE
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.pbPhysicalMove?(user) && [:Sun, :HarshSun].include?(user.battle.pbWeather)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GUTS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.pbHasAnyStatus? && move.pbPhysicalMove?(user)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HUGEPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 2 if move.pbPhysicalMove?(user)
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:HUGEPOWER,:PUREPOWER)

BattleHandlers::DamageCalcUserAbility.add(:HUSTLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if move.pbPhysicalMove?(user)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:IRONFIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MEGALAUNCHER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.pulseMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MINUS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.pbSpecialMove?(user)
    user.eachAlly do |b|
      next if !b.hasActiveAbility?([:MINUS, :PLUS])
      mults[:attack_multiplier] *= 1.5
      break
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:MINUS,:PLUS)

BattleHandlers::DamageCalcUserAbility.add(:NEUROFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 1.25
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:OVERGROW,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp <= user.totalhp / 3 && type == :GRASS
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RECKLESS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if move.recoilMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RIVALRY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.gender!=2 && target.gender!=2
      if user.gender==target.gender
        mults[:base_damage_multiplier] *= 1.25
      else
        mults[:base_damage_multiplier] *= 0.75
      end
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SANDFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather == :Sandstorm &&
       [:ROCK, :GROUND, :STEEL].include?(type)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SHEERFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.3 if move.addlEffect > 0
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:SHEERFORCE,:MORALPACT)

BattleHandlers::DamageCalcUserAbility.add(:SLOWSTART,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] /= 2 if user.effects[PBEffects::SlowStart] > 0 && move.pbPhysicalMove?(user)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SOLARPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.pbSpecialMove?(user) && [:Sun, :HarshSun].include?(user.battle.pbWeather)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SNIPER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.damageState.critical
      mults[:final_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STAKEOUT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 2 if target.battle.choices[target.index][0] == :SwitchOut
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELWORKER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRONGJAW,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.bitingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SWARM,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp <= user.totalhp / 3 && type == :BUG
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TECHNICIAN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.index != target.index && move && move.id != :STRUGGLE &&
       baseDmg * mults[:base_damage_multiplier] <= 60
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TINTEDLENS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 2 if Effectiveness.resistant?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TORRENT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp <= user.totalhp / 3 && type == :WATER
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TOUGHCLAWS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 4 / 3.0 if move.contactMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TOXICBOOST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.poisoned? && move.pbPhysicalMove?(user)
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WATERBUBBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 2 if type == :WATER
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MAGMATICHEAT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    targetTypes = target.pbTypes(true) # Takes third type into account
    for targetType in targetTypes
      if Effectiveness.not_very_effective_type?(type, targetType) && type == :FIRE
        # Changes the 0.5x "not very effective" multiplier to 0.75x
        mults[:base_damage_multiplier] *= 1.5
      end
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RAINBOWGUARD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    types = [:FIRE, :ICE, :ELECTRIC]
    mults[:base_damage_multiplier] *= 1.3 if types.include?(type) && !user.pbHasType?(type)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TAINTEDPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 2
  }
)

BattleHandlers::DamageCalcUserAbility.add(:OPPORTUNIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if move.accuracy == 0 # Moves that never miss
    if move.accuracy < 60
      mults[:final_damage_multiplier] *= 2
    elsif move.accuracy < 100
      mults[:final_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ENTERSPHERE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if type == :FIRE
      mults[:base_damage_multiplier] *= 1.6
    elsif move.pbContactMove?(user)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:CRYSTALSURGE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if type != :CRYSTAL
    next if user.pbHasType?(:CRYSTAL)
    mults[:final_damage_multiplier] *= 1.5
  }
)

BattleHandlers::DamageCalcUserAbility.add(:VANGUARD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if user.turnCount != 1
    mults[:final_damage_multiplier] *= 1.5
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:VANGUARD, :CHARGEDUP)

BattleHandlers::DamageCalcUserAbility.add(:FLYTRAP,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !target.pbHasType?(:BUG)
    mults[:base_damage_multiplier] *= 1.3
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BULLY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if target.pokemon.height > user.pokemon.height
    next if target.pokemon.height == user.pokemon.height && user.pbWeight <= target.pbWeight
    mults[:base_damage_multiplier] *= 1.3
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FRENZIED,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= [2 - ((user.hp.to_f-1) / user.totalhp), 1.0].max
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PERSEVERANCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    met = 1 + 0.2 * [user.effects[PBEffects::Metronome], 3].min
    mults[:final_damage_multiplier] *= met
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ILLINTENT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if move.calcType != :DARK
    mults[:base_damage_multiplier] *= 1.3
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WINDUP,
  proc { |ability,user,target,move,mults,baseDmg,type|
    # TODO: Consider making dedicated method for detecting two-turn attacks, charging or otherwise
    # Two turn attack, Hyper Beam, or Shadow Half
    next if !move.chargingTurnMove? && move.function != "0C2" && move.function != "12E"
    mults[:final_damage_multiplier] *= 1.5
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLURESCENCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.chargingTurnMove?
    mults[:final_damage_multiplier] *= 0.8
  }
)

BattleHandlers::DamageCalcUserAbility.add(:LUNARBLESSING,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 1.25
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PRODIGY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    # Validate if any foes have higher total stats
    abilityTriggered = false
    userTotalStats = user.getTotalStats
    user.eachOpposing do |b|
      abilityTriggered = true if b.getTotalStats > userTotalStats
    end
    next if !abilityTriggered
    # Calculate attack mult
    mults[:attack_multiplier] *= 1 + ([user.getTotalEVs, 500].min / 150.0)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:CRYSTALSTINGER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 2
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WINTERSPIRIT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if type != :GHOST
    next if user.battle.pbWeather != :Hail
    mults[:final_damage_multiplier] *= 1.5
  }
)

BattleHandlers::DamageCalcUserAbility.add(:OVERCHARGED,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if type != :ELECTRIC
    mults[:base_damage_multiplier] *= 1 + (user.effects[PBEffects::Overcharged] * 0.15)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BERSERKER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if user.totalhp <= 1 # Probably not possible but just in case
    # User hp range is 1..totalhp
    # Mult should be 1x at full hp, and 2x at 1 HP
    berserkerRatio = (1 - ((user.hp.to_f - 1) / (user.totalhp - 1)))
    mults[:final_damage_multiplier] *= 1 + berserkerRatio
  }
)

BattleHandlers::DamageCalcUserAbility.add(:EXPLOSIVEEXHAUST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    # Recoil move or move function for Explosion (or Self-Destruct), Final Gambit, or Mind Blown
    mults[:base_damage_multiplier] *= 1.5 if move.recoilMove? || ["0E0", "0E1", "170"].include?(move.function)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:IRONKICK,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if move.kickingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRONGSKULL,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.headBasedMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ROLLUP,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.ballRollingMove?
  }
)

#===============================================================================
# DamageCalcUserAllyAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAllyAbility.add(:BATTERY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.pbSpecialMove?(user)
    mults[:final_damage_multiplier] *= 1.3
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.pbPhysicalMove?(user) && [:Sun, :HarshSun].include?(user.battle.pbWeather)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:NOMAD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !user.pbHasType?(:FLYING) && !user.pbHasType?(:DRAGON)
    mults[:final_damage_multiplier] *= 1.5
  }
)

#===============================================================================
# DamageCalcTargetAbility handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAbility.add(:DRYSKIN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.25 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FILTER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 0.75
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.copy(:FILTER,:SOLIDROCK)

BattleHandlers::DamageCalcTargetAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.pbSpecialMove?(user) && [:Sun, :HarshSun].include?(user.battle.pbWeather)
      mults[:defense_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FLUFFY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 2 if move.calcType == :FIRE
    mults[:base_damage_multiplier] /= 2 if move.contactMove?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FURCOAT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:defense_multiplier] *= 2 if move.pbPhysicalMove?(user) || move.function == "122"   # Psyshock
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:GRASSPELT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.field.terrain == :Grassy
      mults[:defense_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:HEATPROOF,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] /= 2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MARVELSCALE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.pbHasAnyStatus? && move.pbPhysicalMove?(user)
      mults[:defense_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MULTISCALE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] /= 2 if target.hp == target.totalhp
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:THICKFAT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] /= 2 if type == :FIRE || type == :ICE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:WATERBUBBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] /= 2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:CRYSTALLINE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if type == :WATER || type == :GRASS
      mults[:base_damage_multiplier] /= 2
    elsif type == :ELECTRIC
      mults[:base_damage_multiplier] *= 2
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:IMMATERIAL,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.pbSpecialMove?(user)
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:THERMALPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if type == :ICE
      mults[:base_damage_multiplier] *= 2
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:CLOUDFLUFF,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.pbContactMove?(user) && move.pbPhysicalMove?(user)
      mults[:base_damage_multiplier] *= 0.75
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:DESERTBODY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] /= 2 if type == :FIRE || type == :ICE || type == :WATER
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:EDIBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.bitingMove?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:VINECOILSTYLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.pbContactMove?(user)
    mults[:base_damage_multiplier] *= 0.7
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:REFLECTIVE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.pbSpecialMove?(user)
    mults[:base_damage_multiplier] *= 0.5
  }
)

#===============================================================================
# DamageCalcTargetAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAbilityNonIgnorable.add(:PRISMARMOR,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 0.75
    end
  }
)

BattleHandlers::DamageCalcTargetAbilityNonIgnorable.add(:SHADOWSHIELD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.hp==target.totalhp
      mults[:final_damage_multiplier] /= 2
    end
  }
)

#===============================================================================
# DamageCalcTargetAllyAbility handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.pbSpecialMove?(user) && [:Sun, :HarshSun].include?(user.battle.pbWeather)
      mults[:defense_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:FRIENDGUARD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 0.75
  }
)

#===============================================================================
# CriticalCalcUserAbility handlers
#===============================================================================

BattleHandlers::CriticalCalcUserAbility.add(:MERCILESS,
  proc { |ability,user,target,c|
    next 99 if target.poisoned?
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:SUPERLUCK,
  proc { |ability,user,target,c|
    next c+1
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:COUNTERPARRY,
  proc { |ability,user,target,c|
    next 99 if user.hasActiveAbility?(:COUNTERPARRY) && user.effects[PBEffects::CounterParry]
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:OMNIPOTENT,
  proc { |ability,user,target,c|
    next 99
  }
)

#===============================================================================
# CriticalCalcTargetAbility handlers
#===============================================================================

BattleHandlers::CriticalCalcTargetAbility.add(:BATTLEARMOR,
  proc { |ability,user,target,c|
    next -1
  }
)

BattleHandlers::CriticalCalcTargetAbility.copy(:BATTLEARMOR,:SHELLARMOR)

#===============================================================================
# TargetAbilityOnHit handlers
#===============================================================================

BattleHandlers::TargetAbilityOnHit.add(:AFTERMATH,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if !battle.moldBreaker
      dampBattler = battle.pbCheckGlobalAbility(:DAMP)
      if dampBattler
        battle.pbShowAbilitySplash(dampBattler)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1} cannot use {2}!",target.pbThis,target.abilityName))
        else
          battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
             target.pbThis,target.abilityName,dampBattler.pbThis(true),dampBattler.abilityName))
        end
        battle.pbHideAbilitySplash(dampBattler)
        battle.pbHideAbilitySplash(target)
        next
      end
    end
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp/4,false)
      battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ANGERPOINT,
  proc { |ability,user,target,move,battle|
    next if !target.damageState.critical
    next if !target.pbCanRaiseStatStage?(:ATTACK,target)
    battle.pbShowAbilitySplash(target)
    target.stages[:ATTACK] = 6
    battle.pbCommonAnimation("StatUp",target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} maxed its {2}!",target.pbThis,GameData::Stat.get(:ATTACK).name))
    else
      battle.pbDisplay(_INTL("{1}'s {2} maxed its {3}!",
         target.pbThis,target.abilityName,GameData::Stat.get(:ATTACK).name))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CURSEDBODY,
  proc { |ability,user,target,move,battle|
    next if user.fainted?
    next if user.effects[PBEffects::Disable]>0
    regularMove = nil
    user.eachMove do |m|
      next if m.id!=user.lastRegularMoveUsed
      regularMove = m
      break
    end
    next if !regularMove || (regularMove.pp==0 && regularMove.total_pp>0)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if !move.pbMoveFailedAromaVeil?(target,user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.effects[PBEffects::Disable]     = 3
      user.effects[PBEffects::DisableMove] = regularMove.id
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} was disabled!",user.pbThis,regularMove.name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} was disabled by {3}'s {4}!",
           user.pbThis,regularMove.name,target.pbThis(true),target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
      user.pbItemStatusCureCheck
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CUTECHARM,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanAttract?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} made {3} fall in love!",target.pbThis,
           target.abilityName,user.pbThis(true))
      end
      user.pbAttract(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:EFFECTSPORE,
  proc { |ability,user,target,move,battle|
    # NOTE: This ability has a 30% chance of triggering, not a 30% chance of
    #       inflicting a status condition. It can try (and fail) to inflict a
    #       status condition that the user is immune to.
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    r = battle.pbRandom(3)
    next if r==0 && user.asleep?
    next if r==1 && user.poisoned?
    next if r==2 && user.paralyzed?
    battle.pbShowAbilitySplash(target)
    if user.affectedByPowder?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      case r
      when 0
        if user.pbCanSleep?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} made {3} fall asleep!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbSleep(msg)
        end
      when 1
        if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbPoison(target,msg)
        end
      when 2
        if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
               target.pbThis,target.abilityName,user.pbThis(true))
          end
          user.pbParalyze(target,msg)
        end
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.burned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanBurn?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbBurn(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GOOEY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    user.pbLowerStatStageByAbility(:SPEED,1,target,true,true)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:GOOEY,:TANGLINGHAIR)

BattleHandlers::TargetAbilityOnHit.add(:ILLUSION,
  proc { |ability,user,target,move,battle|
    # NOTE: This intentionally doesn't show the ability splash.
    next if !target.effects[PBEffects::Illusion]
    target.effects[PBEffects::Illusion] = nil
    battle.scene.pbChangePokemon(target,target.pokemon)
    battle.pbDisplay(_INTL("{1}'s illusion wore off!",target.pbThis))
    battle.pbSetSeen(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:INNARDSOUT,
  proc { |ability,user,target,move,battle|
    next if !target.fainted? || user.dummy
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(target.damageState.hpLost,false)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
           target.pbThis(true),target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:IRONBARBS,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp/8,false)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
           target.pbThis(true),target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:IRONBARBS,:ROUGHSKIN)

BattleHandlers::TargetAbilityOnHit.add(:JUSTIFIED,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :DARK
    target.pbRaiseStatStageByAbility(:ATTACK,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:MUMMY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    next if user.unstoppableAbility? || user.ability == ability
    oldAbil = nil
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
      user.ability = ability
      battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis,user.abilityName,target.pbThis(true)))
      end
      battle.pbHideAbilitySplash(user) if user.opposes?(target)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnAbilityChanged(oldAbil) if oldAbil != nil
  }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPOINT,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.poisoned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbPoison(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:RATTLED,
  proc { |ability,user,target,move,battle|
    next if ![:BUG, :DARK, :GHOST].include?(move.calcType)
    target.pbRaiseStatStageByAbility(:SPEED,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STAMINA,
  proc { |ability,user,target,move,battle|
    target.pbRaiseStatStageByAbility(:DEFENSE,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STATIC,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.paralyzed? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
           target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbParalyze(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WATERCOMPACTION,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :WATER
    target.pbRaiseStatStageByAbility(:DEFENSE,2,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKARMOR,
  proc { |ability,user,target,move,battle|
    next if !move.phypbPhysicalMove?(user)
    next if !target.pbCanLowerStatStage?(:DEFENSE, target) &&
            !target.pbCanRaiseStatStage?(:SPEED, target)
    battle.pbShowAbilitySplash(target)
    target.pbLowerStatStageByAbility(:DEFENSE, 1, target, false)
    target.pbRaiseStatStageByAbility(:SPEED,
       (Settings::MECHANICS_GENERATION >= 7) ? 2 : 1, target, false)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:AMBIENTAMNESIA,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    reduction = [4,move.pp].min
    if reduction > 0 && battle.pbRandom(10) < 5
      battle.pbShowAbilitySplash(target)
      user.pbSetPP(move,move.pp-reduction)
      battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
          user.pbThis(true),move.name,reduction))
      battle.pbHideAbilitySplash(target)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ENTANGLINGMESS,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(10) < 5
    next if user.effects[PBEffects::Trapping]>0
    next if !user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    battle.pbShowAbilitySplash(target)
    # Set trapping effect duration and info
    user.effects[PBEffects::Trapping] = 2+battle.pbRandom(2)
    user.effects[PBEffects::TrappingMove] = :BIND
    user.effects[PBEffects::TrappingUser] = target.index
    battle.pbDisplay(_INTL("{1} was squeezed by {2}!",user.pbThis,target.pbThis(true)))
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:KAMIKAZE,
  proc { |ability,user,target,move,battle|
    next if target.hp >= (target.totalhp/2).round
    next if !move.pbContactMove?(user)
    minchance = 25
    maxchance = 75
    chance=maxchance-((target.hp/(target.totalhp/2.0))*(maxchance-minchance)).round
    if battle.pbRandom(100) < chance && !target.fainted?
      battle.pbShowAbilitySplash(target)
      target.pbUseMoveSimple(:KAMIKAZEATTACK,user.index)
      battle.pbHideAbilitySplash(target)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:MADNESS,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(10) < 5
    next if !user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    battle.pbShowAbilitySplash(target)
    if user.pbCanConfuse?(target)
      user.pbConfuse(_INTL("{1} confused {2}!",target.pbThis,user.pbThis(true)))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:PHILANTHROPIST,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(10) < 5
    next if !user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if user.status != PBStatuses::NONE
      battle.pbShowAbilitySplash(target)
      user.pbCureStatus
      battle.pbHideAbilitySplash(target)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:THERMALPOWER,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :ICE
    if target.pbCanLowerStatStage?(:SPEED,target)
      target.pbLowerStatStageByAbility(:SPEED,1,target)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:VINDICTIVE,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    stat = :ATTACK
    # Photon Geyser uses the higher of Sp. Atk and Attack
    if move.pbSpecialMove?(user) || (move.function == "164" && user.spatk >= user.attack)
      stat = :SPECIAL_ATTACK
    end
    if user.pbCanLowerStatStage?(stat,user)
      user.pbLowerStatStageByAbility(stat,2,target)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:REFLECTIVE,
  proc { |ability,user,target,move,battle|
    if move.pbSpecialMove?(user) && !user.hasActiveAbility?(:ROCKHEAD) && user.takesIndirectDamage?
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
      battle.scene.pbDamageAnimation(user,0)
      user.pbReduceHP(target.damageState.calcDamage/2)
      user.pbFaint if user.fainted?
      battle.pbHideAbilitySplash(target)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:BATTLESTANCE,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !target.pbCanRaiseStatStage?(:ATTACK, target)
    target.pbRaiseStatStageByAbility(:ATTACK, 1, target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:EDIBLE,
  proc { |ability,user,target,move,battle|
    next if !move.bitingMove?
    next if !target.pbCanRaiseStatStage?(:SPEED, target)
    target.pbRaiseStatStageByAbility(:SPEED, 2, target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CRYSTALADAPTATION,
  proc { |ability,user,target,move,battle|
    type = move.calcType
    res = target.effects[PBEffects::CrystalAdaptation]
    if res[type].nil?
      res[type] = Effectiveness::NORMAL_EFFECTIVE
    end
    if res[type] > Effectiveness::NORMAL_EFFECTIVE/4 # 4x resistance
      res[type] /= 2
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:VIGILANT,
  proc { |ability,user,target,move,battle|
    next if !target.asleep?
    battle.pbShowAbilitySplash(target)
    target.pbCureStatus
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WEBCOVER,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    battle.pbShowAbilitySplash(target)
    if user.pbCanLowerStatStage?(:SPEED, target)
      user.pbLowerStatStageByAbility(:SPEED, 1, target, false)
    end
    if user.effects[PBEffects::MeanLook] < 0
      user.effects[PBEffects::MeanLook] = target.index
      battle.pbDisplay(_INTL("{1} can no longer escape!",user.pbThis))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:PUSHBOMB,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    if battle.pbRandom(100) < 30 && !target.fainted?
      battle.pbShowAbilitySplash(target)
      target.pbUseMoveSimple(:EXPLOSION,user.index)
      battle.pbHideAbilitySplash(target)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:VINECOILSTYLE,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.effects[PBEffects::Trapping] > 0
    battle.pbShowAbilitySplash(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.effects[PBEffects::Trapping] = 5
      user.effects[PBEffects::TrappingMove] = :WRAP
      user.effects[PBEffects::TrappingUser] = target.index
      battle.pbDisplay(_INTL("{1} was trapped!", user.pbThis))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:VOODOO,
  proc { |ability,user,target,move,battle|
    # Collect all battlers of the same egg group
    targetBattlers = []
    battle.eachBattler do |b|
      next if b.index == target.index
      # Validates that b and target share at least one egg group
      next if b.pokemon.species_data.egg_groups.intersection(target.pokemon.species_data.egg_groups).length == 0
      targetBattlers.push(b)
    end
    next if targetBattlers.length == 0
    # Do damage effect
    battle.pbShowAbilitySplash(target)
    targetBattlers.each do |b|
      battle.scene.pbDamageAnimation(b)
      b.pbReduceHP(target.damageState.calcDamage, false)
      b.pbFaint if b.fainted?
    end
    battle.pbDisplay(_INTL("{1} shared its damage with other Pokemon on the field!", target.pbThis))
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:FRAGRANCE,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100) >= 30
    atk_stat = move.pbSpecialMove?(user) ? :SPECIAL_ATTACK : :ATTACK
    next if !user.pbCanLowerStatStage?(atk_stat, target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.pbLowerStatStageByAbility(atk_stat, 1, target)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:COUNTERPARRY,
  proc { |ability,user,target,move,battle|
    next if !move.pbPhysicalMove?(user)
    target.effects[PBEffects::CounterParry] = true
  }
)

BattleHandlers::TargetAbilityOnHit.add(:DELIRIUM,
  proc { |ability,user,target,move,battle|
    next if !target.isSpecies?(:NEBULANIAN) || target.form == 1
    next if !Effectiveness.super_effective?(target.damageState.typeMod)
    battle.pbShowAbilitySplash(target)
    target.pbChangeForm(1, _INTL("{1} became angry!", target.pbThis))
    battle.pbHideAbilitySplash(target)
  }
)

#===============================================================================
# UserAbilityOnHit handlers
#===============================================================================

BattleHandlers::UserAbilityOnHit.add(:POISONTOUCH,
  proc { |ability,user,target,move,battle|
    next if !move.contactMove?
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanPoison?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!",user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbPoison(user,msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FORESTFIRE,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if move.calcType != :GRASS
    battle.pbShowAbilitySplash(user)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} added extra fire damage!",user.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} added extra fire damage!",user.pbThis,user.abilityName))
    end
    user.pbUseMoveSimple(:FORESTFIREATTACK,target.index)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:ENTANGLINGMESS,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(10) < 5
    next if target.effects[PBEffects::Trapping]>0
    battle.pbShowAbilitySplash(user)
    # Set trapping effect duration and info
    target.effects[PBEffects::Trapping] = 2+battle.pbRandom(2)
    target.effects[PBEffects::TrappingMove] = :BIND
    target.effects[PBEffects::TrappingUser] = user.index
    battle.pbDisplay(_INTL("{1} was squeezed by {2}!",target.pbThis,user.pbThis(true)))
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:MADNESS,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(10) < 5
    battle.pbShowAbilitySplash(user)
    if target.pbCanConfuse?(user)
      target.pbConfuse(_INTL("{1} confused {2}!",user.pbThis,target.pbThis(true)))
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:PHILANTHROPIST,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(10) < 5
    if target.status != PBStatuses::NONE
      battle.pbShowAbilitySplash(user)
      target.pbCureStatus
      battle.pbHideAbilitySplash(user)
    end
  }
)

BattleHandlers::UserAbilityOnHit.add(:TAINTEDPOWER,
  proc { |ability,user,target,move,battle|
    next if !move.pbDamagingMove?
    battle.pbShowAbilitySplash(user)
    battle.scene.pbDamageAnimation(user)
    user.pbReduceHP(user.totalhp/8)
    battle.pbDisplay(_INTL("{1} was hurt by its Tainted Power!",user.pbThis))
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:REVERB,
  proc { |ability,user,target,move,battle|
    next if !move.pbDamagingMove?
    next if move.calcType != :SOUND && !move.pbSoundMove?(user)
    target.effects[PBEffects::ReverbDamage] += target.damageState.calcDamage * 0.3
    target.effects[PBEffects::ReverbDamage] = 1 if target.effects[PBEffects::ReverbDamage] < 1
  }
)

BattleHandlers::UserAbilityOnHit.add(:BATTLESTANCE,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !user.pbCanRaiseStatStage?(:ATTACK, user)
    user.pbRaiseStatStageByAbility(:ATTACK, 1, user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:ROARINGHORN,
  proc { |ability,user,target,move,battle|
    next if move.pbTarget(user).num_targets > 1
    next if !user.opposes?(target)
    battle.eachSameSideBattler(target.index) do |b|
      next if b.index != target.index + 2 && b.index != target.index - 2
      next if !b.takesIndirectDamage?
      battle.pbShowAbilitySplash(user)
      battle.pbDisplay(_INTL("{1} took damage from the impact!",b.pbThis))
      battle.scene.pbDamageAnimation(b)
      b.pbReduceHP(target.damageState.calcDamage/2)
      b.pbFaint if b.fainted?
      battle.pbHideAbilitySplash(user)
    end
  }
)

BattleHandlers::UserAbilityOnHit.add(:BLAST,
  proc { |ability,user,target,move,battle|
    next if !user.opposes?(target)
    target.effects[PBEffects::BlastUsers].push(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SPICETANK,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :POISON
    next if !target.pbCanBurn?(user, false)
    next if battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(user)
    target.pbBurn(user)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SLOPPY,
  proc { |ability,user,target,move,battle|
    next if !move.pbPhysicalMove?(user)
    chance = battle.pbRandom(100)
    # 50% chance to do nothing
    if chance < 25 # Random stat down (25%)
      randomDown = []
      GameData::Stat.each_battle do |s|
        randomDown.push(s.id) if target.pbCanLowerStatStage?(s.id, user)
      end
      next if randomDown.length==0
      r = battle.pbRandom(randomDown.length)
      target.pbLowerStatStageByAbility(randomDown[r],1,user)
    elsif chance < 50 # Random status (25%)
      whatStatusCondition = rand(7)
      case whatStatusCondition
      when 0
        if target.pbCanSleep?(user,false)
          battle.pbShowAbilitySplash(user)
          target.pbSleep
          battle.pbHideAbilitySplash(user)
        end
      when 1
        if target.pbCanPoison?(user,false)
          battle.pbShowAbilitySplash(user)
          target.pbPoison(user)
          battle.pbHideAbilitySplash(user)
        end
      when 2
        if target.pbCanBurn?(user,false)
          battle.pbShowAbilitySplash(user)
          target.pbBurn(user)
          battle.pbHideAbilitySplash(user)
        end
      when 3
        if target.pbCanParalyze?(user,false)
          battle.pbShowAbilitySplash(user)
          target.pbParalyze(user)
          battle.pbHideAbilitySplash(user)
        end
      when 4
        if target.pbCanFreeze?(user,false)
          battle.pbShowAbilitySplash(user)
          target.pbFreeze
          battle.pbHideAbilitySplash(user)
        end
      when 5
        if target.pbCanConfuse?(user,false)
          battle.pbShowAbilitySplash(user)
          target.pbConfuse
          battle.pbHideAbilitySplash(user)
        end
      when 6
        if target.pbCanAttract?(user,false)
          battle.pbShowAbilitySplash(user)
          target.pbAttract(user)
          battle.pbHideAbilitySplash(user)
        end
      end
    end
  }
)

BattleHandlers::UserAbilityOnHit.add(:VICTORYRUSH,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    battle.pbShowAbilitySplash(user)
    battle.pbDisplay(_INTL("{1} is on its {2}!", user.pbThis, user.abilityName))
    user.effects[PBEffects::VictoryRush] = true
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SOUNDWAVES,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :SOUND && !move.pbSoundMove?(user)
    next if battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(user)
    if target.pbCanLowerStatStage?(:DEFENSE, user)
      target.pbLowerStatStageByAbility(:DEFENSE, 1, user, false)
    end
    if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user)
      target.pbLowerStatStageByAbility(:SPECIAL_DEFENSE, 1, user, false)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SUPERNOVA,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :COSMIC
    battle.pbShowAbilitySplash(user)
    user.pbUseMoveSimple(:SUPERNOVAATTACK)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:LIQUIDCONDUCTION,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :WATER
    next if battle.pbRandom(100) >= 20
    next if !target.pbCanParalyze?(user, false)
    battle.pbShowAbilitySplash(user)
    target.pbParalyze(user)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:HEALTHYDIET,
  proc { |ability,user,target,move,battle|
    next if !move.bitingMove?
    next if !user.canHeal?
    battle.pbShowAbilitySplash(user)
    user.pbRecoverHP(target.damageState.hpLost * 0.6)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",user.pbThis,user.abilityName))
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:PUNISHER,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if target.effects[PBEffects::Curse]
    next if battle.pbRandom(100) >= 10
    battle.pbShowAbilitySplash(user)
    battle.pbDisplay(_INTL("{1} laid a curse on {2}!",user.pbThis,target.pbThis(true)))
    target.effects[PBEffects::Curse] = true
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:WHIRLPOOLSTYLE,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if target.effects[PBEffects::Trapping] > 0
    if user.hasActiveItem?(:GRIPCLAW)
      target.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
    else
      target.effects[PBEffects::Trapping] = 5 + battle.pbRandom(2)
    end
    target.effects[PBEffects::TrappingMove] = :WHIRLPOOL
    target.effects[PBEffects::TrappingUser] = user.index
    battle.pbShowAbilitySplash(user)
    battle.pbDisplay(_INTL("{1} became trapped in a whirlpool vortex!", target.pbThis))
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FRAGRANCE,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100) >= 30
    atk_stat = move.pbSpecialMove?(user) ? :SPECIAL_ATTACK : :ATTACK
    next if !target.pbCanLowerStatStage?(atk_stat, user)
    target.pbLowerStatStageByAbility(atk_stat, 1, user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:CRYSTALSTINGER,
  proc { |ability,user,target,move,battle|
    next if !user.takesIndirectDamage?
    battle.pbShowAbilitySplash(user)
    battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    battle.scene.pbDamageAnimation(user,0)
    user.pbReduceHP(target.damageState.calcDamage/2)
    user.pbFaint if user.fainted?
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# UserAbilityEndOfMove handlers
#===============================================================================

BattleHandlers::UserAbilityEndOfMove.add(:BEASTBOOST,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0
    userStats = user.plainStats
    highestStatValue = 0
    userStats.each_value { |value| highestStatValue = value if highestStatValue < value }
    GameData::Stat.each_main_battle do |s|
      next if userStats[s.id] < highestStatValue
      if user.pbCanRaiseStatStage?(s.id, user)
        user.pbRaiseStatStageByAbility(s.id, numFainted, user)
      end
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MAGICIAN,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if user.item
    next if battle.wildBattle? && user.opposes?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      user.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true
      if battle.wildBattle? && !user.initialItem && user.item == b.initialItem
        user.setInitialItem(user.item)
        b.setInitialItem(nil)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,
           b.pbThis(true),user.itemName))
      else
        battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",user.pbThis,
           b.pbThis(true),user.itemName,user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      user.pbHeldItemTriggerCheck
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MOXIE,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:ATTACK,user)
    user.pbRaiseStatStageByAbility(:ATTACK,numFainted,user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:TRICKSTER,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if !move.pbContactMove?(user)
    next if battle.wildBattle? && user.opposes?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if user.item==0 && b.item==0
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item) || b.unlosableItem?(user.item) || user.unlosableItem?(user.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD) && !battle.moldBreaker
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be swapped!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      oldUserItem = user.item;     oldUserItemName = user.itemName
      oldTargetItem = b.item; oldTargetItemName = b.itemName
      user.item                             = oldTargetItem
      user.effects[PBEffects::ChoiceBand]   = nil
      user.effects[PBEffects::Unburden]     = (!user.item && oldUserItem)
      b.item                           = oldUserItem
      b.effects[PBEffects::ChoiceBand] = nil
      b.effects[PBEffects::Unburden]   = (!b.item && oldTargetItem)
      # Permanently steal the item from wild Pokémon
      if battle.wildBattle? && b.opposes? && b.initialItem == oldTargetItem && !user.initialItem
        user.setInitialItem(oldTargetItem)
      end
      battle.pbDisplay(_INTL("{1} switched items with its opponent!",user.pbThis))
      battle.pbDisplay(_INTL("{1} obtained {2}.",user.pbThis,oldTargetItemName)) if oldTargetItem
      battle.pbDisplay(_INTL("{1} obtained {2}.",b.pbThis,oldUserItemName)) if oldUserItem
      battle.pbHideAbilitySplash(user)
      user.pbHeldItemTriggerCheck
      b.pbHeldItemTriggerCheck
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:OPPORTUNIST,
  proc { |ability,user,targets,move,battle|
    next if move.accuracy == 0
    # Validate that all targets were unaffected
    allUnaffected = true
    for b in targets
      allUnaffected = false if !b.damageState.unaffected
    end
    next if !allUnaffected
    # Lower user's defense
    if move.accuracy < 60
      if user.pbCanLowerStatStage?(:DEFENSE, user)
        user.pbLowerStatStageByAbility(:DEFENSE, 2, user)
      end
    elsif move.accuracy < 100
      if user.pbCanLowerStatStage?(:DEFENSE, user)
        user.pbLowerStatStageByAbility(:DEFENSE, 1, user)
      end
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SHARPENER,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove?
    next if !user.pbCanRaiseStatStage?(:ATTACK, user)
    user.pbRaiseStatStageByAbility(:ATTACK, 1, user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:HUNGRY,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if !move.pbContactMove?(user)
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      old_user_item = user.item
      old_target_item = b.item
      if user.item
        user.effects[PBEffects::HungryItems].push(b.item)
      else
        user.item = b.item
      end
      b.item = nil
      b.effects[PBEffects::Unburden] = true
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} ate and stored {2}'s {3}!",user.pbThis,
           b.pbThis(true),old_target_item.name))
      else
        battle.pbDisplay(_INTL("{1} ate and stored {2}'s {3} with {4}!",user.pbThis,
           b.pbThis(true),old_target_item.name,user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      user.pbHeldItemTriggerCheck if !old_user_item
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MASTERTHIEF,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if !move.pbContactMove?(user)
    next if battle.wildBattle? && user.opposes?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      # Steal item
      if !user.item
        user.item = b.item
        b.item = nil
        b.effects[PBEffects::Unburden] = true
        if battle.wildBattle? && !user.initialItem && user.item == b.initialItem
          user.setInitialItem(user.item)
          b.setInitialItem(nil)
        end
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,
            b.pbThis(true),user.itemName))
        else
          battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",user.pbThis,
            b.pbThis(true),user.itemName,user.abilityName))
        end
        battle.pbHideAbilitySplash(user)
        user.pbHeldItemTriggerCheck
      # Knock off item
      else
        old_target_item = b.item
        b.item = nil
        b.effects[PBEffects::Unburden] = true
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1} knocked off {2}'s {3}!",user.pbThis,
            b.pbThis(true),old_target_item.name))
        else
          battle.pbDisplay(_INTL("{1} knocked off {2}'s {3} with {4}!",user.pbThis,
            b.pbThis(true),old_target_item.name,user.abilityName))
        end
        battle.pbHideAbilitySplash(user)
      end
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:WONDERHARP,
  proc { |ability,user,targets,move,battle|
    next if move.calcType != :SOUND && !move.pbSoundMove?(user)
    battle.pbShowAbilitySplash(user)
    battle.eachSameSideBattler(user.index) do |b|
      if b.pbCanRaiseStatStage?(:DEFENSE, user)
        b.pbRaiseStatStage(:DEFENSE, 1, user)
      end
      if b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user)
        b.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, user)
      end
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:OVERCHARGED,
  proc { |ability,user,targets,move,battle|
    if move.calcType == :ELECTRIC && move.pbDamagingMove?
      if user.effects[PBEffects::Overcharged] > 0
        user.effects[PBEffects::Overcharged] = 0
        battle.pbShowAbilitySplash(user)
        battle.pbDisplay(_INTL("{1} discharged its stored up energy!", user.pbThis))
        battle.pbHideAbilitySplash(user)
      end
    elsif user.effects[PBEffects::Overcharged] < 3
      user.effects[PBEffects::Overcharged] += 1
      battle.pbShowAbilitySplash(user)
      battle.pbDisplay(_INTL("{1} stored up energy!", user.pbThis))
      battle.pbHideAbilitySplash(user)
    end
  }
)

#===============================================================================
# TargetAbilityAfterMoveUse handlers
#===============================================================================

BattleHandlers::TargetAbilityAfterMoveUse.add(:BERSERK,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if target.damageState.initialHP<target.totalhp/2 || target.hp>=target.totalhp/2
    next if !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
    target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:COLORCHANGE,
  proc { |ability,target,user,move,switched,battle|
    next if target.damageState.calcDamage==0 || target.damageState.substitute
    next if !move.calcType || GameData::Type.get(move.calcType).pseudo_type
    next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
    typeName = GameData::Type.get(move.calcType).name
    battle.pbShowAbilitySplash(target)
    target.pbChangeTypes(move.calcType)
    battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
       target.abilityName,typeName))
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:PICKPOCKET,
  proc { |ability,target,user,move,switched,battle|
    # NOTE: According to Bulbapedia, this can still trigger to steal the user's
    #       item even if it was switched out by a Red Card. This doesn't make
    #       sense, so this code doesn't do it.
    next if battle.wildBattle? && target.opposes?
    next if !move.contactMove?
    next if switched.include?(user.index)
    next if user.effects[PBEffects::Substitute]>0 || target.damageState.substitute
    next if target.item || !user.item
    next if user.unlosableItem?(user.item) || target.unlosableItem?(user.item)
    battle.pbShowAbilitySplash(target)
    if user.hasActiveAbility?(:STICKYHOLD)
      battle.pbShowAbilitySplash(user) if target.opposes?(user)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",user.pbThis))
      end
      battle.pbHideAbilitySplash(user) if target.opposes?(user)
      battle.pbHideAbilitySplash(target)
      next
    end
    target.item = user.item
    user.item = nil
    user.effects[PBEffects::Unburden] = true
    if battle.wildBattle? && !target.initialItem && target.item == user.initialItem
      target.setInitialItem(target.item)
      user.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
       user.pbThis(true),target.itemName))
    battle.pbHideAbilitySplash(target)
    target.pbHeldItemTriggerCheck
  }
)

#===============================================================================
# EORWeatherAbility handlers
#===============================================================================

BattleHandlers::EORWeatherAbility.add(:DRYSKIN,
  proc { |ability,weather,battler,battle|
    case weather
    when :Sun, :HarshSun
      battle.pbShowAbilitySplash(battler)
      battle.scene.pbDamageAnimation(battler)
      battler.pbReduceHP(battler.totalhp/8,false)
      battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
      battler.pbItemHPHealCheck
    when :Rain, :HeavyRain, :Thunderstorm
      next if !battler.canHeal?
      battle.pbShowAbilitySplash(battler)
      battler.pbRecoverHP(battler.totalhp/8)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EORWeatherAbility.add(:ICEBODY,
  proc { |ability,weather,battler,battle|
    next unless weather == :Hail
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:RAINDISH,
  proc { |ability,weather,battler,battle|
    next unless [:Rain, :HeavyRain, :Thunderstorm].include?(weather)
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:SOLARPOWER,
  proc { |ability,weather,battler,battle|
    next unless [:Sun, :HarshSun].include?(weather)
    battle.pbShowAbilitySplash(battler)
    battle.scene.pbDamageAnimation(battler)
    battler.pbReduceHP(battler.totalhp/8,false)
    battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    battler.pbItemHPHealCheck
  }
)

BattleHandlers::EORWeatherAbility.add(:LIGHTGUARD,
  proc { |ability,weather,battler,battle|
    next unless [:HarshSun].include?(weather)
    battle.pbShowAbilitySplash(battler)
    if battler.pbCanRaiseStatStage?(:DEFENSE, battler)
      battler.pbRaiseStatStageByAbility(:DEFENSE, 1, battler, false)
    end
    if battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
      battler.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE, 1, battler, false)
    end
    battler.pbCureStatus
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:RAINBOON,
  proc { |ability,weather,battler,battle|
    next unless [:Rain, :HeavyRain, :Thunderstorm].include?(weather)
    stats = []
    GameData::Stat.each_battle do |s|
      stats.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler)
    end
    next if stats.length == 0
    battler.pbRaiseStatStageByAbility(stats[battle.pbRandom(stats.length)], 1, battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:WEATHERBENEFIT,
  proc { |ability,weather,battler,battle|
    stat = nil
    case weather
    when :Sun, :HarshSun
      stat = :ATTACK
    when :Rain, :HeavyRain, :Thunderstorm
      stat = :SPECIAL_ATTACK
    when :Sandstorm
      stat = :DEFENSE
    when :Hail
      stat = :SPECIAL_DEFENSE
    when :StrongWinds, :Windstorm
      stat = :SPEED
    end
    if stat && battler.pbCanRaiseStatStage?(stat, battler)
      battler.pbRaiseStatStageByAbility(stat, 1, battler)
    end
  }
)

#===============================================================================
# EORHealingAbility handlers
#===============================================================================

BattleHandlers::EORHealingAbility.add(:HEALER,
  proc { |ability,battler,battle|
    next unless battle.pbRandom(100)<30
    battler.eachAlly do |b|
      next if b.status == :NONE
      battle.pbShowAbilitySplash(battler)
      oldStatus = b.status
      b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        case oldStatus
        when :SLEEP
          battle.pbDisplay(_INTL("{1}'s {2} woke its partner up!",battler.pbThis,battler.abilityName))
        when :POISON
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's poison!",battler.pbThis,battler.abilityName))
        when :BURN
          battle.pbDisplay(_INTL("{1}'s {2} healed its partner's burn!",battler.pbThis,battler.abilityName))
        when :PARALYSIS
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's paralysis!",battler.pbThis,battler.abilityName))
        when :FROZEN
          battle.pbDisplay(_INTL("{1}'s {2} defrosted its partner!",battler.pbThis,battler.abilityName))
        end
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EORHealingAbility.add(:HYDRATION,
  proc { |ability,battler,battle|
    next if battler.status == :NONE
    next if ![:Rain, :HeavyRain, :Thunderstorm].include?(battle.pbWeather)
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
      when :POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poison!",battler.pbThis,battler.abilityName))
      when :BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
      when :FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:SHEDSKIN,
  proc { |ability,battler,battle|
    next if battler.status == :NONE
    next unless battle.pbRandom(100)<30
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
      when :POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poison!",battler.pbThis,battler.abilityName))
      when :BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
      when :FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:DEEPSLEEPER,
  proc { |ability,battler,battle|
    next if !battler.asleep? || battler.hp == battler.totalhp
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/8)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:SYNTHESIZE,
  proc { |ability,battler,battle|
    next if !battler.canHeal?
    choice = battle.choices[battler.index]
    next if choice[0] == :UseMove && (choice[2].pbDamagingMove? || choice[2].healingMove?)
    next if [:Rain, :HeavyRain, :Thunderstorm].include?(battle.pbWeather)
    next if battle.field.effects[PBEffects::Darkened]
    next if PBDayNight.isNight?
    battle.pbShowAbilitySplash(battler)
    healfactor = [:Sun, :HarshSun].include?(battle.pbWeather) ? 8 : 16
    battler.pbRecoverHP(battler.totalhp/healfactor)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:SOOTHINGSHINE,
  proc { |ability,battler,battle|
    # Validates if any battlers on same side need healing
    canHealAnyBattler = false
    battle.eachSameSideBattler(battler.index) do |b|
      canHealAnyBattler = true if b.canHeal?
    end
    next if !canHealAnyBattler
    # Ability effect
    battle.pbShowAbilitySplash(battler)
    healfactor = [:Sun, :HarshSun].include?(battle.pbWeather) ? 8 : 16
    battle.eachSameSideBattler(battler.index) do |b|
      next if !b.canHeal?
      b.pbRecoverHP(b.totalhp/healfactor)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s HP.",battler.pbThis,battler.abilityName,b.pbThis(true)))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:ADDITION,
  proc { |ability,battler,battle|
    # Validates if any battlers on same side need healing
    canHealAnyBattler = false
    battle.eachSameSideBattler(battler.index) do |b|
      canHealAnyBattler = true if b.canHeal?
    end
    next if !canHealAnyBattler
    # Ability effect
    hasSubtraction = false
    battle.eachSameSideBattler(battler.index) do |b|
      hasSubtraction = true if b.hasActiveAbility?(:SUBTRACTION)
    end
    battle.pbShowAbilitySplash(battler)
    healmult = hasSubtraction ? 0.3 : 0.1
    battle.eachSameSideBattler(battler.index) do |b|
      next if !b.canHeal?
      b.pbRecoverHP(b.totalhp * healmult)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s HP.",battler.pbThis,battler.abilityName,b.pbThis(true)))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# EOREffectAbility handlers
#===============================================================================

BattleHandlers::EOREffectAbility.add(:BADDREAMS,
  proc { |ability,battler,battle|
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler) || !b.asleep?
      battle.pbShowAbilitySplash(battler)
      next if !b.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldHP = b.hp
      b.pbReduceHP(b.totalhp/8)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is tormented!",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is tormented by {2}'s {3}!",b.pbThis,
           battler.pbThis(true),battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
  }
)

BattleHandlers::EOREffectAbility.add(:SWEETDREAMS,
  proc { |ability,battler,battle|
    battle.eachSameSideBattler(battler.index) do |b|
      next if !b.near?(battler) || !b.asleep?
      next if !b.canHeal?
      battle.pbShowAbilitySplash(battler)
      b.pbRecoverHP(b.totalhp/8)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is having a nice dream!",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is having a nice dream thanks to {2}'s {3}!",b.pbThis,
           battler.pbThis(true),battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EOREffectAbility.add(:MOODY,
  proc { |ability,battler,battle|
    randomUp = []
    randomDown = []
    GameData::Stat.each_battle do |s|
      randomUp.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler)
      randomDown.push(s.id) if battler.pbCanLowerStatStage?(s.id, battler)
    end
    next if randomUp.length==0 && randomDown.length==0
    battle.pbShowAbilitySplash(battler)
    if randomUp.length>0
      r = battle.pbRandom(randomUp.length)
      battler.pbRaiseStatStageByAbility(randomUp[r],2,battler,false)
      randomDown.delete(randomUp[r])
    end
    if randomDown.length>0
      r = battle.pbRandom(randomDown.length)
      battler.pbLowerStatStageByAbility(randomDown[r],1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
    battler.pbItemStatRestoreCheck if randomDown.length>0
  }
)

BattleHandlers::EOREffectAbility.add(:SPEEDBOOST,
  proc { |ability,battler,battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount>0 && battler.pbCanRaiseStatStage?(:SPEED,battler)
      battler.pbRaiseStatStageByAbility(:SPEED,1,battler)
    end
  }
)

BattleHandlers::EOREffectAbility.add(:SIGNALBOOST,
  proc { |ability,battler,battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount>0 && battler.pbCanRaiseStatStage?(:ACCURACY,battler)
      battler.pbRaiseStatStageByAbility(:ACCURACY,1,battler)
    end
  }
)

BattleHandlers::EOREffectAbility.add(:ALLSEEING,
  proc { |ability,battler,battle|
    battle.eachOtherSideBattler(battler.index) do |b|
      if b.near?(battler) && b.pbCanLowerStatStage?(:EVASION,battler)
        b.pbLowerStatStageByAbility(:EVASION,1,battler)
      end
    end
  }
)

BattleHandlers::EOREffectAbility.add(:VICTORYRUSH,
  proc { |ability,battler,battle|
    next if !battler.effects[PBEffects::VictoryRush]
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s {2} ended!", battler.pbThis, battler.abilityName))
    battler.effects[PBEffects::VictoryRush] = false
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:DYNAMICPOWER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.effects[PBEffects::DynamicPower] += 1
    battle.pbDisplay(_INTL("{1}'s base stats increased!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:COUNTERPARRY,
  proc { |ability,battler,battle|
    battler.effects[PBEffects::CounterParry] = false
  }
)

BattleHandlers::EOREffectAbility.add(:SOULABSORB,
  proc { |ability,battler,battle|
    next if !battler.canHeal?
    # Get number of affected battlers
    battlerCount = 0
    battle.eachBattler do |b|
      next if b.index == battler.index
      next if !b.takesIndirectDamage?
      battlerCount += 1
    end
    # Calculate hp drain per battler
    totalHPDrain = battle.singleBattle? ? battler.totalhp/4 : battler.totalhp/2
    hpDrain = totalHPDrain / battlerCount
    # Do damage and heal ability user
    battle.pbShowAbilitySplash(battler)
    battle.eachBattler do |b|
      next if b.index == battler.index
      next if !b.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldHP = b.hp
      b.pbReduceHP(hpDrain)
      battler.pbRecoverHP(hpDrain) if battler.canHeal?
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} absorbed {2}'s HP!",battler.pbThis,b.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1} absorbed {2}'s HP with {3}!",battler.pbThis,
           b.pbThis(true),battler.abilityName))
      end
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:GLEAMINGGLARE,
  proc { |ability,battler,battle|
    next if battle.pbRandom(100) >= 10
    # Validate if any opponents can be paralyzed
    targets = []
    battler.eachOpposing do |b|
      targets.push(b) if b.pbCanParalyze?(battler, false)
    end
    next if targets.length == 0
    # Paralyze a random foe
    paralyzedBattler = targets[battle.pbRandom(targets.length)]
    battle.pbShowAbilitySplash(battler)
    paralyzedBattler.pbParalyze(battler)
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# EORGainItemAbility handlers
#===============================================================================

BattleHandlers::EORGainItemAbility.add(:HARVEST,
  proc { |ability,battler,battle|
    next if battler.item
    next if !battler.recycleItem || !GameData::Item.get(battler.recycleItem).is_berry?
    if ![:Sun, :HarshSun].include?(battle.pbWeather)
      next unless battle.pbRandom(100)<50
    end
    battle.pbShowAbilitySplash(battler)
    battler.item = battler.recycleItem
    battler.setRecycleItem(nil)
    battler.setInitialItem(battler.item) if !battler.initialItem
    battle.pbDisplay(_INTL("{1} harvested one {2}!",battler.pbThis,battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

BattleHandlers::EORGainItemAbility.add(:PICKUP,
  proc { |ability,battler,battle|
    next if battler.item
    foundItem = nil; fromBattler = nil; use = 0
    battle.eachBattler do |b|
      next if b.index==battler.index
      next if b.effects[PBEffects::PickupUse]<=use
      foundItem   = b.effects[PBEffects::PickupItem]
      fromBattler = b
      use         = b.effects[PBEffects::PickupUse]
    end
    next if !foundItem
    battle.pbShowAbilitySplash(battler)
    battler.item = foundItem
    fromBattler.effects[PBEffects::PickupItem] = nil
    fromBattler.effects[PBEffects::PickupUse]  = 0
    fromBattler.setRecycleItem(nil) if fromBattler.recycleItem==foundItem
    if battle.wildBattle? && !battler.initialItem && fromBattler.initialItem==foundItem
      battler.setInitialItem(foundItem)
      fromBattler.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1} found one {2}!",battler.pbThis,battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

#===============================================================================
# CertainSwitchingUserAbility handlers
#===============================================================================

# There aren't any!

#===============================================================================
# TrappingTargetAbility handlers
#===============================================================================

BattleHandlers::TrappingTargetAbility.add(:ARENATRAP,
  proc { |ability,switcher,bearer,battle|
    next true if !switcher.airborne?
  }
)

BattleHandlers::TrappingTargetAbility.add(:MAGNETPULL,
  proc { |ability,switcher,bearer,battle|
    next true if switcher.pbHasType?(:STEEL)
  }
)

BattleHandlers::TrappingTargetAbility.add(:SHADOWTAG,
  proc { |ability,switcher,bearer,battle|
    next true if !switcher.hasActiveAbility?(:SHADOWTAG)
  }
)

#===============================================================================
# AbilityOnSwitchIn handlers
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:AIRLOCK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} has {2}!",battler.pbThis,battler.abilityName))
    end
    battle.pbDisplay(_INTL("The effects of the weather disappeared."))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:AIRLOCK,:CLOUDNINE)

BattleHandlers::AbilityOnSwitchIn.add(:ANTICIPATION,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    battlerTypes = battler.pbTypes(true)
    type1 = battlerTypes[0]
    type2 = battlerTypes[1] || type1
    type3 = battlerTypes[2] || type2
    found = false
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        next if m.statusMove?
        if type1
          moveType = m.type
          if Settings::MECHANICS_GENERATION >= 6 && m.function == "090"   # Hidden Power
            moveType = pbHiddenPower(b.pokemon)[0]
          end
          eff = Effectiveness.calculate(moveType,type1,type2,type3)
          next if Effectiveness.ineffective?(eff)
          next if !Effectiveness.super_effective?(eff) && m.function != "070"   # OHKO
        else
          next if m.function != "070"   # OHKO
        end
        found = true
        break
      end
      break if found
    end
    if found
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} shuddered with anticipation!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:AURABREAK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:COMATOSE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is drowsing!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DARKAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a dark aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DELTASTREAM,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:StrongWinds, battler, battle, true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DESOLATELAND,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:HarshSun, battler, battle, true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DOWNLOAD,
  proc { |ability,battler,battle|
    oDef = oSpDef = 0
    battle.eachOtherSideBattler(battler.index) do |b|
      oDef   += b.defense
      oSpDef += b.spdef
    end
    stat = (oDef<oSpDef) ? :ATTACK : :SPECIAL_ATTACK
    battler.pbRaiseStatStageByAbility(stat,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DRIZZLE,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Rain, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DROUGHT,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Sun, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ELECTRICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Electric
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Electric)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FAIRYAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a fairy aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FOREWARN,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    highestPower = 0
    forewarnMoves = []
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        power = m.baseDamage
        power = 160 if ["070"].include?(m.function)    # OHKO
        power = 150 if ["08B"].include?(m.function)    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["071","072","073"].include?(m.function)
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["06A","06B","06D","06E","06F",
                       "089","08A","08C","08D","090",
                       "096","097","098","09A"].include?(m.function)
        next if power<highestPower
        forewarnMoves = [] if power>highestPower
        forewarnMoves.push(m.name)
        highestPower = power
      end
    end
    if forewarnMoves.length>0
      battle.pbShowAbilitySplash(battler)
      forewarnMoveName = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} was alerted to {2}!",
          battler.pbThis, forewarnMoveName))
      else
        battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",
          battler.pbThis, forewarnMoveName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FRISK,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    foes = []
    battle.eachOtherSideBattler(battler.index) do |b|
      foes.push(b) if b.item
    end
    if foes.length>0
      battle.pbShowAbilitySplash(battler)
      if Settings::MECHANICS_GENERATION >= 6
        foes.each do |b|
          battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",
             battler.pbThis,b.pbThis(true),b.itemName))
        end
      else
        foe = foes[battle.pbRandom(foes.length)]
        battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",
           battler.pbThis,foe.itemName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GRASSYSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Grassy
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Grassy)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:IMPOSTER,
  proc { |ability,battler,battle|
    next if battler.effects[PBEffects::Transform]
    choice = battler.pbDirectOpposing
    next if choice.fainted?
    next if choice.effects[PBEffects::Transform] ||
            choice.effects[PBEffects::Illusion] ||
            choice.effects[PBEffects::Substitute]>0 ||
            choice.effects[PBEffects::SkyDrop]>=0 ||
            choice.semiInvulnerable?
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    battle.pbAnimation(:TRANSFORM,battler,choice)
    battle.scene.pbChangePokemon(battler,choice.pokemon)
    battler.pbTransform(choice)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:INTIMIDATE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerAttackStatStageIntimidate(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MISTYSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Misty
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Misty)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MOLDBREAKER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} breaks the mold!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRESSURE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is exerting its pressure!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRIMORDIALSEA,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:HeavyRain, battler, battle, true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PSYCHICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Psychic
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Psychic)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SANDSTREAM,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Sandstorm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SLOWSTART,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.effects[PBEffects::SlowStart] = 5
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} can't get it going!",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} can't get it going because of its {2}!",
         battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SNOWWARNING,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Hail, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TERAVOLT,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a bursting aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TURBOBLAZE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a blazing aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:UNNERVE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!",battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TEMPERMENTAL,
  proc { |ability,battler,battle|
    next if !battler.pbCanConfuseSelf?(false)
    battle.pbShowAbilitySplash(battler)
    battler.pbConfuseSelf
    battler.pbRaiseStatStageByAbility(:ATTACK,2,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MIRRORTYPE,
  proc { |ability,battler,battle|
    targets = []
    battle.eachOtherSideBattler(battler.index) {|b| targets.push(b)}
    if targets.length > 0
      target = targets[rand(targets.length)]
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} copied {2}'s types!",battler.pbThis,target.pbThis(true)))
      battler.pbChangeTypes(target)
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MYSTERYTYPE,
  proc { |ability,battler,battle|
    types = []
    GameData::Type.each do |i|
      types.push(i) if i != :QMARKS
    end
    type = types[rand(types.length)]
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} changed into the {2} type!",battler.pbThis,GameData::Type.get(type).name))
    battler.pbChangeTypes(type)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:RETEXTURING,
  proc { |ability,battler,battle|
    opps = []
    battler.eachOpposing do |b|
      opps.push(b)
    end
    next if opps.length == 0
    opp = opps[battle.pbRandom(opps.length)]
    restypes = []
    maxrescount = 0
    GameData::Type.each do |i|
      next if i == :QMARKS
      rescount = 0 # Number of opponent's types that this type resists
      for opptype in opp.pbTypes(true)
        rescount += 1 if Effectiveness.resistant_type?(opptype, i)
      end
      if rescount > 0
        restypes.push([i, rescount]) # First element is type, second is resistance count
        maxrescount = rescount if rescount > maxrescount
      end
    end
    restypes.reject! {|type| type[1] != maxrescount}
    newtype = restypes[battle.pbRandom(restypes.length)][0]
    battle.pbShowAbilitySplash(battler)
    battler.pbChangeTypes(newtype)
    battle.pbDisplay(_INTL("{1} changed into the {2} type to resist {3}!",battler.pbThis,GameData::Type.get(newtype).name,opp.pbThis(true)))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ROOTED,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.pbUseMoveExtra(:INGRAIN,battler.index,-1,true)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FERTILEGIFTS,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is ready to share its fertile gifts!", battler.pbThis))
    battle.eachSameSideBattler(battler) do |b|
      next if b.index != battler.index && !b.pbHasType?(:GRASS)
      if b.pbCanRaiseStatStage?(:ATTACK, battler)
        b.pbRaiseStatStage(:ATTACK, 1, battler)
      end
      if b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
        b.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
      end
      if b.canHeal?
        b.pbRecoverHP(b.totalhp/10)
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CRYSTALSURGE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} covered the battlefield with Crystal Energy!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HYPERAROMA,
  proc { |ability,battler,battle|
    battle.pbPriority(true).each do |b|
      next if b.index == battler.index
      next if !b.pbCanAttract?(battler, false)
      next if b.hasActiveAbility?(:HYPERAROMA)
      battle.pbShowAbilitySplash(battler)
      b.pbAttract(battler, _INTL("{1} fell in love with {2}!", b.pbThis, battler.pbThis(true)))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MINDIPULATION,
  proc { |ability,battler,battle|
    battle.eachBattler do |b|
      next if b.index == battler.index
      next if !b.pbCanConfuse?(battler, false)
      next if battle.pbRandom(100) < 50
      battle.pbShowAbilitySplash(battler)
      b.pbConfuse
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:LASTBASTION,
  proc { |ability,battler,battle|
    next if battle.wildBattle? && battler.opposes?
    party = battle.pbParty(battler.index)
    able_pokemon_count = 0
    party.each { |p| able_pokemon_count += 1 if p && !p.egg? && !p.fainted? }
    next if able_pokemon_count > 1
    battle.pbShowAbilitySplash(battler)
    if battler.pbCanRaiseStatStage?(:ATTACK, battler)
      battler.pbRaiseStatStage(:ATTACK, 1, battler)
    end
    if battler.pbCanRaiseStatStage?(:DEFENSE, battler)
      battler.pbRaiseStatStage(:DEFENSE, 1, battler)
    end
    if battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, battler)
      battler.pbRaiseStatStage(:SPECIAL_ATTACK, 1, battler)
    end
    if battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
      battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ALIGNED,
  proc { |ability,battler,battle|
    next if battle.wildBattle? && battler.opposes?
    party = battle.pbParty(battler.index)
    # Calculate number of stat stages to increase
    numStatIncrease = 0
    party.each_with_index { |p, i|
      next if !p || p.egg? || p.fainted?
      next if battler.pokemonIndex == i
      battler.pbTypes.each do |t|
        if p.hasType?(t)
          numStatIncrease += 1
          break
        end
      end
    }
    next if numStatIncrease == 0
    battle.pbShowAbilitySplash(battler)
    # Increase a random stat one-by-one
    for i in 0...numStatIncrease
      randomUp = []
      GameData::Stat.each_battle do |s|
        randomUp.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler)
      end
      break if randomUp.length==0
      r = battle.pbRandom(randomUp.length)
      battler.pbRaiseStatStageByAbility(randomUp[r],1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:BULLY,
  proc { |ability,battler,battle|
    battle.eachOtherSideBattler(battler.index) do |b|
      next if b.pokemon.height > battler.pokemon.height
      next if b.pokemon.height == battler.pokemon.height && battler.pbWeight <= b.pbWeight
      next if !b.pbCanLowerStatStage?(:ATTACK, battler)
      b.pbLowerStatStageByAbility(:ATTACK, 1, battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SUDDENSEED,
  proc { |ability,battler,battle|
    battle.eachOtherSideBattler(battler.index) do |b|
      next if b.effects[PBEffects::LeechSeed] >= 0
      next if b.pbHasType?(:GRASS)
      next if b.effects[PBEffects::Substitute] > 0
      next if b.hasActiveAbility?(:SAPSIPPER)
      battle.pbShowAbilitySplash(battler)
      battle.pbAnimation(:LEECHSEED,battler,b)
      b.effects[PBEffects::LeechSeed] = battler.index
      battle.pbDisplay(_INTL("{1} was seeded!",b.pbThis))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ROCKYTRAP,
  proc { |ability,battler,battle|
    next if battler.pbOpposingSide.effects[PBEffects::StealthRock]
    battle.pbShowAbilitySplash(battler)
    battler.pbOpposingSide.effects[PBEffects::StealthRock] = true
    battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
       battler.pbOpposingTeam(true)))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ROUNDRECORD,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.pbConfuseSelf
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:OUTMATCH,
  proc { |ability,battler,battle|
    next if !battler.pbCanRaiseStatStage?(:SPEED, battler)
    statIncrement = 1
    battler.eachOpposing do |b|
      next if b.pbSpeed <= battler.pbSpeed
      # Enemy is faster
      statIncrement = 2
      break
    end
    battler.pbRaiseStatStageByAbility(:SPEED, statIncrement, battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TEMPEST,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Thunderstorm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CYCLONE,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Windstorm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DEBRISARMOR,
  proc { |ability,battler,battle|
    next if battler.pbOwnSide.effects[PBEffects::Spikes] == 0 &&
            battler.pbOwnSide.effects[PBEffects::ToxicSpikes] == 0 &&
            !battler.pbOwnSide.effects[PBEffects::StealthRock] &&
            battler.pbOwnSide.effects[PBEffects::VoltSpikes] == 0
    battle.pbShowAbilitySplash(battler)
    # Spikes
    if battler.pbOwnSide.effects[PBEffects::Spikes] > 0
      battler.effects[PBEffects::SpikesArmor] = battler.pbOwnSide.effects[PBEffects::Spikes]
      battler.pbOwnSide.effects[PBEffects::Spikes] = 0
      battle.pbDisplay(_INTL("{1} put on Spikes Armor!", battler.pbThis))
    end
    # Toxic Spikes
    if battler.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
      battler.effects[PBEffects::ToxicSpikesArmor] = battler.pbOwnSide.effects[PBEffects::ToxicSpikes]
      battler.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
      battle.pbDisplay(_INTL("{1} put on Toxic Spikes Armor!", battler.pbThis))
    end
    # Stealth Rock
    if battler.pbOwnSide.effects[PBEffects::StealthRock]
      battler.effects[PBEffects::StealthRockArmor] = true
      battler.pbOwnSide.effects[PBEffects::StealthRock] = false
      battle.pbDisplay(_INTL("{1} put on Stealth Rock Armor!", battler.pbThis))
      if battler.pbCanRaiseStatStage?(:DEFENSE, battler)
        battler.pbRaiseStatStageByAbility(:DEFENSE, 1, battler, false)
      end
    end
    # Volt Spikes
    if battler.pbOwnSide.effects[PBEffects::VoltSpikes] > 0
      battler.effects[PBEffects::VoltSpikesArmor] = battler.pbOwnSide.effects[PBEffects::VoltSpikes]
      battler.pbOwnSide.effects[PBEffects::VoltSpikes] = 0
      battle.pbDisplay(_INTL("{1} put on Volt Spikes Armor!", battler.pbThis))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CLEARINGFUMES,
  proc { |ability,battler,battle|
    userSide = battler.pbOwnSide
    targetSide = battler.pbOpposingSide
    # Clear own side hazards
    userSide.effects[PBEffects::StealthRock] = false
    userSide.effects[PBEffects::Spikes] = 0
    userSide.effects[PBEffects::ToxicSpikes] = 0
    userSide.effects[PBEffects::VoltSpikes] = 0
    userSide.effects[PBEffects::StickyWeb] = false
    # Clear opposing side hazards
    targetSide.effects[PBEffects::StealthRock] = false
    targetSide.effects[PBEffects::Spikes] = 0
    targetSide.effects[PBEffects::ToxicSpikes] = 0
    targetSide.effects[PBEffects::VoltSpikes] = 0
    targetSide.effects[PBEffects::StickyWeb] = false
    # Clear all battlers' stat changes
    battle.eachBattler do |b|
      b.pbResetStatStages
    end
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} cleared all hazards and stat changes on the field!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CHILLING,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerSpecialAttackStatStageChilling(battler)
      b.pbItemOnIntimidatedCheck # Copied from Intimidate
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:IMMOVABLE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    if battler.pbCanRaiseStatStage?(:DEFENSE, battler)
      battler.pbRaiseStatStageByAbility(:DEFENSE, 3, battler, false)
    end
    if battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
      battler.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE, 3, battler, false)
    end
    if battler.pbCanLowerStatStage?(:SPEED, battler)
      battler.pbLowerStatStageByAbility(:SPEED, 3, battler, false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:LAVAFLOOR,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Lava
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Lava)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HIVEMIND,
  proc { |ability,battler,battle|
    party = battle.pbParty(battler.index)
    bugCount = 0
    party.each_with_index do |pkmn, i|
      next if battler.pokemonIndex == i
      next if !pkmn.hasType?(:BUG)
      bugCount += 1
    end
    next if bugCount == 0
    battle.pbShowAbilitySplash(battler)
    if battler.pbCanRaiseStatStage?(:ATTACK, battler)
      battler.pbRaiseStatStageByAbility(:ATTACK, bugCount, battler, false)
    end
    if battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, battler)
      battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, bugCount, battler, false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:OMNIGENE,
  proc { |ability,battler,battle|
    # Item type map copied from Judgment move function (09F)
    itemTypes = {
      :FISTPLATE   => :FIGHTING,
      :SKYPLATE    => :FLYING,
      :TOXICPLATE  => :POISON,
      :EARTHPLATE  => :GROUND,
      :STONEPLATE  => :ROCK,
      :INSECTPLATE => :BUG,
      :SPOOKYPLATE => :GHOST,
      :IRONPLATE   => :STEEL,
      :FLAMEPLATE  => :FIRE,
      :SPLASHPLATE => :WATER,
      :MEADOWPLATE => :GRASS,
      :ZAPPLATE    => :ELECTRIC,
      :MINDPLATE   => :PSYCHIC,
      :ICICLEPLATE => :ICE,
      :DRACOPLATE  => :DRAGON,
      :DREADPLATE  => :DARK,
      :PIXIEPLATE  => :FAIRY
    }
    newType = nil
    if battler.itemActive?
      itemTypes.each do |item, itemType|
        next if battler.item != item
        newType = itemType if GameData::Type.exists?(itemType)
        break
      end
    end
    if newType
      battle.pbShowAbilitySplash(battler)
      battler.pbChangeTypes(newType)
      battle.pbDisplay(_INTL("{1} used its {2} to change into the {3} type!",battler.pbThis,battler.itemName,GameData::Type.get(newType).name))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CLAIRVOYANT,
  proc { |ability,battler,battle|
    # Validate that any opponents don't already have a Future Sight counter active
    targets = []
    battler.eachOpposing do |b|
      next if b.fainted?
      next if battle.positions[b.index].effects[PBEffects::FutureSightCounter]>0
      targets.push(b)
    end
    next if targets.length == 0
    # Do Future Sight attack
    randTarget = targets[battle.pbRandom(targets.length)]
    battle.pbShowAbilitySplash(battler)
    battler.pbUseMoveExtra(:FUTURESIGHT, randTarget.index)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CLOAKCONTROL,
  proc { |ability,battler,battle|
    next if battler.opposes?
    next if !battler.pbOwnedByPlayer?
    types = []
    typeNames = []
    GameData::Type.each do |i|
      if i != :QMARKS
        types.push(i)
        typeNames.push(GameData::Type.get(i).name)
      end
    end
    loop do
      battle.scene.pbHideAllDataboxes
      index = battle.scene.pbShowCommands_ebdx(_INTL("Which type should {1} take?",battler.pbThis), typeNames, -1)
      battle.scene.pbShowAllDataboxes
      newType = types[index]
      newTypeName = typeNames[index]
      if index >= 0 && battle.pbDisplayConfirm(_INTL("{1} will become the {2} type. Is this OK?", battler.pbThis, newTypeName))
        battle.pbShowAbilitySplash(battler)
        battle.pbDisplay(_INTL("{1} changed into the {2} type!",battler.pbThis,newTypeName))
        battler.pbChangeTypes(newType)
        battle.pbHideAbilitySplash(battler)
        break
      end
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MAGICSHOW,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} created a bizarre area in which Pokémon's held items lose their effects!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# AbilityOnSwitchOut handlers
#===============================================================================

BattleHandlers::AbilityOnSwitchOut.add(:NATURALCURE,
  proc { |ability,battler,endOfBattle|
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:REGENERATOR,
  proc { |ability,battler,endOfBattle|
    next if endOfBattle
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.pbRecoverHP(battler.totalhp/3,false,false)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:DEBRISARMOR,
  proc { |ability,battler,endOfBattle|
    next if endOfBattle
    # Shed Spikes Armor
    if battler.effects[PBEffects::SpikesArmor] > 0
      battler.pbOwnSide.effects[PBEffects::Spikes] += [battler.effects[PBEffects::SpikesArmor], 3].min
      battler.effects[PBEffects::SpikesArmor] = 0
      battler.battle.pbDisplay(_INTL("{1} shed its Spikes Armor!", battler.pbThis))
    end
    # Shed Toxic Spikes Armor
    if battler.effects[PBEffects::ToxicSpikesArmor] > 0
      battler.pbOwnSide.effects[PBEffects::ToxicSpikes] += [battler.effects[PBEffects::ToxicSpikesArmor], 2].min
      battler.effects[PBEffects::ToxicSpikesArmor] = 0
      battler.battle.pbDisplay(_INTL("{1} shed its Toxic Spikes Armor!", battler.pbThis))
    end
    # Shed Stealth Rock Armor
    if battler.effects[PBEffects::StealthRockArmor]
      battler.pbOwnSide.effects[PBEffects::StealthRock] = true
      battler.effects[PBEffects::StealthRockArmor] = false
      battler.battle.pbDisplay(_INTL("{1} shed its Stealth Rock Armor!", battler.pbThis))
    end
    # Shed Volt Spikes Armor
    if battler.effects[PBEffects::VoltSpikesArmor] > 0
      battler.pbOwnSide.effects[PBEffects::VoltSpikes] += [battler.effects[PBEffects::VoltSpikesArmor], 2].min
      battler.effects[PBEffects::VoltSpikesArmor] = 0
      battler.battle.pbDisplay(_INTL("{1} shed its Volt Spikes Armor!", battler.pbThis))
    end
  }
)

#===============================================================================
# AbilityChangeOnBattlerFainting handlers
#===============================================================================

BattleHandlers::AbilityChangeOnBattlerFainting.add(:POWEROFALCHEMY,
  proc { |ability,battler,fainted,battle|
    next if battler.opposes?(fainted)
    next if fainted.ungainableAbility? ||
       [:POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD, :INCOMPREHENSIBLE].include?(fainted.ability_id)
    battle.pbShowAbilitySplash(battler,true)
    battler.ability = fainted.ability
    battle.pbReplaceAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s {2} was taken over!",fainted.pbThis,fainted.abilityName))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityChangeOnBattlerFainting.copy(:POWEROFALCHEMY,:RECEIVER)

#===============================================================================
# AbilityOnBattlerFainting handlers
#===============================================================================

BattleHandlers::AbilityOnBattlerFainting.add(:SOULHEART,
  proc { |ability,battler,fainted,battle|
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,battler)
  }
)

BattleHandlers::AbilityOnBattlerFainting.add(:LASTBASTION,
  proc { |ability,battler,fainted,battle|
    next if battler.opposes?(fainted)
    next if battle.wildBattle? && battler.opposes?
    party = battle.pbParty(battler.index)
    able_pokemon_count = 0
    party.each { |p| able_pokemon_count += 1 if p && !p.egg? && !p.fainted? }
    next if able_pokemon_count > 1
    battle.pbShowAbilitySplash(battler)
    if battler.pbCanRaiseStatStage?(:ATTACK, battler)
      battler.pbRaiseStatStage(:ATTACK, 1, battler)
    end
    if battler.pbCanRaiseStatStage?(:DEFENSE, battler)
      battler.pbRaiseStatStage(:DEFENSE, 1, battler)
    end
    if battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, battler)
      battler.pbRaiseStatStage(:SPECIAL_ATTACK, 1, battler)
    end
    if battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
      battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnBattlerFainting.add(:EFFULGE,
  proc { |ability,battler,fainted,battle|
    next if !battler.isSpecies?(:KINDESHU)
    next if !battler.opposes?(fainted)
    hp_gain = (battler.totalhp/4) + 1 - battler.hp
    next if hp_gain <= 0
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(hp_gain)
    battler.pbChangeForm(0, nil)
    battle.pbDisplay(_INTL("{1} fed off of {2}'s light energy and recovered HP!", battler.pbThis, fainted.pbThis(true)))
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# RunFromBattleAbility handlers
#===============================================================================

BattleHandlers::RunFromBattleAbility.add(:RUNAWAY,
  proc { |ability,battler|
    next true
  }
)
