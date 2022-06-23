#===============================================================================
#
#===============================================================================
module Battle::AbilityEffects
  SpeedCalc                        = AbilityHandlerHash.new
  WeightCalc                       = AbilityHandlerHash.new
  # Battler's HP/stat changed
  OnHPDroppedBelowHalf             = AbilityHandlerHash.new
  # Battler's status problem
  StatusCheckNonIgnorable          = AbilityHandlerHash.new   # Comatose
  StatusImmunity                   = AbilityHandlerHash.new
  StatusImmunityNonIgnorable       = AbilityHandlerHash.new
  StatusImmunityFromAlly           = AbilityHandlerHash.new
  OnStatusInflicted                = AbilityHandlerHash.new   # Synchronize
  StatusCure                       = AbilityHandlerHash.new
  # Battler's stat stages
  StatLossImmunity                 = AbilityHandlerHash.new
  StatLossImmunityNonIgnorable     = AbilityHandlerHash.new   # Full Metal Body
  StatLossImmunityFromAlly         = AbilityHandlerHash.new   # Flower Veil
  OnStatGain                       = AbilityHandlerHash.new   # None!
  OnStatLoss                       = AbilityHandlerHash.new
  # Priority and turn order
  PriorityChange                   = AbilityHandlerHash.new
  PriorityBracketChange            = AbilityHandlerHash.new   # Stall
  PriorityBracketUse               = AbilityHandlerHash.new   # None!
  # Move usage failures
  OnFlinch                         = AbilityHandlerHash.new   # Steadfast
  MoveBlocking                     = AbilityHandlerHash.new
  MoveImmunity                     = AbilityHandlerHash.new
  # Move usage
  ModifyMoveBaseType               = AbilityHandlerHash.new
  # Accuracy calculation
  AccuracyCalcFromUser             = AbilityHandlerHash.new
  AccuracyCalcFromAlly             = AbilityHandlerHash.new   # Victory Star
  AccuracyCalcFromTarget           = AbilityHandlerHash.new
  # Damage calculation
  DamageCalcFromUser               = AbilityHandlerHash.new
  DamageCalcFromAlly               = AbilityHandlerHash.new
  DamageCalcFromTarget             = AbilityHandlerHash.new
  DamageCalcFromTargetNonIgnorable = AbilityHandlerHash.new
  DamageCalcFromTargetAlly         = AbilityHandlerHash.new
  CriticalCalcFromUser             = AbilityHandlerHash.new
  CriticalCalcFromTarget           = AbilityHandlerHash.new
  # Upon a move hitting a target
  OnBeingHit                       = AbilityHandlerHash.new
  OnDealingHit                     = AbilityHandlerHash.new   # Poison Touch
  # Abilities that trigger at the end of using a move
  OnEndOfUsingMove                 = AbilityHandlerHash.new
  AfterMoveUseFromTarget           = AbilityHandlerHash.new
  # End Of Round
  EndOfRoundWeather                = AbilityHandlerHash.new
  EndOfRoundHealing                = AbilityHandlerHash.new
  EndOfRoundEffect                 = AbilityHandlerHash.new
  EndOfRoundGainItem               = AbilityHandlerHash.new
  # Switching and fainting
  CertainSwitching                 = AbilityHandlerHash.new   # None!
  TrappingByTarget                 = AbilityHandlerHash.new
  OnSwitchIn                       = AbilityHandlerHash.new
  OnSwitchOut                      = AbilityHandlerHash.new
  ChangeOnBattlerFainting          = AbilityHandlerHash.new
  OnBattlerFainting                = AbilityHandlerHash.new   # Soul-Heart
  OnTerrainChange                  = AbilityHandlerHash.new   # Mimicry
  OnIntimidated                    = AbilityHandlerHash.new   # Rattled (Gen 8)
  # Running from battle
  CertainEscapeFromBattle          = AbilityHandlerHash.new   # Run Away

  #=============================================================================

  def self.trigger(hash, *args, ret: false)
    new_ret = hash.trigger(*args)
    return (!new_ret.nil?) ? new_ret : ret
  end

  #=============================================================================

  def self.triggerSpeedCalc(ability, battler, mult)
    return trigger(SpeedCalc, ability, battler, mult, ret: mult)
  end

  def self.triggerWeightCalc(ability, battler, weight)
    return trigger(WeightCalc, ability, battler, weight, ret: weight)
  end

  #=============================================================================

  def self.triggerOnHPDroppedBelowHalf(ability, user, move_user, battle)
    return trigger(OnHPDroppedBelowHalf, ability, user, move_user, battle)
  end

  #=============================================================================

  def self.triggerStatusCheckNonIgnorable(ability, battler, status)
    return trigger(StatusCheckNonIgnorable, ability, battler, status)
  end

  def self.triggerStatusImmunity(ability, battler, status)
    return trigger(StatusImmunity, ability, battler, status)
  end

  def self.triggerStatusImmunityNonIgnorable(ability, battler, status)
    return trigger(StatusImmunityNonIgnorable, ability, battler, status)
  end

  def self.triggerStatusImmunityFromAlly(ability, battler, status)
    return trigger(StatusImmunityFromAlly, ability, battler, status)
  end

  def self.triggerOnStatusInflicted(ability, battler, user, status)
    OnStatusInflicted.trigger(ability, battler, user, status)
  end

  def self.triggerStatusCure(ability, battler)
    return trigger(StatusCure, ability, battler)
  end

  #=============================================================================

  def self.triggerStatLossImmunity(ability, battler, stat, battle, show_messages)
    return trigger(StatLossImmunity, ability, battler, stat, battle, show_messages)
  end

  def self.triggerStatLossImmunityNonIgnorable(ability, battler, stat, battle, show_messages)
    return trigger(StatLossImmunityNonIgnorable, ability, battler, stat, battle, show_messages)
  end

  def self.triggerStatLossImmunityFromAlly(ability, bearer, battler, stat, battle, show_messages)
    return trigger(StatLossImmunityFromAlly, ability, bearer, battler, stat, battle, show_messages)
  end

  def self.triggerOnStatGain(ability, battler, stat, user)
    OnStatGain.trigger(ability, battler, stat, user)
  end

  def self.triggerOnStatLoss(ability, battler, stat, user)
    OnStatLoss.trigger(ability, battler, stat, user)
  end

  #=============================================================================

  def self.triggerPriorityChange(ability, battler, move, priority)
    return trigger(PriorityChange, ability, battler, move, priority, ret: priority)
  end

  def self.triggerPriorityBracketChange(ability, battler, battle)
    return trigger(PriorityBracketChange, ability, battler, battle, ret: 0)
  end

  def self.triggerPriorityBracketUse(ability, battler, battle)
    PriorityBracketUse.trigger(ability, battler, battle)
  end

  #=============================================================================

  def self.triggerOnFlinch(ability, battler, battle)
    OnFlinch.trigger(ability, battler, battle)
  end

  def self.triggerMoveBlocking(ability, bearer, user, targets, move, battle)
    return trigger(MoveBlocking, ability, bearer, user, targets, move, battle)
  end

  def self.triggerMoveImmunity(ability, user, target, move, type, battle, show_message)
    return trigger(MoveImmunity, ability, user, target, move, type, battle, show_message)
  end

  #=============================================================================

  def self.triggerModifyMoveBaseType(ability, user, move, type)
    return trigger(ModifyMoveBaseType, ability, user, move, type, ret: type)
  end

  #=============================================================================

  def self.triggerAccuracyCalcFromUser(ability, mods, user, target, move, type)
    AccuracyCalcFromUser.trigger(ability, mods, user, target, move, type)
  end

  def self.triggerAccuracyCalcFromAlly(ability, mods, user, target, move, type)
    AccuracyCalcFromAlly.trigger(ability, mods, user, target, move, type)
  end

  def self.triggerAccuracyCalcFromTarget(ability, mods, user, target, move, type)
    AccuracyCalcFromTarget.trigger(ability, mods, user, target, move, type)
  end

  #=============================================================================

  def self.triggerDamageCalcFromUser(ability, user, target, move, mults, base_damage, type)
    DamageCalcFromUser.trigger(ability, user, target, move, mults, base_damage, type)
  end

  def self.triggerDamageCalcFromAlly(ability, user, target, move, mults, base_damage, type)
    DamageCalcFromAlly.trigger(ability, user, target, move, mults, base_damage, type)
  end

  def self.triggerDamageCalcFromTarget(ability, user, target, move, mults, base_damage, type)
    DamageCalcFromTarget.trigger(ability, user, target, move, mults, base_damage, type)
  end

  def self.triggerDamageCalcFromTargetNonIgnorable(ability, user, target, move, mults, base_damage, type)
    DamageCalcFromTargetNonIgnorable.trigger(ability, user, target, move, mults, base_damage, type)
  end

  def self.triggerDamageCalcFromTargetAlly(ability, user, target, move, mults, base_damage, type)
    DamageCalcFromTargetAlly.trigger(ability, user, target, move, mults, base_damage, type)
  end

  def self.triggerCriticalCalcFromUser(ability, user, target, crit_stage)
    return trigger(CriticalCalcFromUser, ability, user, target, crit_stage, ret: crit_stage)
  end

  def self.triggerCriticalCalcFromTarget(ability, user, target, crit_stage)
    return trigger(CriticalCalcFromTarget, ability, user, target, crit_stage, ret: crit_stage)
  end

  #=============================================================================

  def self.triggerOnBeingHit(ability, user, target, move, battle)
    OnBeingHit.trigger(ability, user, target, move, battle)
  end

  def self.triggerOnDealingHit(ability, user, target, move, battle)
    OnDealingHit.trigger(ability, user, target, move, battle)
  end

  #=============================================================================

  def self.triggerOnEndOfUsingMove(ability, user, targets, move, battle)
    OnEndOfUsingMove.trigger(ability, user, targets, move, battle)
  end

  def self.triggerAfterMoveUseFromTarget(ability, target, user, move, switched_battlers, battle)
    AfterMoveUseFromTarget.trigger(ability, target, user, move, switched_battlers, battle)
  end

  #=============================================================================

  def self.triggerEndOfRoundWeather(ability, weather, battler, battle)
    EndOfRoundWeather.trigger(ability, weather, battler, battle)
  end

  def self.triggerEndOfRoundHealing(ability, battler, battle)
    EndOfRoundHealing.trigger(ability, battler, battle)
  end

  def self.triggerEndOfRoundEffect(ability, battler, battle)
    EndOfRoundEffect.trigger(ability, battler, battle)
  end

  def self.triggerEndOfRoundGainItem(ability, battler, battle)
    EndOfRoundGainItem.trigger(ability, battler, battle)
  end

  #=============================================================================

  def self.triggerCertainSwitching(ability, switcher, battle)
    return trigger(CertainSwitching, ability, switcher, battle)
  end

  def self.triggerTrappingByTarget(ability, switcher, bearer, battle)
    return trigger(TrappingByTarget, ability, switcher, bearer, battle)
  end

  def self.triggerOnSwitchIn(ability, battler, battle, switch_in = false)
    OnSwitchIn.trigger(ability, battler, battle, switch_in)
  end

  def self.triggerOnSwitchOut(ability, battler, end_of_battle)
    OnSwitchOut.trigger(ability, battler, end_of_battle)
  end

  def self.triggerChangeOnBattlerFainting(ability, battler, fainted, battle)
    ChangeOnBattlerFainting.trigger(ability, battler, fainted, battle)
  end

  def self.triggerOnBattlerFainting(ability, battler, fainted, battle)
    OnBattlerFainting.trigger(ability, battler, fainted, battle)
  end

  def self.triggerOnTerrainChange(ability, battler, battle, ability_changed)
    OnTerrainChange.trigger(ability, battler, battle, ability_changed)
  end

  def self.triggerOnIntimidated(ability, battler, battle)
    OnIntimidated.trigger(ability, battler, battle)
  end

  #=============================================================================

  def self.triggerCertainEscapeFromBattle(ability, battler)
    return trigger(CertainEscapeFromBattle, ability, battler)
  end
end

#===============================================================================
# SpeedCalc handlers
#===============================================================================

Battle::AbilityEffects::SpeedCalc.add(:CHLOROPHYLL,
  proc { |ability, battler, mult|
    next mult * 2 if [:Sun, :HarshSun].include?(battler.effectiveWeather)
  }
)

Battle::AbilityEffects::SpeedCalc.add(:QUICKFEET,
  proc { |ability, battler, mult|
    next mult * 1.5 if battler.pbHasAnyStatus?
  }
)

Battle::AbilityEffects::SpeedCalc.add(:SANDRUSH,
  proc { |ability, battler, mult|
    next mult * 2 if [:Sandstorm].include?(battler.effectiveWeather)
  }
)

Battle::AbilityEffects::SpeedCalc.add(:SLOWSTART,
  proc { |ability, battler, mult|
    next mult / 2 if battler.effects[PBEffects::SlowStart] > 0
  }
)

Battle::AbilityEffects::SpeedCalc.add(:SLUSHRUSH,
  proc { |ability, battler, mult|
    next mult * 2 if [:Hail].include?(battler.effectiveWeather)
  }
)

Battle::AbilityEffects::SpeedCalc.add(:SURGESURFER,
  proc { |ability, battler, mult|
    next mult * 2 if battler.battle.field.terrain == :Electric
  }
)

Battle::AbilityEffects::SpeedCalc.add(:SWIFTSWIM,
  proc { |ability, battler, mult|
    next mult * 2 if [:Rain, :HeavyRain, :Thunderstorm].include?(battler.effectiveWeather)
  }
)

Battle::AbilityEffects::SpeedCalc.add(:UNBURDEN,
  proc { |ability, battler, mult|
    next mult * 2 if battler.effects[PBEffects::Unburden] && !battler.item
  }
)

Battle::AbilityEffects::SpeedCalc.add(:PRODIGY,
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

Battle::AbilityEffects::SpeedCalc.add(:DARKDUALITY,
  proc { |ability,battler,mult|
    next mult * 2 if battler.isSpecies?(:NOCTOA) && battler.form == 1
    next mult
  }
)

#===============================================================================
# WeightCalcy handlers
#===============================================================================

Battle::AbilityEffects::WeightCalc.add(:HEAVYMETAL,
  proc { |ability, battler, w|
    next w * 2
  }
)

Battle::AbilityEffects::WeightCalc.add(:LIGHTMETAL,
  proc { |ability, battler, w|
    next [w / 2, 1].max
  }
)

#===============================================================================
# OnHPDroppedBelowHalf handlers
#===============================================================================

Battle::AbilityEffects::OnHPDroppedBelowHalf.add(:EMERGENCYEXIT,
  proc { |ability, battler, move_user, battle|
    next false if battler.effects[PBEffects::SkyDrop] >= 0 ||
                  battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSkyTargetCannotAct")   # Sky Drop
    # In wild battles
    if battle.wildBattle?
      next false if battler.opposes? && battle.pbSideBattlerCount(battler.index) > 1
      next false if !battle.pbCanRun?(battler.index)
      battle.pbShowAbilitySplash(battler, true)
      battle.pbHideAbilitySplash(battler)
      pbSEPlay("Battle flee")
      battle.pbDisplay(_INTL("{1} fled from battle!", battler.pbThis))
      battle.decision = 3   # Escaped
      next true
    end
    # In trainer battles
    next false if battle.pbAllFainted?(battler.idxOpposingSide)
    next false if !battle.pbCanSwitch?(battler.index)   # Battler can't switch out
    next false if !battle.pbCanChooseNonActive?(battler.index)   # No Pokémon can switch in
    battle.pbShowAbilitySplash(battler, true)
    battle.pbHideAbilitySplash(battler)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} activated!", battler.pbThis, battler.abilityName))
    end
    battle.pbDisplay(_INTL("{1} went back to {2}!",
       battler.pbThis, battle.pbGetOwnerName(battler.index)))
    if battle.endOfRound   # Just switch out
      battle.scene.pbRecall(battler.index) if !battler.fainted?
      battler.pbAbilitiesOnSwitchOut   # Inc. primordial weather check
      next true
    end
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next false if newPkmn < 0   # Shouldn't ever do this
    battle.pbRecallAndReplace(battler.index, newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    battle.moldBreaker = false if move_user && battler.index == move_user.index
    battle.pbOnBattlerEnteringBattle(battler.index)
    next true
  }
)

Battle::AbilityEffects::OnHPDroppedBelowHalf.copy(:EMERGENCYEXIT, :WIMPOUT)

#===============================================================================
# StatusCheckNonIgnorable handlers
#===============================================================================

Battle::AbilityEffects::StatusCheckNonIgnorable.add(:COMATOSE,
  proc { |ability, battler, status|
    next false if !battler.isSpecies?(:KOMALA)
    next true if status.nil? || status == :SLEEP
  }
)

#===============================================================================
# StatusImmunity handlers
#===============================================================================

Battle::AbilityEffects::StatusImmunity.add(:FLOWERVEIL,
  proc { |ability, battler, status|
    next true if battler.pbHasType?(:GRASS)
  }
)

Battle::AbilityEffects::StatusImmunity.add(:IMMUNITY,
  proc { |ability, battler, status|
    next true if status == :POISON
  }
)

Battle::AbilityEffects::StatusImmunity.copy(:IMMUNITY, :PASTELVEIL)

Battle::AbilityEffects::StatusImmunity.add(:INSOMNIA,
  proc { |ability, battler, status|
    next true if status == :SLEEP
  }
)

Battle::AbilityEffects::StatusImmunity.copy(:INSOMNIA, :SWEETVEIL, :VITALSPIRIT)

Battle::AbilityEffects::StatusImmunity.add(:LEAFGUARD,
  proc { |ability, battler, status|
    next true if [:Sun, :HarshSun].include?(battler.effectiveWeather)
  }
)

Battle::AbilityEffects::StatusImmunity.add(:LIMBER,
  proc { |ability, battler, status|
    next true if status == :PARALYSIS
  }
)

Battle::AbilityEffects::StatusImmunity.add(:MAGMAARMOR,
  proc { |ability, battler, status|
    next true if status == :FROZEN
  }
)

Battle::AbilityEffects::StatusImmunity.add(:WATERVEIL,
  proc { |ability, battler, status|
    next true if status == :BURN
  }
)

Battle::AbilityEffects::StatusImmunity.copy(:WATERVEIL, :WATERBUBBLE, :SPICETANK)

#===============================================================================
# StatusImmunityNonIgnorable handlers
#===============================================================================

Battle::AbilityEffects::StatusImmunityNonIgnorable.add(:COMATOSE,
  proc { |ability, battler, status|
    next true if battler.isSpecies?(:KOMALA)
  }
)

Battle::AbilityEffects::StatusImmunityNonIgnorable.add(:SHIELDSDOWN,
  proc { |ability, battler, status|
    next true if battler.isSpecies?(:MINIOR) && battler.form < 7
  }
)

#===============================================================================
# StatusImmunityFromAlly handlers
#===============================================================================

Battle::AbilityEffects::StatusImmunityFromAlly.add(:FLOWERVEIL,
  proc { |ability, battler, status|
    next true if battler.pbHasType?(:GRASS)
  }
)

Battle::AbilityEffects::StatusImmunityFromAlly.add(:SWEETVEIL,
  proc { |ability, battler, status|
    next true if status == :SLEEP
  }
)

#===============================================================================
# OnStatusInflicted handlers
#===============================================================================

Battle::AbilityEffects::OnStatusInflicted.add(:SYNCHRONIZE,
  proc { |ability, battler, user, status|
    next if !user || user.index == battler.index
    case status
    when :POISON
      if user.pbCanPoisonSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !Battle::Scene::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} poisoned {3}!", battler.pbThis, battler.abilityName, user.pbThis(true))
        end
        user.pbPoison(nil, msg, (battler.statusCount > 0))
        battler.battle.pbHideAbilitySplash(battler)
      end
    when :BURN
      if user.pbCanBurnSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !Battle::Scene::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} burned {3}!", battler.pbThis, battler.abilityName, user.pbThis(true))
        end
        user.pbBurn(nil, msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    when :PARALYSIS
      if user.pbCanParalyzeSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !Battle::Scene::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
             battler.pbThis, battler.abilityName, user.pbThis(true))
        end
        user.pbParalyze(nil, msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    end
  }
)

#===============================================================================
# StatusCure handlers
#===============================================================================

Battle::AbilityEffects::StatusCure.add(:IMMUNITY,
  proc { |ability, battler|
    next if battler.status != :POISON
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!", battler.pbThis, battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::StatusCure.add(:INSOMNIA,
  proc { |ability, battler|
    next if battler.status != :SLEEP
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} woke it up!", battler.pbThis, battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::StatusCure.copy(:INSOMNIA, :VITALSPIRIT)

Battle::AbilityEffects::StatusCure.add(:LIMBER,
  proc { |ability, battler|
    next if battler.status != :PARALYSIS
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!", battler.pbThis, battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::StatusCure.add(:MAGMAARMOR,
  proc { |ability, battler|
    next if battler.status != :FROZEN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} defrosted it!", battler.pbThis, battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::StatusCure.add(:OBLIVIOUS,
  proc { |ability, battler|
    next if battler.effects[PBEffects::Attract] < 0 &&
            (battler.effects[PBEffects::Taunt] == 0 || Settings::MECHANICS_GENERATION <= 5)
    battler.battle.pbShowAbilitySplash(battler)
    if battler.effects[PBEffects::Attract] >= 0
      battler.pbCureAttract
      if Battle::Scene::USE_ABILITY_SPLASH
        battler.battle.pbDisplay(_INTL("{1} got over its infatuation.", battler.pbThis))
      else
        battler.battle.pbDisplay(_INTL("{1}'s {2} cured its infatuation status!",
           battler.pbThis, battler.abilityName))
      end
    end
    if battler.effects[PBEffects::Taunt] > 0 && Settings::MECHANICS_GENERATION >= 6
      battler.effects[PBEffects::Taunt] = 0
      if Battle::Scene::USE_ABILITY_SPLASH
        battler.battle.pbDisplay(_INTL("{1}'s Taunt wore off!", battler.pbThis))
      else
        battler.battle.pbDisplay(_INTL("{1}'s {2} made its taunt wear off!",
           battler.pbThis, battler.abilityName))
      end
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::StatusCure.add(:OWNTEMPO,
  proc { |ability, battler|
    next if battler.effects[PBEffects::Confusion] == 0
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureConfusion
    if Battle::Scene::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1} snapped out of its confusion.", battler.pbThis))
    else
      battler.battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",
         battler.pbThis, battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::StatusCure.add(:WATERVEIL,
  proc { |ability, battler|
    next if battler.status != :BURN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} healed its burn!", battler.pbThis, battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::StatusCure.copy(:WATERVEIL, :WATERBUBBLE)

#===============================================================================
# StatLossImmunity handlers
#===============================================================================

Battle::AbilityEffects::StatLossImmunity.add(:BIGPECKS,
  proc { |ability, battler, stat, battle, showMessages|
    next false if stat != :DEFENSE
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!", battler.pbThis,
           battler.abilityName, GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

Battle::AbilityEffects::StatLossImmunity.add(:CLEARBODY,
  proc { |ability, battler, stat, battle, showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!", battler.pbThis, battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

Battle::AbilityEffects::StatLossImmunity.copy(:CLEARBODY, :WHITESMOKE)

Battle::AbilityEffects::StatLossImmunity.add(:FLOWERVEIL,
  proc { |ability, battler, stat, battle, showMessages|
    next false if !battler.pbHasType?(:GRASS)
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!", battler.pbThis, battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

Battle::AbilityEffects::StatLossImmunity.add(:HYPERCUTTER,
  proc { |ability, battler, stat, battle, showMessages|
    next false if stat != :ATTACK
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!", battler.pbThis,
           battler.abilityName, GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

Battle::AbilityEffects::StatLossImmunity.add(:KEENEYE,
  proc { |ability, battler, stat, battle, showMessages|
    next false if stat != :ACCURACY
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!", battler.pbThis,
           battler.abilityName, GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

Battle::AbilityEffects::StatLossImmunity.copy(:KEENEYE, :SENSORYAWARENESS)

Battle::AbilityEffects::StatLossImmunity.add(:VICTORYRUSH,
  proc { |ability,battler,stat,battle,showMessages|
    next false if !battler.effects[PBEffects::VictoryRush]
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if Battle::Scene::USE_ABILITY_SPLASH
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
# StatLossImmunityNonIgnorable handlers
#===============================================================================

Battle::AbilityEffects::StatLossImmunityNonIgnorable.add(:FULLMETALBODY,
  proc { |ability, battler, stat, battle, showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!", battler.pbThis, battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

#===============================================================================
# StatLossImmunityFromAlly handlers
#===============================================================================

Battle::AbilityEffects::StatLossImmunityFromAlly.add(:FLOWERVEIL,
  proc { |ability, bearer, battler, stat, battle, showMessages|
    next false if !battler.pbHasType?(:GRASS)
    if showMessages
      battle.pbShowAbilitySplash(bearer)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s stat loss!",
           bearer.pbThis, bearer.abilityName, battler.pbThis(true)))
      end
      battle.pbHideAbilitySplash(bearer)
    end
    next true
  }
)

#===============================================================================
# OnStatGain handlers
#===============================================================================

# There aren't any!

#===============================================================================
# OnStatLoss handlers
#===============================================================================

Battle::AbilityEffects::OnStatLoss.add(:COMPETITIVE,
  proc { |ability, battler, stat, user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 2, battler)
  }
)

Battle::AbilityEffects::OnStatLoss.add(:DEFIANT,
  proc { |ability, battler, stat, user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(:ATTACK, 2, battler)
  }
)

#===============================================================================
# PriorityChange handlers
#===============================================================================

Battle::AbilityEffects::PriorityChange.add(:GALEWINGS,
  proc { |ability, battler, move, pri|
    next pri + 1 if (Settings::MECHANICS_GENERATION <= 6 || battler.hp == battler.totalhp) &&
                    move.type == :FLYING
  }
)

Battle::AbilityEffects::PriorityChange.add(:PRANKSTER,
  proc { |ability, battler, move, pri|
    if move.statusMove?
      battler.effects[PBEffects::Prankster] = true
      next pri + 1
    end
  }
)

Battle::AbilityEffects::PriorityChange.add(:TRIAGE,
  proc { |ability, battler, move, pri|
    next pri + 3 if move.healingMove?
  }
)

Battle::AbilityEffects::PriorityChange.add(:SPEEDBALL,
  proc { |ability,battler,move,pri|
    next pri+1 if move.rollingBasedMove? || battler.usingMultiTurnAttack?
  }
)

Battle::AbilityEffects::PriorityChange.add(:FREESTYLE,
  proc { |ability,battler,move,pri|
    next pri+1 if move.type == :SOUND || move.pbSoundMove?(battler)
  }
)

Battle::AbilityEffects::PriorityChange.add(:RAPIDSTREAM,
  proc { |ability,battler,move,pri|
    next pri+1 if move.type == :WATER && battler.hp == battler.totalhp
  }
)

# Lowest possible bracket
Battle::AbilityEffects::PriorityChange.add(:IMMOVABLE,
  proc { |ability,battler,move,pri|
    next -7
  }
)

Battle::AbilityEffects::PriorityChange.add(:QUICKBLADE,
  proc { |ability,battler,move,pri|
    next pri+1 if move.slashingMove?
  }
)

Battle::AbilityEffects::PriorityChange.add(:PROXY,
  proc { |ability,battler,move,pri|
    next pri+1 if battler.isSpecies?(:PHANTITUTE) && move.id == :SUBSTITUTE
  }
)

#===============================================================================
# PriorityBracketChange handlers
#===============================================================================

Battle::AbilityEffects::PriorityBracketChange.add(:QUICKDRAW,
  proc { |ability, battler, battle|
    next 1 if battle.pbRandom(100) < 30
  }
)

Battle::AbilityEffects::PriorityBracketChange.add(:STALL,
  proc { |ability, battler, battle|
    next -1
  }
)

# Last within bracket
Battle::AbilityEffects::PriorityBracketChange.copy(:STALL, :IMMOVABLE)

#===============================================================================
# PriorityBracketUse handlers
#===============================================================================

Battle::AbilityEffects::PriorityBracketUse.add(:QUICKDRAW,
  proc { |ability, battler, battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} made {2} move faster!", battler.abilityName, battler.pbThis(true)))
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# OnFlinch handlers
#===============================================================================

Battle::AbilityEffects::OnFlinch.add(:STEADFAST,
  proc { |ability, battler, battle|
    battler.pbRaiseStatStageByAbility(:SPEED, 1, battler)
  }
)

#===============================================================================
# MoveBlocking handlers
#===============================================================================

Battle::AbilityEffects::MoveBlocking.add(:DAZZLING,
  proc { |ability, bearer, user, targets, move, battle|
    next false if battle.choices[user.index][4] <= 0
    next false if !bearer.opposes?(user)
    ret = false
    targets.each do |b|
      next if !b.opposes?(user)
      ret = true
    end
    next ret
  }
)

Battle::AbilityEffects::MoveBlocking.copy(:DAZZLING, :QUEENLYMAJESTY)

#===============================================================================
# MoveImmunity handlers
#===============================================================================

Battle::AbilityEffects::MoveImmunity.add(:BULLETPROOF,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if !move.bombMove?
    if show_message
      battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           target.pbThis, target.abilityName, move.name))
      end
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

Battle::AbilityEffects::MoveImmunity.add(:FLASHFIRE,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if user.index == target.index
    next false if type != :FIRE
    if show_message
      battle.pbShowAbilitySplash(target)
      if !target.effects[PBEffects::FlashFire]
        target.effects[PBEffects::FlashFire] = true
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!", target.pbThis(true)))
        else
          battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose because of its {2}!",
             target.pbThis(true), target.abilityName))
        end
      elsif Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
                               target.pbThis, target.abilityName, move.name))
      end
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

Battle::AbilityEffects::MoveImmunity.add(:LIGHTNINGROD,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :ELECTRIC, :SPECIAL_ATTACK, 1, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:MOTORDRIVE,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :ELECTRIC, :SPEED, 1, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:SAPSIPPER,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :GRASS, :ATTACK, 1, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:SOUNDPROOF,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if !move.pbSoundMove?(user)
    next false if Settings::MECHANICS_GENERATION >= 8 && user.index == target.index
    if show_message
      battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!", target.pbThis, target.abilityName, move.name))
      end
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

Battle::AbilityEffects::MoveImmunity.add(:STORMDRAIN,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :WATER, :SPECIAL_ATTACK, 1, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:TELEPATHY,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if move.statusMove?
    next false if user.index == target.index || target.opposes?(user)
    if show_message
      battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!", target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon with {2}!",
           target.pbThis, target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

Battle::AbilityEffects::MoveImmunity.add(:VOLTABSORB,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityHealingAbility(user, move, type, :ELECTRIC, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.add(:WATERABSORB,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityHealingAbility(user, move, type, :WATER, show_message)
  }
)

Battle::AbilityEffects::MoveImmunity.copy(:WATERABSORB, :DRYSKIN)

Battle::AbilityEffects::MoveImmunity.add(:WONDERGUARD,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if move.statusMove?
    next false if !type || Effectiveness.super_effective?(target.damageState.typeMod)
    if show_message
      battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1} avoided damage with {2}!", target.pbThis, target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)

Battle::AbilityEffects::MoveImmunity.add(:CLOUDFLUFF,
proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityStatRaisingAbility(user, move, type,
       :ELECTRIC, :SPECIAL_ATTACK, 1, show_message)
  }
)

# To make target immune to contact moves
Battle::AbilityEffects::MoveImmunity.add(:IMMATERIAL,
proc { |ability, user, target, move, type, battle, show_message|
    next false if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
         target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

Battle::AbilityEffects::MoveImmunity.add(:THERMALPOWER,
proc { |ability, user, target, move, type, battle, show_message|
    next false if type != :FIRE
    battle.pbShowAbilitySplash(target)
    if Battle::Scene::USE_ABILITY_SPLASH
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

Battle::AbilityEffects::MoveImmunity.add(:HUMIDIFY,
proc { |ability, user, target, move, type, battle, show_message|
    next false if type != :WATER
    battle.pbShowAbilitySplash(target)
    if Battle::Scene::USE_ABILITY_SPLASH
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

Battle::AbilityEffects::MoveImmunity.add(:QUARTZARMOR,
proc { |ability, user, target, move, type, battle, show_message|
    next false if type != :WATER
    battle.pbShowAbilitySplash(target)
    if Battle::Scene::USE_ABILITY_SPLASH
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

Battle::AbilityEffects::MoveImmunity.add(:WINTERSPIRIT,
proc { |ability, user, target, move, type, battle, show_message|
    next false if type != :NORMAL && type != :FIGHTING
    next false if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
        target.pbThis,target.abilityName,move.name))
    end
    if user.pbCanFreeze?(target, false) && user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      user.pbFreeze
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

Battle::AbilityEffects::MoveImmunity.add(:FIRMLYPLANTED,
proc { |ability, user, target, move, type, battle, show_message|
    next false if !move.throwingMove?
    battle.pbShowAbilitySplash(target)
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} stayed firmly planted!",target.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
        target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

Battle::AbilityEffects::MoveImmunity.add(:DARKDUALITY,
proc { |ability, user, target, move, type, battle, show_message|
    next false if !target.isSpecies?(:NOCTOA) || target.form != 1
    next false if type != :GHOST
    battle.pbShowAbilitySplash(target)
    if Battle::Scene::USE_ABILITY_SPLASH
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
# ModifyMoveBaseType handlers
#===============================================================================

Battle::AbilityEffects::ModifyMoveBaseType.add(:AERILATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:FLYING)
    move.powerBoost = true
    next :FLYING
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:GALVANIZE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:ELECTRIC)
    move.powerBoost = true
    next :ELECTRIC
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:LIQUIDVOICE,
  proc { |ability, user, move, type|
    next :WATER if GameData::Type.exists?(:WATER) && move.pbSoundMove?(user)
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:NORMALIZE,
  proc { |ability, user, move, type|
    next if !GameData::Type.exists?(:NORMAL)
    move.powerBoost = true if Settings::MECHANICS_GENERATION >= 7
    next :NORMAL
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:PIXILATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:FAIRY)
    move.powerBoost = true
    next :FAIRY
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:REFRIGERATE,
  proc { |ability, user, move, type|
    next if type != :NORMAL || !GameData::Type.exists?(:ICE)
    move.powerBoost = true
    next :ICE
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:CRYSTALATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:CRYSTAL)
    move.powerBoost = true
    next :CRYSTAL
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:SAKURA,
  proc { |ability,user,move,type|
    next if type != :GRASS || !GameData::Type.exists?(:FAIRY)
    move.powerBoost = true
    next :FAIRY
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:MINDTRICK,
  proc { |ability,user,move,type|
    next if type != :PSYCHIC || !GameData::Type.exists?(:MYSTIC)
    move.powerBoost = true
    next :MYSTIC
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:GALAXYBRAIN,
  proc { |ability,user,move,type|
    next if type != :PSYCHIC || !GameData::Type.exists?(:COSMIC)
    move.powerBoost = true
    next :COSMIC
  }
)

#===============================================================================
# AccuracyCalcFromUser handlers
#===============================================================================

Battle::AbilityEffects::AccuracyCalcFromUser.add(:COMPOUNDEYES,
  proc { |ability, mods, user, target, move, type|
    mods[:accuracy_multiplier] *= 1.3
  }
)

Battle::AbilityEffects::AccuracyCalcFromUser.add(:HUSTLE,
  proc { |ability, mods, user, target, move, type|
    mods[:accuracy_multiplier] *= 0.8 if move.pbPhysicalMove?(user)
  }
)

Battle::AbilityEffects::AccuracyCalcFromUser.add(:KEENEYE,
  proc { |ability, mods, user, target, move, type|
    mods[:evasion_stage] = 0 if mods[:evasion_stage] > 0 && Settings::MECHANICS_GENERATION >= 6
  }
)

Battle::AbilityEffects::AccuracyCalcFromUser.add(:NOGUARD,
  proc { |ability, mods, user, target, move, type|
    mods[:base_accuracy] = 0
  }
)

Battle::AbilityEffects::AccuracyCalcFromUser.add(:UNAWARE,
  proc { |ability, mods, user, target, move, type|
    mods[:evasion_stage] = 0 if move.damagingMove?
  }
)

Battle::AbilityEffects::AccuracyCalcFromUser.add(:VICTORYSTAR,
  proc { |ability, mods, user, target, move, type|
    mods[:accuracy_multiplier] *= 1.1
  }
)

Battle::AbilityEffects::AccuracyCalcFromUser.add(:DARKLIGHT,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.1 if target.pbHasType?(:DARK)
  }
)

Battle::AbilityEffects::AccuracyCalcFromUser.add(:LUNARBLESSING,
  proc { |ability,mods,user,target,move,type|
    next if !move.pbDamagingMove?
    mods[:accuracy_multiplier] *= 1.25
  }
)

#===============================================================================
# AccuracyCalcFromAlly handlers
#===============================================================================

Battle::AbilityEffects::AccuracyCalcFromAlly.add(:VICTORYSTAR,
  proc { |ability, mods, user, target, move, type|
    mods[:accuracy_multiplier] *= 1.1
  }
)

Battle::AbilityEffects::AccuracyCalcFromAlly.add(:DARKLIGHT,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.1 if target.pbHasType?(:DARK)
  }
)

#===============================================================================
# AccuracyCalcFromTarget handlers
#===============================================================================

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:LIGHTNINGROD,
  proc { |ability, mods, user, target, move, type|
    mods[:base_accuracy] = 0 if type == :ELECTRIC
  }
)

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:NOGUARD,
  proc { |ability, mods, user, target, move, type|
    mods[:base_accuracy] = 0
  }
)

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:SANDVEIL,
  proc { |ability, mods, user, target, move, type|
    mods[:evasion_multiplier] *= 1.25 if target.effectiveWeather == :Sandstorm
  }
)

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:SNOWCLOAK,
  proc { |ability, mods, user, target, move, type|
    mods[:evasion_multiplier] *= 1.25 if target.effectiveWeather == :Hail
  }
)

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:STORMDRAIN,
  proc { |ability, mods, user, target, move, type|
    mods[:base_accuracy] = 0 if type == :WATER
  }
)

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:TANGLEDFEET,
  proc { |ability, mods, user, target, move, type|
    mods[:accuracy_multiplier] /= 2 if target.effects[PBEffects::Confusion] > 0
  }
)

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:UNAWARE,
  proc { |ability, mods, user, target, move, type|
    mods[:accuracy_stage] = 0 if move.damagingMove?
  }
)

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:WONDERSKIN,
  proc { |ability, mods, user, target, move, type|
    if move.statusMove? && user.opposes?(target) && mods[:base_accuracy] > 50
      mods[:base_accuracy] = 50
    end
  }
)

Battle::AbilityEffects::AccuracyCalcFromTarget.add(:AVOID,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 0.85 if move.pbSpecialMove?(user)
  }
)

#===============================================================================
# DamageCalcFromUser handlers
#===============================================================================

Battle::AbilityEffects::DamageCalcFromUser.add(:AERILATE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] *= 1.2 if move.powerBoost
  }
)

Battle::AbilityEffects::DamageCalcFromUser.copy(:AERILATE, :PIXILATE, :REFRIGERATE, :GALVANIZE, :NORMALIZE, :CRYSTALATE, :MINDTRICK, :GALAXYBRAIN)

Battle::AbilityEffects::DamageCalcFromUser.add(:SAKURA,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] *= 1.1 if move.powerBoost
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:ANALYTIC,
  proc { |ability, user, target, move, mults, baseDmg, type|
    # NOTE: In the official games, if another battler faints earlier in the
    #       round but it would have moved after the user, then Analytic does not
    #       power up the move. However, this makes the determination so much
    #       more complicated (involving pbPriority and counting or not counting
    #       speed/priority modifiers depending on which Generation's mechanics
    #       are being used), so I'm choosing to ignore it. The effect is thus:
    #       "power up the move if all other battlers on the field right now have
    #       already moved".
    if move.pbMoveFailedLastInRound?(user, false)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:BLAZE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.hp <= user.totalhp / 3 && type == :FIRE
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:DEFEATIST,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] /= 2 if user.hp <= user.totalhp / 2
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:DRAGONSMAW,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.5 if type == :DRAGON
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:FLAREBOOST,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.burned? && move.pbSpecialMove?(user)
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:FLASHFIRE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.effects[PBEffects::FlashFire] && type == :FIRE
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:FLOWERGIFT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if move.pbPhysicalMove?(user) && [:Sun, :HarshSun].include?(user.effectiveWeather)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:GORILLATACTICS,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.5 if move.physicalMove?
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:GUTS,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.pbHasAnyStatus? && move.pbPhysicalMove?(user)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:HUGEPOWER,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 2 if move.pbPhysicalMove?(user)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.copy(:HUGEPOWER, :PUREPOWER)

Battle::AbilityEffects::DamageCalcFromUser.add(:HUSTLE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.5 if move.pbPhysicalMove?(user)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:IRONFIST,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] *= 1.2 if move.punchingMove?
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:MEGALAUNCHER,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] *= 1.5 if move.pulseMove?
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:MINUS,
  proc { |ability, user, target, move, mults, baseDmg, type|
    next if !move.pbSpecialMove?(user)
    if user.allAllies.any? { |b| b.hasActiveAbility?([:MINUS, :PLUS]) }
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.copy(:MINUS, :PLUS)

Battle::AbilityEffects::DamageCalcFromUser.add(:NEUROFORCE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 1.25
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:OVERGROW,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.hp <= user.totalhp / 3 && type == :GRASS
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:PUNKROCK,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.3 if move.pbSoundMove?(user)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:RECKLESS,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] *= 1.2 if move.recoilMove?
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:RIVALRY,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.gender != 2 && target.gender != 2
      if user.gender == target.gender
        mults[:base_damage_multiplier] *= 1.25
      else
        mults[:base_damage_multiplier] *= 0.75
      end
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:SANDFORCE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.effectiveWeather == :Sandstorm &&
       [:ROCK, :GROUND, :STEEL].include?(type)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:SHEERFORCE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] *= 1.3 if move.addlEffect > 0
  }
)

Battle::AbilityEffects::DamageCalcFromUser.copy(:SHEERFORCE,:MORALPACT)

Battle::AbilityEffects::DamageCalcFromUser.add(:SLOWSTART,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] /= 2 if user.effects[PBEffects::SlowStart] > 0 && move.pbPhysicalMove?(user)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:SOLARPOWER,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if move.pbSpecialMove?(user) && [:Sun, :HarshSun].include?(user.effectiveWeather)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:SNIPER,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if target.damageState.critical
      mults[:final_damage_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:STAKEOUT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 2 if target.battle.choices[target.index][0] == :SwitchOut
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:STEELWORKER,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.5 if type == :STEEL
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:STEELYSPIRIT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 1.5 if type == :STEEL
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:STRONGJAW,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] *= 1.5 if move.bitingMove?
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:SWARM,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.hp <= user.totalhp / 3 && type == :BUG
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:TECHNICIAN,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.index != target.index && move && move.id != :STRUGGLE &&
       baseDmg * mults[:base_damage_multiplier] <= 60
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:TINTEDLENS,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 2 if Effectiveness.resistant?(target.damageState.typeMod)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:TORRENT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.hp <= user.totalhp / 3 && type == :WATER
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:TOUGHCLAWS,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] *= 4 / 3.0 if move.contactMove?
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:TOXICBOOST,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.poisoned? && move.pbPhysicalMove?(user)
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:TRANSISTOR,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 1.5 if type == :ELECTRIC
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:WATERBUBBLE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] *= 2 if type == :WATER
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:MAGMATICHEAT,
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

Battle::AbilityEffects::DamageCalcFromUser.add(:RAINBOWGUARD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    types = [:FIRE, :ICE, :ELECTRIC]
    mults[:base_damage_multiplier] *= 1.3 if types.include?(type) && !user.pbHasType?(type)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:TAINTEDPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 2
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:OPPORTUNIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if move.accuracy == 0 # Moves that never miss
    if move.accuracy < 60
      mults[:final_damage_multiplier] *= 2
    elsif move.accuracy < 100
      mults[:final_damage_multiplier] *= 1.3
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:ENTERSPHERE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if type == :FIRE
      mults[:base_damage_multiplier] *= 1.6
    elsif move.pbContactMove?(user)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:CRYSTALSURGE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if type != :CRYSTAL
    next if user.pbHasType?(:CRYSTAL)
    mults[:final_damage_multiplier] *= 1.5
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:VANGUARD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if user.turnCount != 1
    mults[:final_damage_multiplier] *= 1.5
  }
)

Battle::AbilityEffects::DamageCalcFromUser.copy(:VANGUARD, :CHARGEDUP)

Battle::AbilityEffects::DamageCalcFromUser.add(:FLYTRAP,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !target.pbHasType?(:BUG)
    mults[:base_damage_multiplier] *= 1.3
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:BULLY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if target.pokemon.height > user.pokemon.height
    next if target.pokemon.height == user.pokemon.height && user.pbWeight <= target.pbWeight
    mults[:base_damage_multiplier] *= 1.3
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:FRENZIED,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= [2 - ((user.hp.to_f-1) / user.totalhp), 1.0].max
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:PERSEVERANCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    met = 1 + 0.2 * [user.effects[PBEffects::Metronome], 3].min
    mults[:final_damage_multiplier] *= met
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:ILLINTENT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if move.calcType != :DARK
    mults[:base_damage_multiplier] *= 1.3
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:WINDUP,
  proc { |ability,user,target,move,mults,baseDmg,type|
    # TODO: Consider making dedicated method for detecting two-turn attacks, charging or otherwise
    # Two turn attack, Hyper Beam, Crystallized Beam, or Shadow Half
    next if !move.chargingTurnMove? && move.function != "AttackAndSkipNextTurn" &&
            move.function != "AttackAndSkipThreeTurns" && move.function != "AllBattlersLoseHalfHPUserSkipsNextTurn"
    mults[:final_damage_multiplier] *= 1.5
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:FLURESCENCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.chargingTurnMove?
    mults[:final_damage_multiplier] *= 0.8
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:LUNARBLESSING,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 1.25
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:PRODIGY,
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

Battle::AbilityEffects::DamageCalcFromUser.add(:CRYSTALSTINGER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 2
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:WINTERSPIRIT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if type != :GHOST
    next if user.battle.pbWeather != :Hail
    mults[:final_damage_multiplier] *= 1.5
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:OVERCHARGED,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if type != :ELECTRIC
    mults[:base_damage_multiplier] *= 1 + (user.effects[PBEffects::Overcharged] * 0.15)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:BERSERKER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if user.totalhp <= 1 # Probably not possible but just in case
    # User hp range is 1..totalhp
    # Mult should be 1x at full hp, and 2x at 1 HP
    berserkerRatio = (1 - ((user.hp.to_f - 1) / (user.totalhp - 1)))
    mults[:final_damage_multiplier] *= 1 + berserkerRatio
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:EXPLOSIVEEXHAUST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    # Recoil move or move function for Explosion (or Self-Destruct), Final Gambit, or Mind Blown
    explosiveMoves = ["UserFaintsExplosive", "UserFaintsFixedDamageUserHP", "UserLosesHalfOfTotalHPExplosive"]
    mults[:base_damage_multiplier] *= 1.5 if move.recoilMove? || explosiveMoves.include?(move.function)
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:IRONKICK,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if move.kickingMove?
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:STRONGSKULL,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.headBasedMove?
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:ROLLUP,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.ballRollingMove?
  }
)

#===============================================================================
# DamageCalcFromAlly handlers
#===============================================================================

Battle::AbilityEffects::DamageCalcFromAlly.add(:BATTERY,
  proc { |ability, user, target, move, mults, baseDmg, type|
    next if !move.pbSpecialMove?(user)
    mults[:final_damage_multiplier] *= 1.3
  }
)

Battle::AbilityEffects::DamageCalcFromAlly.add(:FLOWERGIFT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if move.pbPhysicalMove?(user) && [:Sun, :HarshSun].include?(user.effectiveWeather)
      mults[:attack_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromAlly.add(:POWERSPOT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 1.3
  }
)

Battle::AbilityEffects::DamageCalcFromAlly.add(:STEELYSPIRIT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 1.5 if type == :STEEL
  }
)

Battle::AbilityEffects::DamageCalcFromAlly.add(:NOMAD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !user.pbHasType?(:FLYING) && !user.pbHasType?(:DRAGON)
    mults[:final_damage_multiplier] *= 1.5
  }
)

#===============================================================================
# DamageCalcFromTarget handlers
#===============================================================================

Battle::AbilityEffects::DamageCalcFromTarget.add(:DRYSKIN,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] *= 1.25 if type == :FIRE
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:FILTER,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 0.75
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.copy(:FILTER, :SOLIDROCK)

Battle::AbilityEffects::DamageCalcFromTarget.add(:FLOWERGIFT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if move.pbSpecialMove?(user) && [:Sun, :HarshSun].include?(target.effectiveWeather)
      mults[:defense_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:FLUFFY,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 2 if move.calcType == :FIRE
    mults[:final_damage_multiplier] /= 2 if move.pbContactMove?(user)
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:FURCOAT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:defense_multiplier] *= 2 if move.pbPhysicalMove?(user) ||
                                       move.function == "UseTargetDefenseInsteadOfTargetSpDef"   # Psyshock
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:GRASSPELT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.battle.field.terrain == :Grassy
      mults[:defense_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:HEATPROOF,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] /= 2 if type == :FIRE
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:ICESCALES,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] /= 2 if move.pbSpecialMove?(user)
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:MARVELSCALE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if target.pbHasAnyStatus? && move.pbPhysicalMove?(user)
      mults[:defense_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:MULTISCALE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] /= 2 if target.hp == target.totalhp
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:PUNKROCK,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] /= 2 if move.pbSoundMove?(user)
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:THICKFAT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] /= 2 if [:FIRE, :ICE].include?(type)
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:WATERBUBBLE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] /= 2 if type == :FIRE
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:CRYSTALLINE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if type == :WATER || type == :GRASS
      mults[:base_damage_multiplier] /= 2
    elsif type == :ELECTRIC
      mults[:base_damage_multiplier] *= 2
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:IMMATERIAL,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.pbSpecialMove?(user)
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:THERMALPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if type == :ICE
      mults[:base_damage_multiplier] *= 2
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:CLOUDFLUFF,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.pbContactMove?(user) && move.pbPhysicalMove?(user)
      mults[:base_damage_multiplier] *= 0.75
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:DESERTBODY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] /= 2 if type == :FIRE || type == :ICE || type == :WATER
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:EDIBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.bitingMove?
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:VINECOILSTYLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.pbContactMove?(user)
    mults[:base_damage_multiplier] *= 0.7
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:REFLECTIVE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.pbSpecialMove?(user)
    mults[:base_damage_multiplier] *= 0.5
  }
)

#===============================================================================
# DamageCalcFromTargetNonIgnorable handlers
#===============================================================================

Battle::AbilityEffects::DamageCalcFromTargetNonIgnorable.add(:PRISMARMOR,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 0.75
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTargetNonIgnorable.add(:SHADOWSHIELD,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if target.hp == target.totalhp
      mults[:final_damage_multiplier] /= 2
    end
  }
)

#===============================================================================
# DamageCalcFromTargetAlly handlers
#===============================================================================

Battle::AbilityEffects::DamageCalcFromTargetAlly.add(:FLOWERGIFT,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if move.pbSpecialMove?(user) && [:Sun, :HarshSun].include?(target.effectiveWeather)
      mults[:defense_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTargetAlly.add(:FRIENDGUARD,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.75
  }
)

#===============================================================================
# CriticalCalcFromUser handlers
#===============================================================================

Battle::AbilityEffects::CriticalCalcFromUser.add(:MERCILESS,
  proc { |ability, user, target, c|
    next 99 if target.poisoned?
  }
)

Battle::AbilityEffects::CriticalCalcFromUser.add(:SUPERLUCK,
  proc { |ability, user, target, c|
    next c + 1
  }
)

Battle::AbilityEffects::CriticalCalcFromUser.add(:COUNTERPARRY,
  proc { |ability,user,target,c|
    next 99 if user.hasActiveAbility?(:COUNTERPARRY) && user.effects[PBEffects::CounterParry]
  }
)

Battle::AbilityEffects::CriticalCalcFromUser.add(:OMNIPOTENT,
  proc { |ability,user,target,c|
    next 99
  }
)

#===============================================================================
# CriticalCalcFromTarget handlers
#===============================================================================

Battle::AbilityEffects::CriticalCalcFromTarget.add(:BATTLEARMOR,
  proc { |ability, user, target, c|
    next -1
  }
)

Battle::AbilityEffects::CriticalCalcFromTarget.copy(:BATTLEARMOR, :SHELLARMOR)

#===============================================================================
# OnBeingHit handlers
#===============================================================================

Battle::AbilityEffects::OnBeingHit.add(:AFTERMATH,
  proc { |ability, user, target, move, battle|
    next if !target.fainted?
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if !battle.moldBreaker
      dampBattler = battle.pbCheckGlobalAbility(:DAMP)
      if dampBattler
        battle.pbShowAbilitySplash(dampBattler)
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1} cannot use {2}!", target.pbThis, target.abilityName))
        else
          battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
             target.pbThis, target.abilityName, dampBattler.pbThis(true), dampBattler.abilityName))
        end
        battle.pbHideAbilitySplash(dampBattler)
        battle.pbHideAbilitySplash(target)
        next
      end
    end
    if user.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp / 4, false)
      battle.pbDisplay(_INTL("{1} was caught in the aftermath!", user.pbThis))
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:ANGERPOINT,
  proc { |ability, user, target, move, battle|
    next if !target.damageState.critical
    next if !target.pbCanRaiseStatStage?(:ATTACK, target)
    battle.pbShowAbilitySplash(target)
    target.stages[:ATTACK] = 6
    target.statsRaisedThisRound = true
    battle.pbCommonAnimation("StatUp", target)
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} maxed its {2}!", target.pbThis, GameData::Stat.get(:ATTACK).name))
    else
      battle.pbDisplay(_INTL("{1}'s {2} maxed its {3}!",
         target.pbThis, target.abilityName, GameData::Stat.get(:ATTACK).name))
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:COTTONDOWN,
  proc { |ability, user, target, move, battle|
    next if battle.allBattlers.none? { |b| b.pbCanLowerStatStage?(:DEFENSE, target) }
    battle.pbShowAbilitySplash(target)
    battle.allBattlers.each do |b|
      b.pbLowerStatStageByAbility(:SPEED, 1, target, false)
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:CURSEDBODY,
  proc { |ability, user, target, move, battle|
    next if user.fainted?
    next if user.effects[PBEffects::Disable] > 0
    regularMove = nil
    user.eachMove do |m|
      next if m.id != user.lastRegularMoveUsed
      regularMove = m
      break
    end
    next if !regularMove || (regularMove.pp == 0 && regularMove.total_pp > 0)
    next if battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(target)
    if !move.pbMoveFailedAromaVeil?(target, user, Battle::Scene::USE_ABILITY_SPLASH)
      user.effects[PBEffects::Disable]     = 3
      user.effects[PBEffects::DisableMove] = regularMove.id
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} was disabled!", user.pbThis, regularMove.name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} was disabled by {3}'s {4}!",
           user.pbThis, regularMove.name, target.pbThis(true), target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
      user.pbItemStatusCureCheck
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:CUTECHARM,
  proc { |ability, user, target, move, battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(target)
    if user.pbCanAttract?(target, Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} made {3} fall in love!", target.pbThis,
           target.abilityName, user.pbThis(true))
      end
      user.pbAttract(target, msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:EFFECTSPORE,
  proc { |ability, user, target, move, battle|
    # NOTE: This ability has a 30% chance of triggering, not a 30% chance of
    #       inflicting a status condition. It can try (and fail) to inflict a
    #       status condition that the user is immune to.
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100) >= 30
    r = battle.pbRandom(3)
    next if r == 0 && user.asleep?
    next if r == 1 && user.poisoned?
    next if r == 2 && user.paralyzed?
    battle.pbShowAbilitySplash(target)
    if user.affectedByPowder?(Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      case r
      when 0
        if user.pbCanSleep?(target, Battle::Scene::USE_ABILITY_SPLASH)
          msg = nil
          if !Battle::Scene::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} made {3} fall asleep!", target.pbThis,
               target.abilityName, user.pbThis(true))
          end
          user.pbSleep(msg)
        end
      when 1
        if user.pbCanPoison?(target, Battle::Scene::USE_ABILITY_SPLASH)
          msg = nil
          if !Battle::Scene::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} poisoned {3}!", target.pbThis,
               target.abilityName, user.pbThis(true))
          end
          user.pbPoison(target, msg)
        end
      when 2
        if user.pbCanParalyze?(target, Battle::Scene::USE_ABILITY_SPLASH)
          msg = nil
          if !Battle::Scene::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
               target.pbThis, target.abilityName, user.pbThis(true))
          end
          user.pbParalyze(target, msg)
        end
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:FLAMEBODY,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.burned? || battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(target)
    if user.pbCanBurn?(target, Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}!", target.pbThis, target.abilityName, user.pbThis(true))
      end
      user.pbBurn(target, msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:GOOEY,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    user.pbLowerStatStageByAbility(:SPEED, 1, target, true, true)
  }
)

Battle::AbilityEffects::OnBeingHit.copy(:GOOEY, :TANGLINGHAIR)

Battle::AbilityEffects::OnBeingHit.add(:ILLUSION,
  proc { |ability, user, target, move, battle|
    # NOTE: This intentionally doesn't show the ability splash.
    next if !target.effects[PBEffects::Illusion]
    target.effects[PBEffects::Illusion] = nil
    battle.scene.pbChangePokemon(target, target.pokemon)
    battle.pbDisplay(_INTL("{1}'s illusion wore off!", target.pbThis))
    battle.pbSetSeen(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:INNARDSOUT,
  proc { |ability, user, target, move, battle|
    next if !target.fainted? || user.dummy
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(target.damageState.hpLost, false)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!", user.pbThis,
           target.pbThis(true), target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:IRONBARBS,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp / 8, false)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!", user.pbThis,
           target.pbThis(true), target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.copy(:IRONBARBS, :ROUGHSKIN)

Battle::AbilityEffects::OnBeingHit.add(:JUSTIFIED,
  proc { |ability, user, target, move, battle|
    next if move.calcType != :DARK
    target.pbRaiseStatStageByAbility(:ATTACK, 1, target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:MUMMY,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    next if user.unstoppableAbility? || user.ability == ability
    oldAbil = nil
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
      user.ability = ability
      battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!", user.pbThis, user.abilityName))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis, user.abilityName, target.pbThis(true)))
      end
      battle.pbHideAbilitySplash(user) if user.opposes?(target)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnLosingAbility(oldAbil)
    user.pbTriggerAbilityOnGainingIt
  }
)

Battle::AbilityEffects::OnBeingHit.add(:PERISHBODY,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    next if user.effects[PBEffects::PerishSong] > 0 || target.effects[PBEffects::PerishSong] > 0
    battle.pbShowAbilitySplash(target)
    if user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      user.effects[PBEffects::PerishSong] = 4
      user.effects[PBEffects::PerishSongUser] = target.index
      target.effects[PBEffects::PerishSong] = 4
      target.effects[PBEffects::PerishSongUser] = target.index
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
      else
        battle.pbDisplay(_INTL("Both Pokémon will faint in three turns because of {1}'s {2}!",
           target.pbThis(true), target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:POISONPOINT,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.poisoned? || battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(target)
    if user.pbCanPoison?(target, Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!", target.pbThis, target.abilityName, user.pbThis(true))
      end
      user.pbPoison(target, msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:RATTLED,
  proc { |ability, user, target, move, battle|
    next if ![:BUG, :DARK, :GHOST].include?(move.calcType)
    target.pbRaiseStatStageByAbility(:SPEED, 1, target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:SANDSPIT,
  proc { |ability, user, target, move, battle|
    battle.pbStartWeatherAbility(:Sandstorm, target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:STAMINA,
  proc { |ability, user, target, move, battle|
    target.pbRaiseStatStageByAbility(:DEFENSE, 1, target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:STATIC,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.paralyzed? || battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(target)
    if user.pbCanParalyze?(target, Battle::Scene::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
           target.pbThis, target.abilityName, user.pbThis(true))
      end
      user.pbParalyze(target, msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:WANDERINGSPIRIT,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.ungainableAbility? || [:RECEIVER, :WONDERGUARD].include?(user.ability_id)
    oldUserAbil   = nil
    oldTargetAbil = nil
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
      oldUserAbil   = user.ability
      oldTargetAbil = target.ability
      user.ability   = oldTargetAbil
      target.ability = oldUserAbil
      if user.opposes?(target)
        battle.pbReplaceAbilitySplash(user)
        battle.pbReplaceAbilitySplash(target)
      end
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} swapped Abilities with {2}!", target.pbThis, user.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1} swapped its {2} Ability with {3}'s {4} Ability!",
           target.pbThis, user.abilityName, user.pbThis(true), target.abilityName))
      end
      if user.opposes?(target)
        battle.pbHideAbilitySplash(user)
        battle.pbHideAbilitySplash(target)
      end
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnLosingAbility(oldUserAbil)
    target.pbOnLosingAbility(oldTargetAbil)
    user.pbTriggerAbilityOnGainingIt
    target.pbTriggerAbilityOnGainingIt
  }
)

Battle::AbilityEffects::OnBeingHit.add(:WATERCOMPACTION,
  proc { |ability, user, target, move, battle|
    next if move.calcType != :WATER
    target.pbRaiseStatStageByAbility(:DEFENSE, 2, target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:WEAKARMOR,
  proc { |ability, user, target, move, battle|
    next if !move.pbPhysicalMove?(user)
    next if !target.pbCanLowerStatStage?(:DEFENSE, target) &&
            !target.pbCanRaiseStatStage?(:SPEED, target)
    battle.pbShowAbilitySplash(target)
    target.pbLowerStatStageByAbility(:DEFENSE, 1, target, false)
    target.pbRaiseStatStageByAbility(:SPEED,
       (Settings::MECHANICS_GENERATION >= 7) ? 2 : 1, target, false)
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:AMBIENTAMNESIA,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
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

Battle::AbilityEffects::OnBeingHit.add(:ENTANGLINGMESS,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(10) < 5
    next if user.effects[PBEffects::Trapping]>0
    next if !user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
    battle.pbShowAbilitySplash(target)
    # Set trapping effect duration and info
    user.effects[PBEffects::Trapping] = 2+battle.pbRandom(2)
    user.effects[PBEffects::TrappingMove] = :BIND
    user.effects[PBEffects::TrappingUser] = target.index
    battle.pbDisplay(_INTL("{1} was squeezed by {2}!",user.pbThis,target.pbThis(true)))
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:KAMIKAZE,
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

Battle::AbilityEffects::OnBeingHit.add(:MADNESS,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(10) < 5
    next if !user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
    battle.pbShowAbilitySplash(target)
    if user.pbCanConfuse?(target)
      user.pbConfuse(_INTL("{1} confused {2}!",target.pbThis,user.pbThis(true)))
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:PHILANTHROPIST,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(10) < 5
    next if !user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
    if user.status != PBStatuses::NONE
      battle.pbShowAbilitySplash(target)
      user.pbCureStatus
      battle.pbHideAbilitySplash(target)
    end
  }
)

Battle::AbilityEffects::OnBeingHit.add(:THERMALPOWER,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :ICE
    if target.pbCanLowerStatStage?(:SPEED,target)
      target.pbLowerStatStageByAbility(:SPEED,1,target)
    end
  }
)

Battle::AbilityEffects::OnBeingHit.add(:VINDICTIVE,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    stat = :ATTACK
    # Photon Geyser uses the higher of Sp. Atk and Attack
    if move.pbSpecialMove?(user) || (move.function == "CategoryDependsOnHigherDamageIgnoreTargetAbility" && user.spatk >= user.attack)
      stat = :SPECIAL_ATTACK
    end
    if user.pbCanLowerStatStage?(stat,user)
      user.pbLowerStatStageByAbility(stat,2,target)
    end
  }
)

Battle::AbilityEffects::OnBeingHit.add(:REFLECTIVE,
  proc { |ability,user,target,move,battle|
    if move.pbSpecialMove?(user) && !user.hasActiveAbility?(:ROCKHEAD) && user.takesIndirectDamage?
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
      battle.scene.pbDamageAnimation(user,0)
      user.pbTakeEffectDamage(target.damageState.calcDamage/2)
      battle.pbHideAbilitySplash(target)
    end
  }
)

Battle::AbilityEffects::OnBeingHit.add(:BATTLESTANCE,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !target.pbCanRaiseStatStage?(:ATTACK, target)
    target.pbRaiseStatStageByAbility(:ATTACK, 1, target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:EDIBLE,
  proc { |ability,user,target,move,battle|
    next if !move.bitingMove?
    next if !target.pbCanRaiseStatStage?(:SPEED, target)
    target.pbRaiseStatStageByAbility(:SPEED, 2, target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:CRYSTALADAPTATION,
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

Battle::AbilityEffects::OnBeingHit.add(:VIGILANT,
  proc { |ability,user,target,move,battle|
    next if !target.asleep?
    battle.pbShowAbilitySplash(target)
    target.pbCureStatus
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:WEBCOVER,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
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

Battle::AbilityEffects::OnBeingHit.add(:PUSHBOMB,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    if battle.pbRandom(100) < 30 && !target.fainted?
      battle.pbShowAbilitySplash(target)
      target.pbUseMoveSimple(:EXPLOSION,user.index)
      battle.pbHideAbilitySplash(target)
    end
  }
)

Battle::AbilityEffects::OnBeingHit.add(:VINECOILSTYLE,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.effects[PBEffects::Trapping] > 0
    battle.pbShowAbilitySplash(target)
    if user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      user.effects[PBEffects::Trapping] = 5
      user.effects[PBEffects::TrappingMove] = :WRAP
      user.effects[PBEffects::TrappingUser] = target.index
      battle.pbDisplay(_INTL("{1} was trapped!", user.pbThis))
    end
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:VOODOO,
  proc { |ability,user,target,move,battle|
    # Collect all battlers of the same egg group
    targetBattlers = []
    battle.allBattlers.each do |b|
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
      b.pbTakeEffectDamage(target.damageState.calcDamage, false)
    end
    battle.pbDisplay(_INTL("{1} shared its damage with other Pokemon on the field!", target.pbThis))
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:FRAGRANCE,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100) >= 30
    atk_stat = move.pbSpecialMove?(user) ? :SPECIAL_ATTACK : :ATTACK
    next if !user.pbCanLowerStatStage?(atk_stat, target)
    if user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      user.pbLowerStatStageByAbility(atk_stat, 1, target)
    end
  }
)

Battle::AbilityEffects::OnBeingHit.add(:COUNTERPARRY,
  proc { |ability,user,target,move,battle|
    next if !move.pbPhysicalMove?(user)
    target.effects[PBEffects::CounterParry] = true
  }
)

Battle::AbilityEffects::OnBeingHit.add(:DELIRIUM,
  proc { |ability,user,target,move,battle|
    next if !target.isSpecies?(:NEBULANIAN) || target.form == 1
    next if !Effectiveness.super_effective?(target.damageState.typeMod)
    battle.pbShowAbilitySplash(target)
    target.pbChangeForm(1, _INTL("{1} became angry!", target.pbThis))
    battle.pbHideAbilitySplash(target)
  }
)

#===============================================================================
# OnDealingHit handlers
#===============================================================================

Battle::AbilityEffects::OnDealingHit.add(:POISONTOUCH,
  proc { |ability, user, target, move, battle|
    next if !move.contactMove?
    next if battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanPoison?(user, Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!", user.pbThis, user.abilityName, target.pbThis(true))
      end
      target.pbPoison(user, msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:FORESTFIRE,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if move.calcType != :GRASS
    battle.pbShowAbilitySplash(user)
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} added extra fire damage!",user.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} added extra fire damage!",user.pbThis,user.abilityName))
    end
    user.pbUseMoveSimple(:FORESTFIREATTACK,target.index)
    battle.pbHideAbilitySplash(user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:ENTANGLINGMESS,
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

Battle::AbilityEffects::OnDealingHit.add(:MADNESS,
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

Battle::AbilityEffects::OnDealingHit.add(:PHILANTHROPIST,
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

Battle::AbilityEffects::OnDealingHit.add(:TAINTEDPOWER,
  proc { |ability,user,target,move,battle|
    next if !move.pbDamagingMove?
    battle.pbShowAbilitySplash(user)
    battle.scene.pbDamageAnimation(user)
    user.pbReduceHP(user.totalhp/8)
    battle.pbDisplay(_INTL("{1} was hurt by its Tainted Power!",user.pbThis))
    battle.pbHideAbilitySplash(user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:REVERB,
  proc { |ability,user,target,move,battle|
    next if !move.pbDamagingMove?
    next if move.calcType != :SOUND && !move.pbSoundMove?(user)
    target.effects[PBEffects::ReverbDamage] += target.damageState.calcDamage * 0.3
    target.effects[PBEffects::ReverbDamage] = 1 if target.effects[PBEffects::ReverbDamage] < 1
  }
)

Battle::AbilityEffects::OnDealingHit.add(:BATTLESTANCE,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !user.pbCanRaiseStatStage?(:ATTACK, user)
    user.pbRaiseStatStageByAbility(:ATTACK, 1, user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:ROARINGHORN,
  proc { |ability,user,target,move,battle|
    next if move.pbTarget(user).num_targets > 1
    next if !user.opposes?(target)
    battle.allSameSideBattlers(target.index).each do |b|
      next if b.index != target.index + 2 && b.index != target.index - 2
      next if !b.takesIndirectDamage?
      battle.pbShowAbilitySplash(user)
      battle.pbDisplay(_INTL("{1} took damage from the impact!",b.pbThis))
      battle.scene.pbDamageAnimation(b)
      b.pbTakeEffectDamage(target.damageState.calcDamage/2)
      battle.pbHideAbilitySplash(user)
    end
  }
)

Battle::AbilityEffects::OnDealingHit.add(:BLAST,
  proc { |ability,user,target,move,battle|
    next if !user.opposes?(target)
    target.effects[PBEffects::BlastUsers].push(user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:SPICETANK,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :POISON
    next if !target.pbCanBurn?(user, false)
    next if battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(user)
    target.pbBurn(user)
    battle.pbHideAbilitySplash(user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:SLOPPY,
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

Battle::AbilityEffects::OnDealingHit.add(:VICTORYRUSH,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    battle.pbShowAbilitySplash(user)
    battle.pbDisplay(_INTL("{1} is on its {2}!", user.pbThis, user.abilityName))
    user.effects[PBEffects::VictoryRush] = true
    battle.pbHideAbilitySplash(user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:SOUNDWAVES,
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

Battle::AbilityEffects::OnDealingHit.add(:SUPERNOVA,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :COSMIC
    battle.pbShowAbilitySplash(user)
    user.pbUseMoveSimple(:SUPERNOVAATTACK)
    battle.pbHideAbilitySplash(user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:LIQUIDCONDUCTION,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :WATER
    next if battle.pbRandom(100) >= 20
    next if !target.pbCanParalyze?(user, false)
    battle.pbShowAbilitySplash(user)
    target.pbParalyze(user)
    battle.pbHideAbilitySplash(user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:HEALTHYDIET,
  proc { |ability,user,target,move,battle|
    next if !move.bitingMove?
    next if !user.canHeal?
    battle.pbShowAbilitySplash(user)
    user.pbRecoverHP(target.damageState.hpLost * 0.6)
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",user.pbThis,user.abilityName))
    end
    battle.pbHideAbilitySplash(user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:PUNISHER,
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

Battle::AbilityEffects::OnDealingHit.add(:WHIRLPOOLSTYLE,
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

Battle::AbilityEffects::OnDealingHit.add(:FRAGRANCE,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100) >= 30
    atk_stat = move.pbSpecialMove?(user) ? :SPECIAL_ATTACK : :ATTACK
    next if !target.pbCanLowerStatStage?(atk_stat, user)
    target.pbLowerStatStageByAbility(atk_stat, 1, user)
  }
)

Battle::AbilityEffects::OnDealingHit.add(:CRYSTALSTINGER,
  proc { |ability,user,target,move,battle|
    next if !user.takesIndirectDamage?
    battle.pbShowAbilitySplash(user)
    battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    battle.scene.pbDamageAnimation(user,0)
    user.pbTakeEffectDamage(target.damageState.calcDamage/2)
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# OnEndOfUsingMove handlers
#===============================================================================

Battle::AbilityEffects::OnEndOfUsingMove.add(:BEASTBOOST,
  proc { |ability, user, targets, move, battle|
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

Battle::AbilityEffects::OnEndOfUsingMove.add(:CHILLINGNEIGH,
  proc { |ability, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0 || !user.pbCanRaiseStatStage?(:ATTACK, user)
    user.ability_id = :CHILLINGNEIGH   # So the As One abilities can just copy this
    user.pbRaiseStatStageByAbility(:ATTACK, 1, user)
    user.ability_id = ability
  }
)

Battle::AbilityEffects::OnEndOfUsingMove.copy(:CHILLINGNEIGH, :ASONECHILLINGNEIGH)

Battle::AbilityEffects::OnEndOfUsingMove.add(:GRIMNEIGH,
  proc { |ability, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0 || !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user)
    user.ability_id = :GRIMNEIGH   # So the As One abilities can just copy this
    user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 1, user)
    user.ability_id = ability
  }
)

Battle::AbilityEffects::OnEndOfUsingMove.copy(:GRIMNEIGH, :ASONEGRIMNEIGH)

Battle::AbilityEffects::OnEndOfUsingMove.add(:MAGICIAN,
  proc { |ability, user, targets, move, battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if user.item
    next if user.wild?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!", b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      user.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true if b.hasActiveAbility?(:UNBURDEN)
      if battle.wildBattle? && !user.initialItem && user.item == b.initialItem
        user.setInitialItem(user.item)
        b.setInitialItem(nil)
      end
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} stole {2}'s {3}!", user.pbThis,
           b.pbThis(true), user.itemName))
      else
        battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!", user.pbThis,
           b.pbThis(true), user.itemName, user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      user.pbHeldItemTriggerCheck
      break
    end
  }
)

Battle::AbilityEffects::OnEndOfUsingMove.add(:MOXIE,
  proc { |ability, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0 || !user.pbCanRaiseStatStage?(:ATTACK, user)
    user.pbRaiseStatStageByAbility(:ATTACK, numFainted, user)
  }
)

Battle::AbilityEffects::OnEndOfUsingMove.add(:TRICKSTER,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if !move.pbContactMove?(user)
    next if user.wild?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if user.item==0 && b.item==0
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item) || b.unlosableItem?(user.item) || user.unlosableItem?(user.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD) && !battle.moldBreaker
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be swapped!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      oldUserItem = user.item;     oldUserItemName = user.itemName
      oldTargetItem = b.item; oldTargetItemName = b.itemName
      user.item                             = oldTargetItem
      user.effects[PBEffects::ChoiceBand]   = nil
      user.effects[PBEffects::Unburden]     = (!user.item && oldUserItem) if user.hasActiveAbility?(:UNBURDEN)
      b.item                           = oldUserItem
      b.effects[PBEffects::ChoiceBand] = nil
      b.effects[PBEffects::Unburden]   = (!b.item && oldTargetItem) if b.hasActiveAbility?(:UNBURDEN)
      # Permanently steal the item from wild Pokémon
      if b.wild? && b.initialItem == oldTargetItem && !user.initialItem
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

Battle::AbilityEffects::OnEndOfUsingMove.add(:OPPORTUNIST,
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

Battle::AbilityEffects::OnEndOfUsingMove.add(:SHARPENER,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove?
    next if !user.pbCanRaiseStatStage?(:ATTACK, user)
    user.pbRaiseStatStageByAbility(:ATTACK, 1, user)
  }
)

Battle::AbilityEffects::OnEndOfUsingMove.add(:HUNGRY,
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
        if Battle::Scene::USE_ABILITY_SPLASH
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
      b.effects[PBEffects::Unburden] = true if b.hasActiveAbility?(:UNBURDEN)
      if Battle::Scene::USE_ABILITY_SPLASH
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

Battle::AbilityEffects::OnEndOfUsingMove.add(:MASTERTHIEF,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if !move.pbContactMove?(user)
    next if user.wild?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      # Steal item
      if !user.item
        user.item = b.item
        b.item = nil
        b.effects[PBEffects::Unburden] = true if b.hasActiveAbility?(:UNBURDEN)
        if battle.wildBattle? && !user.initialItem && user.item == b.initialItem
          user.setInitialItem(user.item)
          b.setInitialItem(nil)
        end
        if Battle::Scene::USE_ABILITY_SPLASH
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
        b.effects[PBEffects::Unburden] = true if b.hasActiveAbility?(:UNBURDEN)
        if Battle::Scene::USE_ABILITY_SPLASH
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

Battle::AbilityEffects::OnEndOfUsingMove.add(:TASTYTREAT,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      food_items_with_battle_handler_list = [:LAVACOOKIE, :OLDGATEAU, :CASTELIACONE, :BERRYJUICE, :RAGECANDYBAR, :SWEETHEART, :FRESHWATER, :SODAPOP, :LEMONADE, :MOOMOOMILK, :ENERGYPOWDER, :ENERGYROOT, :HEALPOWDER, :CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY, :ORANBERRY, :PERSIMBERRY, :LUMBERRY, :SITRUSBERRY, :LUMIOSEGALETTE, :SHALOURSABLE, :BIGMALASADA]
      food_items_without_battle_handler_list = [:HONEY, :REDAPRICORN, :YELLOWAPRICORN, :BLUEAPRICORN, :GREENAPRICORN, :PINKAPRICORN, :WHITEAPRICORN, :BLACKAPRICORN, :TINYMUSHROOM, :BIGMUSHROOM, :BALMMUSHROOM, :LUCKYEGG, :BIGROOT, :BLACKSLUDGE, :LEFTOVERS, :MENTALHERB, :WHITEHERB, :POWERHERB, :ABSORBBULB, :MIRACLESEED, :SACREDASH, :REVIVALHERB, :LEPPABERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY, :RAZZBERRY, :BLUKBERRY, :NANABBERRY, :WEPEARBERRY, :PINAPBERRY, :POMEGBERRY, :KELPSYBERRY, :QUALOTBERRY, :HONDEWBERRY, :GREPABERRY, :TAMATOBERRY, :CORNNBERRY, :MAGOSTBERRY, :RABUTABERRY, :NOMELBERRY, :SPELONBERRY, :PAMTREBERRY, :WATMELBERRY, :DURINBERRY, :BELUEBERRY, :OCCABERRY, :PASSHOBERRY, :WACANBERRY, :RINDOBERRY, :YACHEBERRY, :CHOPLEBERRY, :KEBIABERRY, :SHUCABERRY, :COBABERRY, :PAYAPABERRY, :TANGABERRY, :CHARTIBERRY, :KASIBBERRY, :HABANBERRY, :COLBURBERRY, :BABIRIBERRY, :CHILANBERRY, :LIECHIBERRY, :GANLONBERRY, :SALACBERRY, :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY, :ENIGMABERRY, :MICLEBERRY, :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY, :GRACIDEA, :REDNECTAR, :YELLOWNECTAR, :PINKNECTAR, :PURPLENECTAR, :ELECTRICSEED, :PSYCHICSEED, :MISTYSEED, :GRASSYSEED, :LUMINOUSMOSS, :SNOWBALL, :WHIPPEDDREAM, :ROSELIBERRY, :KEEBERRY, :MARANGABERRY, :ROYALHONEY, :LIGHTNUT, :LIGHTSEED, :ALOLANPANCAKES, :POPROCK, :RISCIBERRY, :LONELYMINT, :ADAMANTMINT, :NAUGHTYMINT, :BRAVEMINT, :BOLDMINT, :IMPISHMINT, :LAXMINT, :RELAXEDMINT, :MODESTMINT, :MILDMINT, :RASHMINT, :QUIETMINT, :CALMMINT, :GENTLEMINT, :CAREFULMINT, :SASSYMINT, :TIMIDMINT, :HASTYMINT, :JOLLYMINT, :NAIVEMINT, :SERIOUSMINT, :SWEETAPPLE, :TARTAPPLE, :STRAWBERRYSWEET, :LOVESWEET, :BERRYSWEET, :CLOVERSWEET, :FLOWERSWEET, :STARSWEET, :RIBBONSWEET]
      food_item_list = food_items_with_battle_handler_list.union(food_items_without_battle_handler_list)
      next if !food_item_list.include?(b.item.id)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      old_target_item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true if b.hasActiveAbility?(:UNBURDEN)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} ate {2}'s {3}!",user.pbThis,
           b.pbThis(true),old_target_item.name))
      else
        battle.pbDisplay(_INTL("{1} ate {2}'s {3} with {4}!",user.pbThis,
           b.pbThis(true),old_target_item.name,user.abilityName))
      end
      user.pbRecoverHP(user.totalhp/4)
      battle.pbDisplay(_INTL("{1}'s HP was restored.", user.pbThis))
      if food_items_with_battle_handler_list.include?(old_target_item.id)
        if old_target_item.id == :REVIVALHERB ||
           ItemHandlers.triggerCanUseInBattle(old_target_item.id, user.pokemon, user, nil, nil, battle, nil, false)
          ItemHandlers.triggerUseInBattle(old_target_item.id, user, battle)
          ItemHandlers.triggerBattleUseOnBattler(old_target_item.id, user, battle.scene)
          ItemHandlers.triggerBattleUseOnPokemon(old_target_item.id, user.pokemon, user, nil, battle.scene)
        end
      else
        # TODO: alt effect
        case old_target_item.id
        when :HONEY
          
        end
      end
      battle.pbHideAbilitySplash(user)
      break
    end
  }
)

Battle::AbilityEffects::OnEndOfUsingMove.add(:WONDERHARP,
  proc { |ability,user,targets,move,battle|
    next if move.calcType != :SOUND && !move.pbSoundMove?(user)
    battle.pbShowAbilitySplash(user)
    battle.allSameSideBattlers(user.index).each do |b|
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

Battle::AbilityEffects::OnEndOfUsingMove.add(:OVERCHARGED,
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

Battle::AbilityEffects::OnEndOfUsingMove.add(:PROXY,
  proc { |ability,user,targets,move,battle|
    next if !user.isSpecies?(:PHANTITUTE)
    next if move.pp == 0
    move.pp -= 1
  }
)

#===============================================================================
# AfterMoveUseFromTarget handlers
#===============================================================================

Battle::AbilityEffects::AfterMoveUseFromTarget.add(:BERSERK,
  proc { |ability, target, user, move, switched_battlers, battle|
    next if !move.damagingMove?
    next if !target.droppedBelowHalfHP
    next if !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK, target)
    target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 1, target)
  }
)

Battle::AbilityEffects::AfterMoveUseFromTarget.add(:COLORCHANGE,
  proc { |ability, target, user, move, switched_battlers, battle|
    next if target.damageState.calcDamage == 0 || target.damageState.substitute
    next if !move.calcType || GameData::Type.get(move.calcType).pseudo_type
    next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
    typeName = GameData::Type.get(move.calcType).name
    battle.pbShowAbilitySplash(target)
    target.pbChangeTypes(move.calcType)
    battle.pbDisplay(_INTL("{1}'s type changed to {2} because of its {3}!",
       target.pbThis, typeName, target.abilityName))
    battle.pbHideAbilitySplash(target)
  }
)

Battle::AbilityEffects::AfterMoveUseFromTarget.add(:PICKPOCKET,
  proc { |ability, target, user, move, switched_battlers, battle|
    # NOTE: According to Bulbapedia, this can still trigger to steal the user's
    #       item even if it was switched out by a Red Card. That doesn't make
    #       sense, so this code doesn't do it.
    next if target.wild?
    next if switched_battlers.include?(user.index)   # User was switched out
    next if !move.contactMove?
    next if user.effects[PBEffects::Substitute] > 0 || target.damageState.substitute
    next if target.item || !user.item
    next if user.unlosableItem?(user.item) || target.unlosableItem?(user.item)
    battle.pbShowAbilitySplash(target)
    if user.hasActiveAbility?(:STICKYHOLD)
      battle.pbShowAbilitySplash(user) if target.opposes?(user)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s item cannot be stolen!", user.pbThis))
      end
      battle.pbHideAbilitySplash(user) if target.opposes?(user)
      battle.pbHideAbilitySplash(target)
      next
    end
    target.item = user.item
    user.item = nil
    user.effects[PBEffects::Unburden] = true if user.hasActiveAbility?(:UNBURDEN)
    if battle.wildBattle? && !target.initialItem && target.item == user.initialItem
      target.setInitialItem(target.item)
      user.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!", target.pbThis,
       user.pbThis(true), target.itemName))
    battle.pbHideAbilitySplash(target)
    target.pbHeldItemTriggerCheck
  }
)

#===============================================================================
# EndOfRoundWeather handlers
#===============================================================================

Battle::AbilityEffects::EndOfRoundWeather.add(:DRYSKIN,
  proc { |ability, weather, battler, battle|
    case weather
    when :Sun, :HarshSun
      battle.pbShowAbilitySplash(battler)
      battle.scene.pbDamageAnimation(battler)
      battler.pbReduceHP(battler.totalhp / 8, false)
      battle.pbDisplay(_INTL("{1} was hurt by the sunlight!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
      battler.pbItemHPHealCheck
    when :Rain, :HeavyRain, :Thunderstorm
      next if !battler.canHeal?
      battle.pbShowAbilitySplash(battler)
      battler.pbRecoverHP(battler.totalhp / 8)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored its HP.", battler.pbThis, battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

Battle::AbilityEffects::EndOfRoundWeather.add(:ICEBODY,
  proc { |ability, weather, battler, battle|
    next unless weather == :Hail
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp / 16)
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.", battler.pbThis, battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundWeather.add(:ICEFACE,
  proc { |ability, weather, battler, battle|
    next if weather != :Hail
    next if !battler.canRestoreIceFace || battler.form != 1
    battle.pbShowAbilitySplash(battler)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} activated!", battler.pbThis, battler.abilityName))
    end
    battler.pbChangeForm(0, _INTL("{1} transformed!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundWeather.add(:RAINDISH,
  proc { |ability, weather, battler, battle|
    next unless [:Rain, :HeavyRain].include?(weather)
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp / 16)
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.", battler.pbThis, battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundWeather.add(:SOLARPOWER,
  proc { |ability, weather, battler, battle|
    next unless [:Sun, :HarshSun].include?(weather)
    battle.pbShowAbilitySplash(battler)
    battle.scene.pbDamageAnimation(battler)
    battler.pbReduceHP(battler.totalhp / 8, false)
    battle.pbDisplay(_INTL("{1} was hurt by the sunlight!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    battler.pbItemHPHealCheck
  }
)

Battle::AbilityEffects::EndOfRoundWeather.add(:LIGHTGUARD,
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

Battle::AbilityEffects::EndOfRoundWeather.add(:RAINBOON,
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

Battle::AbilityEffects::EndOfRoundWeather.add(:WEATHERBENEFIT,
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
# EndOfRoundHealing handlers
#===============================================================================

Battle::AbilityEffects::EndOfRoundHealing.add(:HEALER,
  proc { |ability, battler, battle|
    next unless battle.pbRandom(100) < 30
    battler.allAllies.each do |b|
      next if b.status == :NONE
      battle.pbShowAbilitySplash(battler)
      oldStatus = b.status
      b.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
      if !Battle::Scene::USE_ABILITY_SPLASH
        case oldStatus
        when :SLEEP
          battle.pbDisplay(_INTL("{1}'s {2} woke its partner up!", battler.pbThis, battler.abilityName))
        when :POISON
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's poison!", battler.pbThis, battler.abilityName))
        when :BURN
          battle.pbDisplay(_INTL("{1}'s {2} healed its partner's burn!", battler.pbThis, battler.abilityName))
        when :PARALYSIS
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's paralysis!", battler.pbThis, battler.abilityName))
        when :FROZEN
          battle.pbDisplay(_INTL("{1}'s {2} defrosted its partner!", battler.pbThis, battler.abilityName))
        end
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

Battle::AbilityEffects::EndOfRoundHealing.add(:HYDRATION,
  proc { |ability, battler, battle|
    next if battler.status == :NONE
    next if ![:Rain, :HeavyRain, :Thunderstorm].include?(battler.effectiveWeather)
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
    if !Battle::Scene::USE_ABILITY_SPLASH
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!", battler.pbThis, battler.abilityName))
      when :POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poison!", battler.pbThis, battler.abilityName))
      when :BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!", battler.pbThis, battler.abilityName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!", battler.pbThis, battler.abilityName))
      when :FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!", battler.pbThis, battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundHealing.add(:SHEDSKIN,
  proc { |ability, battler, battle|
    next if battler.status == :NONE
    next unless battle.pbRandom(100) < 30
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
    if !Battle::Scene::USE_ABILITY_SPLASH
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!", battler.pbThis, battler.abilityName))
      when :POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poison!", battler.pbThis, battler.abilityName))
      when :BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!", battler.pbThis, battler.abilityName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!", battler.pbThis, battler.abilityName))
      when :FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!", battler.pbThis, battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundHealing.add(:DEEPSLEEPER,
  proc { |ability,battler,battle|
    next if !battler.asleep? || battler.hp == battler.totalhp
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/8)
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundHealing.add(:SYNTHESIZE,
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
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundHealing.add(:SOOTHINGSHINE,
  proc { |ability,battler,battle|
    # Validates if any battlers on same side need healing
    canHealAnyBattler = false
    battle.allSameSideBattlers(battler.index).each do |b|
      canHealAnyBattler = true if b.canHeal?
    end
    next if !canHealAnyBattler
    # Ability effect
    battle.pbShowAbilitySplash(battler)
    healfactor = [:Sun, :HarshSun].include?(battle.pbWeather) ? 8 : 16
    battle.allSameSideBattlers(battler.index).each do |b|
      next if !b.canHeal?
      b.pbRecoverHP(b.totalhp/healfactor)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s HP.",battler.pbThis,battler.abilityName,b.pbThis(true)))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundHealing.add(:ADDITION,
  proc { |ability,battler,battle|
    # Validates if any battlers on same side need healing
    canHealAnyBattler = false
    battle.allSameSideBattlers(battler.index).each do |b|
      canHealAnyBattler = true if b.canHeal?
    end
    next if !canHealAnyBattler
    # Ability effect
    battle.pbShowAbilitySplash(battler)
    healmult = battle.pbCheckAllyAbility(:SUBTRACTION, battler.index) ? 0.3 : 0.1
    battle.allSameSideBattlers(battler.index).each do |b|
      next if !b.canHeal?
      b.pbRecoverHP(b.totalhp * healmult)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s HP.",battler.pbThis,battler.abilityName,b.pbThis(true)))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# EndOfRoundEffect handlers
#===============================================================================

Battle::AbilityEffects::EndOfRoundEffect.add(:BADDREAMS,
  proc { |ability, battler, battle|
    battle.allOtherSideBattlers(battler.index).each do |b|
      next if !b.near?(battler) || !b.asleep?
      battle.pbShowAbilitySplash(battler)
      next if !b.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH)
      b.pbTakeEffectDamage(b.totalhp / 8) { |hp_lost|
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1} is tormented!", b.pbThis))
        else
          battle.pbDisplay(_INTL("{1} is tormented by {2}'s {3}!",
             b.pbThis, battler.pbThis(true), battler.abilityName))
        end
        battle.pbHideAbilitySplash(battler)
      }
    end
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:MOODY,
  proc { |ability, battler, battle|
    randomUp = []
    randomDown = []
    if Settings::MECHANICS_GENERATION >= 8
      GameData::Stat.each_main_battle do |s|
        randomUp.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler)
        randomDown.push(s.id) if battler.pbCanLowerStatStage?(s.id, battler)
      end
    else
      GameData::Stat.each_battle do |s|
        randomUp.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler)
        randomDown.push(s.id) if battler.pbCanLowerStatStage?(s.id, battler)
      end
    end
    next if randomUp.length == 0 && randomDown.length == 0
    battle.pbShowAbilitySplash(battler)
    if randomUp.length > 0
      r = battle.pbRandom(randomUp.length)
      battler.pbRaiseStatStageByAbility(randomUp[r], 2, battler, false)
      randomDown.delete(randomUp[r])
    end
    if randomDown.length > 0
      r = battle.pbRandom(randomDown.length)
      battler.pbLowerStatStageByAbility(randomDown[r], 1, battler, false)
    end
    battle.pbHideAbilitySplash(battler)
    battler.pbItemStatRestoreCheck if randomDown.length > 0
    battler.pbItemOnStatDropped
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:SPEEDBOOST,
  proc { |ability, battler, battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount > 0 && battle.choices[battler.index][0] != :Run &&
       battler.pbCanRaiseStatStage?(:SPEED, battler)
      battler.pbRaiseStatStageByAbility(:SPEED, 1, battler)
    end
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:SWEETDREAMS,
  proc { |ability,battler,battle|
    battle.allSameSideBattlers(battler.index).each do |b|
      next if !b.near?(battler) || !b.asleep?
      next if !b.canHeal?
      battle.pbShowAbilitySplash(battler)
      b.pbRecoverHP(b.totalhp/8)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is having a nice dream!",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is having a nice dream thanks to {2}'s {3}!",b.pbThis,
           battler.pbThis(true),battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:SIGNALBOOST,
  proc { |ability, battler, battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount > 0 && battle.choices[battler.index][0] != :Run &&
       battler.pbCanRaiseStatStage?(:ACCURACY, battler)
      battler.pbRaiseStatStageByAbility(:ACCURACY, 1, battler)
    end
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:ALLSEEING,
  proc { |ability,battler,battle|
    battle.allOtherSideBattlers(battler.index).each do |b|
      if b.near?(battler) && b.pbCanLowerStatStage?(:EVASION,battler)
        b.pbLowerStatStageByAbility(:EVASION,1,battler)
      end
    end
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:VICTORYRUSH,
  proc { |ability,battler,battle|
    next if !battler.effects[PBEffects::VictoryRush]
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s {2} ended!", battler.pbThis, battler.abilityName))
    battler.effects[PBEffects::VictoryRush] = false
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:DYNAMICPOWER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.effects[PBEffects::DynamicPower] += 1
    battle.pbDisplay(_INTL("{1}'s base stats increased!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:COUNTERPARRY,
  proc { |ability,battler,battle|
    battler.effects[PBEffects::CounterParry] = false
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:SOULABSORB,
  proc { |ability,battler,battle|
    next if !battler.canHeal?
    # Get number of affected battlers
    battlerCount = 0
    battle.allBattlers.each do |b|
      next if b.index == battler.index
      next if !b.takesIndirectDamage?
      battlerCount += 1
    end
    # Calculate hp drain per battler
    totalHPDrain = battle.singleBattle? ? battler.totalhp/4 : battler.totalhp/2
    hpDrain = totalHPDrain / battlerCount
    # Do damage and heal ability user
    battle.pbShowAbilitySplash(battler)
    battle.allBattlers.each do |b|
      next if b.index == battler.index
      next if !b.takesIndirectDamage?(Battle::Scene::USE_ABILITY_SPLASH)
      oldHP = b.hp
      b.pbReduceHP(hpDrain)
      battler.pbRecoverHP(hpDrain) if battler.canHeal?
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} absorbed {2}'s HP!",battler.pbThis,b.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1} absorbed {2}'s HP with {3}!",battler.pbThis,
           b.pbThis(true),battler.abilityName))
      end
      b.pbItemHPHealCheck
      b.pbTakeEffectDamage(oldHP)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:GLEAMINGGLARE,
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
# EndOfRoundGainItem handlers
#===============================================================================

Battle::AbilityEffects::EndOfRoundGainItem.add(:BALLFETCH,
  proc { |ability, battler, battle|
    next if battler.item
    next if battle.first_poke_ball.nil?
    battle.pbShowAbilitySplash(battler)
    battler.item = battle.first_poke_ball
    battler.setInitialItem(battler.item) if !battler.initialItem
    battle.first_poke_ball = nil
    battle.pbDisplay(_INTL("{1} retrieved the thrown {2}!", battler.pbThis, battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

Battle::AbilityEffects::EndOfRoundGainItem.add(:HARVEST,
  proc { |ability, battler, battle|
    next if battler.item
    next if !battler.recycleItem || !GameData::Item.get(battler.recycleItem).is_berry?
    if ![:Sun, :HarshSun].include?(battler.effectiveWeather)
      next unless battle.pbRandom(100) < 50
    end
    battle.pbShowAbilitySplash(battler)
    battler.item = battler.recycleItem
    battler.setRecycleItem(nil)
    battler.setInitialItem(battler.item) if !battler.initialItem
    battle.pbDisplay(_INTL("{1} harvested one {2}!", battler.pbThis, battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

Battle::AbilityEffects::EndOfRoundGainItem.add(:PICKUP,
  proc { |ability, battler, battle|
    next if battler.item
    foundItem = nil
    fromBattler = nil
    use = 0
    battle.allBattlers.each do |b|
      next if b.index == battler.index
      next if b.effects[PBEffects::PickupUse] <= use
      foundItem   = b.effects[PBEffects::PickupItem]
      fromBattler = b
      use         = b.effects[PBEffects::PickupUse]
    end
    next if !foundItem
    battle.pbShowAbilitySplash(battler)
    battler.item = foundItem
    fromBattler.effects[PBEffects::PickupItem] = nil
    fromBattler.effects[PBEffects::PickupUse]  = 0
    fromBattler.setRecycleItem(nil) if fromBattler.recycleItem == foundItem
    if battle.wildBattle? && !battler.initialItem && fromBattler.initialItem == foundItem
      battler.setInitialItem(foundItem)
      fromBattler.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1} found one {2}!", battler.pbThis, battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

#===============================================================================
# CertainSwitching handlers
#===============================================================================

# There aren't any!

#===============================================================================
# TrappingByTarget handlers
#===============================================================================

Battle::AbilityEffects::TrappingByTarget.add(:ARENATRAP,
  proc { |ability, switcher, bearer, battle|
    next true if !switcher.airborne?
  }
)

Battle::AbilityEffects::TrappingByTarget.add(:MAGNETPULL,
  proc { |ability, switcher, bearer, battle|
    next true if switcher.pbHasType?(:STEEL)
  }
)

Battle::AbilityEffects::TrappingByTarget.add(:SHADOWTAG,
  proc { |ability, switcher, bearer, battle|
    next true if !switcher.hasActiveAbility?(:SHADOWTAG)
  }
)

#===============================================================================
# OnSwitchIn handlers
#===============================================================================

Battle::AbilityEffects::OnSwitchIn.add(:AIRLOCK,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} has {2}!", battler.pbThis, battler.abilityName))
    end
    battle.pbDisplay(_INTL("The effects of the weather disappeared."))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.copy(:AIRLOCK, :CLOUDNINE)

Battle::AbilityEffects::OnSwitchIn.add(:ANTICIPATION,
  proc { |ability, battler, battle, switch_in|
    next if !battler.pbOwnedByPlayer?
    battlerTypes = battler.pbTypes(true)
    types = battlerTypes
    found = false
    battle.allOtherSideBattlers(battler.index).each do |b|
      b.eachMove do |m|
        next if m.statusMove?
        if types.length > 0
          moveType = m.type
          if Settings::MECHANICS_GENERATION >= 6 && m.function == "TypeDependsOnUserIVs"   # Hidden Power
            moveType = pbHiddenPower(b.pokemon)[0]
          end
          eff = Effectiveness.calculate(moveType, types[0], types[1], types[2])
          next if Effectiveness.ineffective?(eff)
          next if !Effectiveness.super_effective?(eff) &&
                  !["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(m.function)
        elsif !["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(m.function)
          next
        end
        found = true
        break
      end
      break if found
    end
    if found
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} shuddered with anticipation!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ASONECHILLINGNEIGH,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} has two Abilities!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    battler.ability_id = :UNNERVE
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!", battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
    battler.ability_id = ability
  }
)

Battle::AbilityEffects::OnSwitchIn.copy(:ASONECHILLINGNEIGH, :ASONEGRIMNEIGH)

Battle::AbilityEffects::OnSwitchIn.add(:AURABREAK,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:COMATOSE,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is drowsing!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:CURIOUSMEDICINE,
  proc { |ability, battler, battle, switch_in|
    next if battler.allAllies.none? { |b| b.hasAlteredStatStages? }
    battle.pbShowAbilitySplash(battler)
    battler.allAllies.each do |b|
      next if !b.hasAlteredStatStages?
      b.pbResetStatStages
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stat changes were removed!", b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s stat changes were removed by {2}'s {3}!",
           b.pbThis, battler.pbThis(true), battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:DARKAURA,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a dark aura!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:DAUNTLESSSHIELD,
  proc { |ability, battler, battle, switch_in|
    battler.pbRaiseStatStageByAbility(:DEFENSE, 1, battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:DELTASTREAM,
  proc { |ability, battler, battle, switch_in|
    battle.pbStartWeatherAbility(:StrongWinds, battler, true)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:DESOLATELAND,
  proc { |ability, battler, battle, switch_in|
    battle.pbStartWeatherAbility(:HarshSun, battler, true)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:DOWNLOAD,
  proc { |ability, battler, battle, switch_in|
    oDef = oSpDef = 0
    battle.allOtherSideBattlers(battler.index).each do |b|
      oDef   += b.defense
      oSpDef += b.spdef
    end
    stat = (oDef < oSpDef) ? :ATTACK : :SPECIAL_ATTACK
    battler.pbRaiseStatStageByAbility(stat, 1, battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:DRIZZLE,
  proc { |ability, battler, battle, switch_in|
    battle.pbStartWeatherAbility(:Rain, battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:DROUGHT,
  proc { |ability, battler, battle, switch_in|
    battle.pbStartWeatherAbility(:Sun, battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ELECTRICSURGE,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :Electric
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Electric)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:FAIRYAURA,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a fairy aura!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:FOREWARN,
  proc { |ability, battler, battle, switch_in|
    next if !battler.pbOwnedByPlayer?
    highestPower = 0
    forewarnMoves = []
    battle.allOtherSideBattlers(battler.index).each do |b|
      b.eachMove do |m|
        power = m.baseDamage
        power = 160 if ["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(m.function)
        power = 150 if ["PowerHigherWithUserHP"].include?(m.function)    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["CounterPhysicalDamage",
                        "CounterSpecialDamage",
                        "CounterDamagePlusHalf"].include?(m.function)
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["FixedDamage20",
                       "FixedDamage40",
                       "FixedDamageUserLevel",
                       "LowerTargetHPToUserHP",
                       "FixedDamageUserLevelRandom",
                       "PowerHigherWithUserHappiness",
                       "PowerLowerWithUserHappiness",
                       "PowerHigherWithUserHP",
                       "PowerHigherWithTargetFasterThanUser",
                       "TypeAndPowerDependOnUserBerry",
                       "PowerHigherWithLessPP",
                       "PowerLowerWithUserHP",
                       "PowerHigherWithTargetWeight"].include?(m.function)
        power = 80 if Settings::MECHANICS_GENERATION <= 5 && m.function == "TypeDependsOnUserIVs"
        next if power < highestPower
        forewarnMoves = [] if power > highestPower
        forewarnMoves.push(m.name)
        highestPower = power
      end
    end
    if forewarnMoves.length > 0
      battle.pbShowAbilitySplash(battler)
      forewarnMoveName = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      if Battle::Scene::USE_ABILITY_SPLASH
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

Battle::AbilityEffects::OnSwitchIn.add(:FRISK,
  proc { |ability, battler, battle, switch_in|
    next if !battler.pbOwnedByPlayer?
    foes = battle.allOtherSideBattlers(battler.index).select { |b| b.item }
    if foes.length > 0
      battle.pbShowAbilitySplash(battler)
      if Settings::MECHANICS_GENERATION >= 6
        foes.each do |b|
          battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",
             battler.pbThis, b.pbThis(true), b.itemName))
        end
      else
        foe = foes[battle.pbRandom(foes.length)]
        battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",
           battler.pbThis, foe.itemName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:GRASSYSURGE,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :Grassy
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Grassy)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ICEFACE,
  proc { |ability, battler, battle, switch_in|
    next if !battler.isSpecies?(:EISCUE) || battler.form != 1
    next if battler.effectiveWeather != :Hail
    battle.pbShowAbilitySplash(battler)
    if !Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} activated!", battler.pbThis, battler.abilityName))
    end
    battler.pbChangeForm(0, _INTL("{1} transformed!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:IMPOSTER,
  proc { |ability, battler, battle, switch_in|
    next if !switch_in || battler.effects[PBEffects::Transform]
    choice = battler.pbDirectOpposing
    next if choice.fainted?
    next if choice.effects[PBEffects::Transform] ||
            choice.effects[PBEffects::Illusion] ||
            choice.effects[PBEffects::Substitute] > 0 ||
            choice.effects[PBEffects::SkyDrop] >= 0 ||
            choice.semiInvulnerable?
    battle.pbShowAbilitySplash(battler, true)
    battle.pbHideAbilitySplash(battler)
    battle.pbAnimation(:TRANSFORM, battler, choice)
    battle.scene.pbChangePokemon(battler, choice.pokemon)
    battler.pbTransform(choice)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:INTIMIDATE,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.allOtherSideBattlers(battler.index).each do |b|
      next if !b.near?(battler)
      check_item = true
      if b.hasActiveAbility?(:CONTRARY)
        check_item = false if b.statStageAtMax?(:ATTACK)
      elsif b.statStageAtMin?(:ATTACK)
        check_item = false
      end
      check_ability = b.pbLowerAttackStatStageIntimidate(battler)
      b.pbAbilitiesOnIntimidated if check_ability
      b.pbItemOnIntimidatedCheck if check_item
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:INTREPIDSWORD,
  proc { |ability, battler, battle, switch_in|
    battler.pbRaiseStatStageByAbility(:ATTACK, 1, battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:MIMICRY,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :None
    Battle::AbilityEffects.triggerOnTerrainChange(ability, battler, battle, false)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:MISTYSURGE,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :Misty
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Misty)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:MOLDBREAKER,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} breaks the mold!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:NEUTRALIZINGGAS,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler, true)
    battle.pbHideAbilitySplash(battler)
    battle.pbDisplay(_INTL("Neutralizing gas filled the area!"))
    battle.allBattlers.each do |b|
      # Slow Start - end all turn counts
      b.effects[PBEffects::SlowStart] = 0
      # Truant - let b move on its first turn after Neutralizing Gas disappears
      b.effects[PBEffects::Truant] = false
      # Gorilla Tactics - end choice lock
      if !b.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF])
        b.effects[PBEffects::ChoiceBand] = nil
      end
      # Illusion - end illusions
      if b.effects[PBEffects::Illusion]
        b.effects[PBEffects::Illusion] = nil
        if !b.effects[PBEffects::Transform]
          battle.scene.pbChangePokemon(b, b.pokemon)
          battle.pbDisplay(_INTL("{1}'s {2} wore off!", b.pbThis, b.abilityName))
          battle.pbSetSeen(b)
        end
      end
    end
    # Trigger items upon Unnerve being negated
    battler.ability_id = nil   # Allows checking if Unnerve was active before
    had_unnerve = battle.pbCheckGlobalAbility(:UNNERVE)
    battler.ability_id = :NEUTRALIZINGGAS
    if had_unnerve && !battle.pbCheckGlobalAbility(:UNNERVE)
      battle.allBattlers.each { |b| b.pbItemsOnUnnerveEnding }
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:PASTELVEIL,
  proc { |ability, battler, battle, switch_in|
    next if battler.allAllies.none? { |b| b.status == :POISON }
    battle.pbShowAbilitySplash(battler)
    battler.allAllies.each do |b|
      next if b.status != :POISON
      b.pbCureStatus(Battle::Scene::USE_ABILITY_SPLASH)
      if !Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cured {3}'s poisoning!",
           battler.pbThis, battler.abilityName, b.pbThis(true)))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:PRESSURE,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is exerting its pressure!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:PRIMORDIALSEA,
  proc { |ability, battler, battle, switch_in|
    battle.pbStartWeatherAbility(:HeavyRain, battler, true)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:PSYCHICSURGE,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :Psychic
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Psychic)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:SANDSTREAM,
  proc { |ability, battler, battle, switch_in|
    battle.pbStartWeatherAbility(:Sandstorm, battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:SCREENCLEANER,
  proc { |ability, battler, battle, switch_in|
    next if battler.pbOwnSide.effects[PBEffects::AuroraVeil] == 0 &&
            battler.pbOwnSide.effects[PBEffects::LightScreen] == 0 &&
            battler.pbOwnSide.effects[PBEffects::Reflect] == 0 &&
            battler.pbOpposingSide.effects[PBEffects::AuroraVeil] == 0 &&
            battler.pbOpposingSide.effects[PBEffects::LightScreen] == 0 &&
            battler.pbOpposingSide.effects[PBEffects::Reflect] == 0
    battle.pbShowAbilitySplash(battler)
    if battler.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
      battler.pbOpposingSide.effects[PBEffects::AuroraVeil] = 0
      battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!", battler.pbOpposingTeam))
    end
    if battler.pbOpposingSide.effects[PBEffects::LightScreen] > 0
      battler.pbOpposingSide.effects[PBEffects::LightScreen] = 0
      battle.pbDisplay(_INTL("{1}'s Light Screen wore off!", battler.pbOpposingTeam))
    end
    if battler.pbOpposingSide.effects[PBEffects::Reflect] > 0
      battler.pbOpposingSide.effects[PBEffects::Reflect] = 0
      battle.pbDisplay(_INTL("{1}'s Reflect wore off!", battler.pbOpposingTeam))
    end
    if battler.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
      battler.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!", battler.pbTeam))
    end
    if battler.pbOwnSide.effects[PBEffects::LightScreen] > 0
      battler.pbOwnSide.effects[PBEffects::LightScreen] = 0
      battle.pbDisplay(_INTL("{1}'s Light Screen wore off!", battler.pbTeam))
    end
    if battler.pbOwnSide.effects[PBEffects::Reflect] > 0
      battler.pbOwnSide.effects[PBEffects::Reflect] = 0
      battle.pbDisplay(_INTL("{1}'s Reflect wore off!", battler.pbTeam))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:SLOWSTART,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battler.effects[PBEffects::SlowStart] = 5
    if Battle::Scene::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} can't get it going!", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} can't get it going because of its {2}!",
         battler.pbThis, battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:SNOWWARNING,
  proc { |ability, battler, battle, switch_in|
    battle.pbStartWeatherAbility(:Hail, battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:TERAVOLT,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a bursting aura!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:TURBOBLAZE,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a blazing aura!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:UNNERVE,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!", battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:TEMPERMENTAL,
  proc { |ability, battler, battle, switch_in|
    next if !battler.pbCanConfuseSelf?(false)
    battle.pbShowAbilitySplash(battler)
    battler.pbConfuseSelf
    battler.pbRaiseStatStageByAbility(:ATTACK,2,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:MIRRORTYPE,
  proc { |ability, battler, battle, switch_in|
    targets = []
    battle.allOtherSideBattlers(battler.index).each {|b| targets.push(b)}
    if targets.length > 0
      target = targets[rand(targets.length)]
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} copied {2}'s types!",battler.pbThis,target.pbThis(true)))
      battler.pbChangeTypes(target)
      battle.pbHideAbilitySplash(battler)
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:MYSTERYTYPE,
  proc { |ability, battler, battle, switch_in|
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

Battle::AbilityEffects::OnSwitchIn.add(:RETEXTURING,
  proc { |ability, battler, battle, switch_in|
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

Battle::AbilityEffects::OnSwitchIn.add(:ROOTED,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battler.pbUseMoveExtra(:INGRAIN,battler.index,-1,true)
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:FERTILEGIFTS,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is ready to share its fertile gifts!", battler.pbThis))
    battle.allSameSideBattlers(battler).each do |b|
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

Battle::AbilityEffects::OnSwitchIn.add(:CRYSTALSURGE,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} covered the battlefield with Crystal Energy!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:HYPERAROMA,
  proc { |ability, battler, battle, switch_in|
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

Battle::AbilityEffects::OnSwitchIn.add(:MINDIPULATION,
  proc { |ability, battler, battle, switch_in|
    battle.allBattlers.each do |b|
      next if b.index == battler.index
      next if !b.pbCanConfuse?(battler, false)
      next if battle.pbRandom(100) < 50
      battle.pbShowAbilitySplash(battler)
      b.pbConfuse
      battle.pbHideAbilitySplash(battler)
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:LASTBASTION,
  proc { |ability, battler, battle, switch_in|
    next if battler.wild?
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

Battle::AbilityEffects::OnSwitchIn.add(:ALIGNED,
  proc { |ability, battler, battle, switch_in|
    # Calculate number of stat stages to increase
    numStatIncrease = 0
    battlersAndParty = battle.pbGetBattlersAndParty(battler.index)
    for b in battlersAndParty[0]
      next if b.fainted?
      numStatIncrease += 1 if battler.pbTypes(true).intersection(b.pbTypes(true)).length > 0
    end
    for p in battlersAndParty[1]
      next if !p || p.egg? || p.fainted?
      numStatIncrease += 1 if battler.pbTypes(true).intersection(p.types).length > 0
    end
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

Battle::AbilityEffects::OnSwitchIn.add(:BULLY,
  proc { |ability, battler, battle, switch_in|
    battle.allOtherSideBattlers(battler.index).each do |b|
      next if b.pokemon.height > battler.pokemon.height
      next if b.pokemon.height == battler.pokemon.height && battler.pbWeight <= b.pbWeight
      next if !b.pbCanLowerStatStage?(:ATTACK, battler)
      b.pbLowerStatStageByAbility(:ATTACK, 1, battler)
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:SUDDENSEED,
  proc { |ability, battler, battle, switch_in|
    battle.allOtherSideBattlers(battler.index).each do |b|
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

Battle::AbilityEffects::OnSwitchIn.add(:ROCKYTRAP,
  proc { |ability, battler, battle, switch_in|
    next if battler.pbOpposingSide.effects[PBEffects::StealthRock]
    battle.pbShowAbilitySplash(battler)
    battler.pbOpposingSide.effects[PBEffects::StealthRock] = true
    battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
       battler.pbOpposingTeam(true)))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ROUNDRECORD,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battler.pbConfuseSelf
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:OUTMATCH,
  proc { |ability, battler, battle, switch_in|
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

Battle::AbilityEffects::OnSwitchIn.add(:TEMPEST,
  proc { |ability, battler, battle, switch_in|
    pbBattleWeatherAbility(:Thunderstorm, battler, battle)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:CYCLONE,
  proc { |ability, battler, battle, switch_in|
    pbBattleWeatherAbility(:Windstorm, battler, battle)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:DEBRISARMOR,
  proc { |ability, battler, battle, switch_in|
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

Battle::AbilityEffects::OnSwitchIn.add(:CLEARINGFUMES,
  proc { |ability, battler, battle, switch_in|
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
    battle.allBattlers.each do |b|
      b.pbResetStatStages
    end
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} cleared all hazards and stat changes on the field!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:CHILLING,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.allOtherSideBattlers(battler.index).each do |b|
      next if !b.near?(battler)
      b.pbLowerSpecialAttackStatStageChilling(battler)
      b.pbItemOnIntimidatedCheck # Copied from Intimidate
    end
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:IMMOVABLE,
  proc { |ability, battler, battle, switch_in|
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

Battle::AbilityEffects::OnSwitchIn.add(:LAVAFLOOR,
  proc { |ability, battler, battle, switch_in|
    next if battle.field.terrain == :Lava
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Lava)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:HIVEMIND,
  proc { |ability, battler, battle, switch_in|
    bugCount = 0
    type_lists = battle.pbGetTypeListsOfBattlersAndParty(battler.index)
    for tl in type_lists
      bugCount += 1 if tl.include?(:BUG)
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

Battle::AbilityEffects::OnSwitchIn.add(:OMNIGENE,
  proc { |ability, battler, battle, switch_in|
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
      :PIXIEPLATE  => :FAIRY,
      :ODDPLATE    => :MYSTIC,
      :LOUDPLATE   => :SOUND,
      :LUMENPLATE  => :LIGHT,
      :COSMOSPLATE => :COSMIC,
      :SHINYPLATE  => :CRYSTAL
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

Battle::AbilityEffects::OnSwitchIn.add(:CLAIRVOYANT,
  proc { |ability, battler, battle, switch_in|
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

Battle::AbilityEffects::OnSwitchIn.add(:CLOAKCONTROL,
  proc { |ability, battler, battle, switch_in|
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

Battle::AbilityEffects::OnSwitchIn.add(:MAGICSHOW,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} created a bizarre area in which Pokémon's held items lose their effects!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:HEAVYEYED,
  proc { |ability, battler, battle, switch_in|
    next if !battler.isSpecies?(:RABLIN) || battler.form == 0
    next if !battler.pbCanSleep?(battler, false)
    battler.pbSleepSelf
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:NEGATION,
  proc { |ability, battler, battle, switch_in|
    next if battle.pbCheckGlobalAbility(:CRYSTALENERGY)
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is suppressing all power transformations!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ADDITION,
  proc { |ability, battler, battle, switch_in|
    next if battle.initialSwitchIn && battle.subtractionMessageDisplayed[battler.index % 2]
    # Display message if side has both Addition and Subtraction users
    subtractionUser = battle.pbCheckAllyAbility(:SUBTRACTION, battler.index)
    if subtractionUser
      battle.pbShowAbilitySplash(subtractionUser)
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} and {2} unite to remove all type weaknesses from its side!", subtractionUser.pbThis, battler.pbThis(true)))
      battle.pbHideAbilitySplash(battler)
      battle.pbHideAbilitySplash(subtractionUser)
      battle.subtractionMessageDisplayed[battler.index % 2] = true
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:SUBTRACTION,
  proc { |ability, battler, battle, switch_in|
    next if battle.initialSwitchIn && battle.subtractionMessageDisplayed[battler.index % 2]
    # Display message if side has both Addition and Subtraction users
    additionUser = battle.pbCheckAllyAbility(:ADDITION, battler.index)
    if additionUser
      battle.pbShowAbilitySplash(additionUser)
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} and {2} unite to remove all type weaknesses from its side!", additionUser.pbThis, battler.pbThis(true)))
      battle.pbHideAbilitySplash(battler)
      battle.pbHideAbilitySplash(additionUser)
      battle.subtractionMessageDisplayed[battler.index % 2] = true
      next
    end
    # Display message for each Pokemon losing a weakness
    subtractionCount = 0
    battle.allSameSideBattlers(battler.index).each do |b|
      subtractionCount += 1 if b.hasActiveAbility?(:SUBTRACTION)
    end
    battle.pbShowAbilitySplash(battler)
    battle.allSameSideBattlers(battler.index).each do |b|
      if subtractionCount <= b.effects[PBEffects::SubtractionTypes].length
        typeListString = b.effects[PBEffects::SubtractionTypes][0...subtractionCount].join(", ")
        battle.pbDisplay(_INTL("{1} lost its weakness(es) to the following type(s): {2}", b.pbThis, typeListString))
      end
    end
    battle.pbHideAbilitySplash(battler)
    battle.subtractionMessageDisplayed[battler.index % 2] = true
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:SKILLSCAN,
  proc { |ability, battler, battle, switch_in|
    types = battler.pbTypes(true)
    showSprite = false
    battler.eachOpposing do |b|
      b.eachMove do |m|
        next if !m.pbDamagingMove?
        next if !Effectiveness.super_effective_type?(m.type, types[0], types[1], types[2])
        showSprite = true
        break
      end
    end
    if showSprite
      # TODO: show skill scan sprite
      battle.pbDisplay(_INTL("!!!!!!!!!!!!!!"))
    end
  }
)

#===============================================================================
# OnSwitchOut handlers
#===============================================================================

Battle::AbilityEffects::OnSwitchOut.add(:IMMUNITY,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :POISON
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

Battle::AbilityEffects::OnSwitchOut.add(:INSOMNIA,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :SLEEP
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

Battle::AbilityEffects::OnSwitchOut.copy(:INSOMNIA, :VITALSPIRIT)

Battle::AbilityEffects::OnSwitchOut.add(:LIMBER,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :PARALYSIS
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

Battle::AbilityEffects::OnSwitchOut.add(:MAGMAARMOR,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :FROZEN
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

Battle::AbilityEffects::OnSwitchOut.add(:NATURALCURE,
  proc { |ability, battler, endOfBattle|
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

Battle::AbilityEffects::OnSwitchOut.add(:REGENERATOR,
  proc { |ability, battler, endOfBattle|
    next if endOfBattle
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.pbRecoverHP(battler.totalhp / 3, false, false)
  }
)

Battle::AbilityEffects::OnSwitchOut.add(:WATERVEIL,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :BURN
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

Battle::AbilityEffects::OnSwitchOut.copy(:WATERVEIL, :WATERBUBBLE)

Battle::AbilityEffects::OnSwitchOut.add(:DEBRISARMOR,
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
# ChangeOnBattlerFainting handlers
#===============================================================================

Battle::AbilityEffects::ChangeOnBattlerFainting.add(:POWEROFALCHEMY,
  proc { |ability, battler, fainted, battle|
    next if battler.opposes?(fainted)
    next if fainted.ungainableAbility? ||
       [:POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD, :INCOMPREHENSIBLE].include?(fainted.ability_id)
    battle.pbShowAbilitySplash(battler, true)
    battler.ability = fainted.ability
    battle.pbReplaceAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s {2} was taken over!", fainted.pbThis, fainted.abilityName))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::ChangeOnBattlerFainting.copy(:POWEROFALCHEMY, :RECEIVER)

#===============================================================================
# OnBattlerFainting handlers
#===============================================================================

Battle::AbilityEffects::OnBattlerFainting.add(:SOULHEART,
  proc { |ability, battler, fainted, battle|
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 1, battler)
  }
)

Battle::AbilityEffects::OnBattlerFainting.add(:LASTBASTION,
  proc { |ability,battler,fainted,battle|
    next if battler.opposes?(fainted)
    next if battler.wild?
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

Battle::AbilityEffects::OnBattlerFainting.add(:EFFULGE,
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
# OnTerrainChange handlers
#===============================================================================

Battle::AbilityEffects::OnTerrainChange.add(:MIMICRY,
  proc { |ability, battler, battle, ability_changed|
    if battle.field.terrain == :None
      # Revert to original typing
      battle.pbShowAbilitySplash(battler)
      battler.pbResetTypes
      battle.pbDisplay(_INTL("{1} changed back to its regular type!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    else
      # Change to new typing
      terrain_hash = {
        :Electric => :ELECTRIC,
        :Grassy   => :GRASS,
        :Misty    => :FAIRY,
        :Psychic  => :PSYCHIC
      }
      new_type = terrain_hash[battle.field.terrain]
      new_type_name = nil
      if new_type
        type_data = GameData::Type.try_get(new_type)
        new_type = nil if !type_data
        new_type_name = type_data.name if type_data
      end
      if new_type
        battle.pbShowAbilitySplash(battler)
        battler.pbChangeTypes(new_type)
        battle.pbDisplay(_INTL("{1}'s type changed to {2}!", battler.pbThis, new_type_name))
        battle.pbHideAbilitySplash(battler)
      end
    end
  }
)

#===============================================================================
# OnIntimidated handlers
#===============================================================================

Battle::AbilityEffects::OnIntimidated.add(:RATTLED,
  proc { |ability, battler, battle|
    next if Settings::MECHANICS_GENERATION < 8
    battler.pbRaiseStatStageByAbility(:SPEED, 1, battler)
  }
)

#===============================================================================
# CertainEscapeFromBattle handlers
#===============================================================================

Battle::AbilityEffects::CertainEscapeFromBattle.add(:RUNAWAY,
  proc { |ability, battler|
    next true
  }
)
