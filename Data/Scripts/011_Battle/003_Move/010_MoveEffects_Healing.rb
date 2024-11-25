#===============================================================================
# Heals user to full HP. User falls asleep for 2 more rounds. (Rest)
#===============================================================================
class Battle::Move::HealUserFullyAndFallAsleep < Battle::Move::HealingMove
  def pbMoveFailed?(user, targets)
    if user.asleep?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if !user.pbCanSleep?(user, true, self, true)
    return true if super
    return false
  end

  def pbHealAmount(user)
    return user.totalhp - user.hp
  end

  def pbEffectGeneral(user)
    user.pbSleepSelf(_INTL("{1} slept and became healthy!", user.pbThis), 3)
    super
  end
end

#===============================================================================
# If this move KO's the target, fully recovers the user's HP. (Grab Life)
#===============================================================================
class Battle::Move::HealUserFullyIfTargetFaints < Battle::Move
  def healingMove?;       return true; end

  def pbEffectAfterAllHits(user, target)
    return if !target.damageState.fainted
    return if !user.canHeal?
    if user.pbRecoverHP(user.totalhp - user.hp) > 0
      @battle.pbDisplay(_INTL("{1} absorbed energy from its foe!", user.pbThis))
    end
  end
end

#===============================================================================
# Heals user by 1/2 of its max HP.
#===============================================================================
class Battle::Move::HealUserHalfOfTotalHP < Battle::Move::HealingMove
  def pbHealAmount(user)
    return (user.totalhp / 2.0).round
  end
end

#===============================================================================
# Heals user by an amount depending on the weather. (Moonlight, Morning Sun,
# Synthesis)
#===============================================================================
class Battle::Move::HealUserDependingOnWeather < Battle::Move::HealingMove
  def pbOnStartUse(user, targets)
    case user.effectiveWeather
    when :Sun, :HarshSun
      @healAmount = (user.totalhp * 2 / 3.0).round
    when :None, :StrongWinds
      @healAmount = (user.totalhp / 2.0).round
    else
      @healAmount = (user.totalhp / 4.0).round
    end
  end

  def pbHealAmount(user)
    return @healAmount
  end
end

#===============================================================================
# Heals user by 1/2 of its max HP, or 2/3 of its max HP in a sandstorm. (Shore Up)
#===============================================================================
class Battle::Move::HealUserDependingOnSandstorm < Battle::Move::HealingMove
  def pbHealAmount(user)
    return (user.totalhp * 2 / 3.0).round if user.effectiveWeather == :Sandstorm
    return (user.totalhp / 2.0).round
  end
end

#===============================================================================
# Heals user by 1/2 of its max HP. (Roost)
# User roosts, and its Flying type is ignored for attacks used against it.
#===============================================================================
class Battle::Move::HealUserHalfOfTotalHPLoseFlyingTypeThisTurn < Battle::Move::HealingMove
  def pbHealAmount(user)
    return (user.totalhp / 2.0).round
  end

  def pbEffectGeneral(user)
    super
    user.effects[PBEffects::Roost] = true
  end
end

#===============================================================================
# Cures the target's permanent status problems. Heals user by 1/2 of its max HP.
# (Purify)
#===============================================================================
class Battle::Move::CureTargetStatusHealUserHalfOfTotalHP < Battle::Move::HealingMove
  def canSnatch?;    return false; end   # Because it affects a target
  def canMagicCoat?; return true;  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.status == :NONE
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbHealAmount(user)
    return (user.totalhp / 2.0).round
  end

  def pbEffectAgainstTarget(user, target)
    target.pbCureStatus
    super
  end
end

#===============================================================================
# Cures the target's permanent status problems. Heals user by 1/2 of its max HP.
# Similar to above effect but for damaging moves. (Miracle Pulse)
#===============================================================================
class Battle::Move::CureTargetStatusHealUserHalfOfTotalHPDamagingMove < Battle::Move
  def pbEffectAgainstTarget(user, target)
    if target.status != :NONE
      target.pbCureStatus
      # Technically runs for every target, but Miracle Pulse only targets a
      # single battler.
      if user.pbRecoverHP((user.totalhp / 2.0).round) > 0
        @battle.pbDisplay(_INTL("{1}'s HP was restored.", user.pbThis))
      end
    end
  end
end

#===============================================================================
# Decreases the target's Attack by 1 stage. Heals user by an amount equal to the
# target's Attack stat (after applying stat stages, before this move decreases
# it). (Strength Sap)
#===============================================================================
class Battle::Move::HealUserByTargetAttackLowerTargetAttack1 < Battle::Move
  def healingMove?;  return true; end
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    # NOTE: The official games appear to just check whether the target's Attack
    #       stat stage is -6 and fail if so, but I've added the "fail if target
    #       has Contrary and is at +6" check too for symmetry. This move still
    #       works even if the stat stage cannot be changed due to an ability or
    #       other effect.
    if !@battle.moldBreaker && target.hasActiveAbility?(:CONTRARY) &&
       target.statStageAtMax?(:ATTACK)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    elsif target.statStageAtMin?(:ATTACK)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    # Calculate target's effective attack value
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8, 9]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2, 2]
    atk      = target.attack
    atkStage = target.modifiedStages[:ATTACK] + 6
    healAmt = (atk.to_f * stageMul[atkStage] / stageDiv[atkStage]).floor
    # Reduce target's Attack stat
    if target.pbCanLowerStatStage?(:ATTACK, user, self)
      target.pbLowerStatStage(:ATTACK, 1, user)
    end
    # Heal user
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      user.pbReduceHP(healAmt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", user.pbThis))
      @battle.pbHideAbilitySplash(target)
      user.pbItemHPHealCheck
    elsif user.canHeal?
      healAmt = (healAmt * 1.3).floor if user.hasActiveItem?(:BIGROOT)
      if user.pbRecoverHP(healAmt) > 0
        @battle.pbDisplay(_INTL("{1}'s HP was restored.", user.pbThis))
      end
    end
  end
end

#===============================================================================
# User gains half the HP it inflicts as damage.
#===============================================================================
class Battle::Move::HealUserByHalfOfDamageDone < Battle::Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (target.damageState.hpLost / 2.0).round
    user.pbRecoverHPFromDrain(hpGain, target)
  end
end

#===============================================================================
# User gains half the HP it inflicts as damage. Fails if target is not asleep.
# (Dream Eater)
#===============================================================================
class Battle::Move::HealUserByHalfOfDamageDoneIfTargetAsleep < Battle::Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.asleep?
      @battle.pbDisplay(_INTL("{1} wasn't affected!", target.pbThis)) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (target.damageState.hpLost / 2.0).round
    user.pbRecoverHPFromDrain(hpGain, target)
  end
end

#===============================================================================
# User gains 3/4 the HP it inflicts as damage. (Draining Kiss, Oblivion Wing)
#===============================================================================
class Battle::Move::HealUserByThreeQuartersOfDamageDone < Battle::Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (target.damageState.hpLost * 0.75).round
    user.pbRecoverHPFromDrain(hpGain, target)
  end
end

#===============================================================================
# User gains half the HP it inflicts as damage. Also, base damage increases by
# 10 and healing amount by 10% for every raised stat the target has. (Qi Drain)
#===============================================================================
class Battle::Move::HealUserByHalfOfDamageDoneAndBoostPower10Healing10PercentPerStatBoostOnTarget < Battle::Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbBaseDamage(baseDmg, user, target)
    power_mult = 0
    GameData::Stat.each_battle { |s| power_mult += target.modifiedStages[s.id] if target.modifiedStages[s.id] > 0 }
    return baseDmg + (10 * power_mult)
  end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    drain_multiplier = 5
    GameData::Stat.each_battle { |s| drain_multiplier += target.modifiedStages[s.id] if target.modifiedStages[s.id] > 0 }
    hpGain = (target.damageState.hpLost * drain_multiplier.to_f / 10).round
    user.pbRecoverHPFromDrain(hpGain, target)
  end
end

#===============================================================================
# User gains half the HP it inflicts as damage. Also, doubles the damage of burn
# and poison effects on the target for 5 turns. (Deter Drain)
#===============================================================================
class Battle::Move::HealUserByHalfOfDamageDoneAndIncreaseDamageDoneByBurnPoisonFor5Turns < Battle::Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (target.damageState.hpLost / 2.0).round
    user.pbRecoverHPFromDrain(hpGain, target)
    target.effects[PBEffects::DeterDrainActive] = 5
    @battle.pbDisplay(_INTL("{1} became weaker to burns and poison!", target.pbThis))
  end
end

#===============================================================================
# The user and its allies gain 25% of their total HP. (Life Dew)
#===============================================================================
class Battle::Move::HealUserAndAlliesQuarterOfTotalHP < Battle::Move
  def healingMove?; return true; end

  def pbMoveFailed?(user, targets)
    if @battle.allSameSideBattlers(user).none? { |b| b.canHeal? }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return !target.canHeal?
  end

  def pbEffectAgainstTarget(user, target)
    if target.pbRecoverHP(target.totalhp / 4) > 0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
  end
end

#===============================================================================
# The user and its allies gain 25% of their total HP and are cured of their
# permanent status problems. (Jungle Healing)
#===============================================================================
class Battle::Move::HealUserAndAlliesQuarterOfTotalHPCureStatus < Battle::Move
  def healingMove?; return true; end

  def pbMoveFailed?(user, targets)
    if @battle.allSameSideBattlers(user).none? { |b| b.canHeal? || b.status != :NONE }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return target.status == :NONE && !target.canHeal?
  end

  def pbEffectAgainstTarget(user, target)
    if target.canHeal? && target.pbRecoverHP(target.totalhp / 4) > 0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
    if target.status != :NONE
      old_status = target.status
      target.pbCureStatus(false)
      case old_status
      when :SLEEP
        @battle.pbDisplay(_INTL("{1} was woken from sleep.", target.pbThis))
      when :POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.", target.pbThis))
      when :BURN
        @battle.pbDisplay(_INTL("{1}'s burn was healed.", target.pbThis))
      when :PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.", target.pbThis))
      when :FROZEN
        @battle.pbDisplay(_INTL("{1} was thawed out.", target.pbThis))
      end
    end
  end
end

#===============================================================================
# Heals user by 1/2 of its max HP and raises a random stat (except Evasion) by 1
# stage. However, this move fails if the user's HP is at more than 1/2 of its
# max HP. (Regrowth)
#===============================================================================
class Battle::Move::HealUserHalfOfTotalHPAndRaiseUserRandomStatExceptEvasivenessAndFailsIfUserHPAboveHalfOfTotalHP < Battle::Move::HealingMove
  def pbMoveFailed?(user, targets)
    if user.hp >= (user.totalhp / 2.0).round
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @statArray = []
    GameData::Stat.each_battle do |s|
      @statArray.push(s.id) if user.pbCanRaiseStatStage?(s.id, user, self) && s.id != :EVASION
    end
    if @statArray.length == 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return super
  end

  def pbHealAmount(user)
    return (user.totalhp / 2.0).round
  end

  def pbEffectGeneral(user)
    super
    user.pbRaiseStatStage(@statArray[@battle.pbRandom(@statArray.length)], 1, user)
  end
end

#===============================================================================
# Heals user by 1/2 of its max HP if any of the targets have fainted.
# (Phoenix Flame)
#===============================================================================
class Battle::Move::HealUserHalfOfTotalHPIfKOsTarget < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.fainted? || target.damageState.unaffected
    return if !target.damageState.fainted
    if user.canHeal? && user.pbRecoverHP((user.totalhp / 2.0).round) > 0
      @battle.pbDisplay(_INTL("{1}'s rises stronger from the ashes!", user.pbThis))
    end
  end
end

#===============================================================================
# Heals target by 1/2 of its max HP. (Heal Pulse)
#===============================================================================
class Battle::Move::HealTargetHalfOfTotalHP < Battle::Move
  def healingMove?;  return true; end
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.hp == target.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
      return true
    elsif !target.canHeal?
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    hpGain = (target.totalhp / 2.0).round
    if pulseMove? && user.hasActiveAbility?(:MEGALAUNCHER)
      hpGain = (target.totalhp * 3 / 4.0).round
    end
    if target.pbRecoverHP(hpGain) > 0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
  end
end

#===============================================================================
# Heals target by 1/2 of its max HP (3/4 in a single battle), but skips next
# turn. (Soothing Gleam)
#===============================================================================
class Battle::Move::HealTargetHalfOfTotalHP75PercentIfSingleBattleAndSkipNextTurn < Battle::Move::HealTargetHalfOfTotalHP
  def pbEffectGeneral(user)
    user.effects[PBEffects::HyperBeam] = 2
    user.currentMove = @id
  end

  def pbEffectAgainstTarget(user, target)
    hpGain = (target.totalhp / 2.0).round
    if @battle.pbSideSize(user.index) == 1
      hpGain = (target.totalhp * 3 / 4.0).round
    end
    if target.pbRecoverHP(hpGain) > 0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
  end
end

#===============================================================================
# Heals target by 1/2 of its max HP, or 2/3 of its max HP in Grassy Terrain.
# (Floral Healing)
#===============================================================================
class Battle::Move::HealTargetDependingOnGrassyTerrain < Battle::Move
  def healingMove?;  return true; end
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.hp == target.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
      return true
    elsif !target.canHeal?
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    hpGain = (target.totalhp / 2.0).round
    hpGain = (target.totalhp * 2 / 3.0).round if @battle.field.terrain == :Grassy
    if target.pbRecoverHP(hpGain) > 0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
  end
end

#===============================================================================
# Battler in user's position is healed by 1/2 of its max HP, at the end of the
# next round. (Wish)
#===============================================================================
class Battle::Move::HealUserPositionNextTurn < Battle::Move
  def healingMove?; return true; end
  def canSnatch?;   return true; end

  def pbMoveFailed?(user, targets)
    if @battle.positions[user.index].effects[PBEffects::Wish] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.positions[user.index].effects[PBEffects::Wish]       = 2
    @battle.positions[user.index].effects[PBEffects::WishAmount] = (user.totalhp / 2.0).round
    @battle.positions[user.index].effects[PBEffects::WishMaker]  = user.pokemonIndex
  end
end

#===============================================================================
# Heals user by 10% of its total HP and raises its Speed by 1 stage, but also
# lowers its Defense and Sp. Def. by 1 stage each. (Crystal Polish)
#===============================================================================
class Battle::Move::HealUserBy10PercentOfTotalHPAndRaiseUserSpeed1AndLowerUserDefSpDef1 < Battle::Move
  def healingMove?;       return true; end
  def canSnatch?;         return true; end

  def pbMoveFailed?(user, targets)
    return false if user.hp < user.totalhp ||
                    user.pbCanRaiseStatStage?(:SPEED, user, self) ||
                    user.pbCanLowerStatStage?(:DEFENSE, user, self) ||
                    user.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user, self)
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def pbHealAmount(user)
    return (user.totalhp / 10.0).round
  end

  def pbEffectGeneral(user)
    if user.hp < user.totalhp
      amt = pbHealAmount(user)
      if user.pbRecoverHP(amt) > 0
        @battle.pbDisplay(_INTL("{1}'s HP was restored.", user.pbThis))
      end
    end
    if user.pbCanRaiseStatStage?(:SPEED, user, self)
      user.pbRaiseStatStage(:SPEED, 1, user)
    end
    if user.pbCanLowerStatStage?(:DEFENSE, user, self)
      user.pbLowerStatStage(:DEFENSE, 1, user)
    end
    if user.pbCanLowerStatStage?(:SPECIAL_DEFENSE, user, self)
      user.pbLowerStatStage(:SPECIAL_DEFENSE, 1, user)
    end
    super
  end
end

#===============================================================================
# Rings the user. Ringed Pokémon gain 1/16 of max HP at the end of each round.
# (Aqua Ring)
#===============================================================================
class Battle::Move::StartHealUserEachTurn < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::AquaRing]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::AquaRing] = true
    @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!", user.pbThis))
  end
end

#===============================================================================
# Ingrains the user. Ingrained Pokémon gain 1/16 of max HP at the end of each
# round, and cannot flee or switch out. (Ingrain)
#===============================================================================
class Battle::Move::StartHealUserEachTurnTrapUserInBattle < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Ingrain] = true
    @battle.pbDisplay(_INTL("{1} planted its roots!", user.pbThis))
  end
end

#===============================================================================
# Target will lose 1/4 of max HP at end of each round, while asleep. (Nightmare)
#===============================================================================
class Battle::Move::StartDamageTargetEachTurnIfTargetAsleep < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.asleep? || target.effects[PBEffects::Nightmare]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Nightmare] = true
    @battle.pbDisplay(_INTL("{1} began having a nightmare!", target.pbThis))
  end
end

#===============================================================================
# Seeds the target. Seeded Pokémon lose 1/8 of max HP at the end of each round,
# and the Pokémon in the user's position gains the same amount. (Leech Seed)
#===============================================================================
class Battle::Move::StartLeechSeedTarget < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::LeechSeed] >= 0
      @battle.pbDisplay(_INTL("{1} evaded the attack!", target.pbThis)) if show_message
      return true
    end
    if target.pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true))) if show_message
      return true
    end
    return false
  end

  def pbMissMessage(user, target)
    @battle.pbDisplay(_INTL("{1} evaded the attack!", target.pbThis))
    return true
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::LeechSeed] = user.index
    @battle.pbDisplay(_INTL("{1} was seeded!", target.pbThis))
  end
end

#===============================================================================
# The user takes damage equal to 1/2 of its total HP, even if the target is
# unaffected (this is not recoil damage). (Steel Beam)
#===============================================================================
class Battle::Move::UserLosesHalfOfTotalHP < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if !user.takesIndirectDamage?
    amt = (user.totalhp / 2.0).ceil
    amt = 1 if amt < 1
    user.pbReduceHP(amt, false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Damages user by 1/2 of its max HP, even if this move misses. (Mind Blown)
#===============================================================================
class Battle::Move::UserLosesHalfOfTotalHPExplosive < Battle::Move
  def worksWithNoTargets?; return true; end

  def pbMoveFailed?(user, targets)
    if !@battle.moldBreaker
      bearer = @battle.pbCheckGlobalAbility(:DAMP)
      if bearer
        @battle.pbShowAbilitySplash(bearer)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} cannot use {2}!", user.pbThis, @name))
        else
          @battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
                                  user.pbThis, @name, bearer.pbThis(true), bearer.abilityName))
        end
        @battle.pbHideAbilitySplash(bearer)
        return true
      end
    end
    return false
  end

  def pbSelfKO(user)
    return if !user.takesIndirectDamage?
    user.pbReduceHP((user.totalhp / 2.0).round, false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# User faints, even if the move does nothing else. (Explosion, Self-Destruct)
#===============================================================================
class Battle::Move::UserFaintsExplosive < Battle::Move
  def worksWithNoTargets?;     return true; end
  def pbNumHits(user, targets); return 1;    end

  def pbMoveFailed?(user, targets)
    if !@battle.moldBreaker
      bearer = @battle.pbCheckGlobalAbility(:DAMP)
      if bearer
        @battle.pbShowAbilitySplash(bearer)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} cannot use {2}!", user.pbThis, @name))
        else
          @battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
                                  user.pbThis, @name, bearer.pbThis(true), bearer.abilityName))
        end
        @battle.pbHideAbilitySplash(bearer)
        return true
      end
    end
    return false
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp, false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# User faints. (Disconnect)
#===============================================================================
class Battle::Move::UserFaints < Battle::Move
  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp, false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# User faints and removes all screens, entry hazards, and terrains.
# (Field Collapse)
#===============================================================================
class Battle::Move::UserFaintsRemoveEntryHazardsAndScreensAndTerrains < Battle::Move
  def pbAddTarget(targets, user)
    # No need to target itself, there is separate code to faint the user below.
    targets.reject! {|t| t.index == user.index}
  end

  def pbEffectGeneral(user)
    # Remove screens
    @battle.sides.each do |i|
      i.effects[PBEffects::AuroraVeil]  = 0
      i.effects[PBEffects::Reflect]     = 0
      i.effects[PBEffects::LightScreen] = 0
      i.effects[PBEffects::Safeguard]   = 0
    end
    @battle.pbDisplay(_INTL("It broke all barriers!"))
    # Remove entry hazards
    if user.pbOwnSide.effects[PBEffects::StealthRock] || user.pbOpposingSide.effects[PBEffects::StealthRock]
      user.pbOwnSide.effects[PBEffects::StealthRock]      = false
      user.pbOpposingSide.effects[PBEffects::StealthRock] = false
      @battle.pbDisplay(_INTL("{1} cleared stealth rocks!", user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::Spikes] > 0 || user.pbOpposingSide.effects[PBEffects::Spikes] > 0
      user.pbOwnSide.effects[PBEffects::Spikes]      = 0
      user.pbOpposingSide.effects[PBEffects::Spikes] = 0
      @battle.pbDisplay(_INTL("{1} cleared spikes!", user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 || user.pbOpposingSide.effects[PBEffects::ToxicSpikes] > 0
      user.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
      user.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
      @battle.pbDisplay(_INTL("{1} cleared poison spikes!", user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::VoltSpikes] > 0 || user.pbOpposingSide.effects[PBEffects::VoltSpikes] > 0
      user.pbOwnSide.effects[PBEffects::VoltSpikes]      = 0
      user.pbOpposingSide.effects[PBEffects::VoltSpikes] = 0
      @battle.pbDisplay(_INTL("{1} cleared volt spikes!", user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::StickyWeb] || user.pbOpposingSide.effects[PBEffects::StickyWeb]
      user.pbOwnSide.effects[PBEffects::StickyWeb]      = false
      user.pbOpposingSide.effects[PBEffects::StickyWeb] = false
      @battle.pbDisplay(_INTL("{1} cleared sticky webs!", user.pbThis))
    end
    if user.pbOwnSide.effects[PBEffects::AsteroidBelt] > 0 || user.pbOpposingSide.effects[PBEffects::AsteroidBelt] > 0
      user.pbOwnSide.effects[PBEffects::AsteroidBelt]      = 0
      user.pbOpposingSide.effects[PBEffects::AsteroidBelt] = 0
      @battle.pbDisplay(_INTL("{1} cleared asteroids!", user.pbThis))
    end
    # Remove terrain
    case @battle.field.terrain
    when :Electric
      @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
    when :Grassy
      @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
    when :Misty
      @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
    when :Psychic
      @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
    when :Lava
      @battle.pbDisplay(_INTL("The lava disappeared from the battlefield."))
    when :Crystal
      @battle.pbDisplay(_INTL("The crystals disappeared from the battlefield."))
    when :Icy
      @battle.pbDisplay(_INTL("The ice on the ground melted."))
    end
    @battle.field.terrain = :None
    # Faint user
    if !user.fainted?
      user.pbReduceHP(user.hp, false)
      user.pbItemHPHealCheck
    end
  end
end

#===============================================================================
# User faints. If Misty Terrain applies, base power is multiplied by 1.5.
# (Misty Explosion)
#===============================================================================
class Battle::Move::UserFaintsPowersUpInMistyTerrainExplosive < Battle::Move::UserFaintsExplosive
  def pbBaseDamage(baseDmg, user, target)
    baseDmg = baseDmg * 3 / 2 if @battle.field.terrain == :Misty
    return baseDmg
  end
end

#===============================================================================
# User faints, even if the move does nothing else. This move's type is the same
# as the user's first type. (Kamikaze ability's attack move)
#===============================================================================
class Battle::Move::UserFaintsExplosiveTypeIsUserFirstType < Battle::Move::UserFaintsExplosive
  def pbBaseType(user)
    userTypes = user.pbTypes(true)
    return userTypes[0] || @type
  end
end

#===============================================================================
# Inflicts fixed damage equal to user's current HP. (Final Gambit)
# User faints (if successful).
#===============================================================================
class Battle::Move::UserFaintsFixedDamageUserHP < Battle::Move::FixedDamageMove
  def pbNumHits(user, targets); return 1; end

  def pbOnStartUse(user, targets)
    @finalGambitDamage = user.hp
  end

  def pbFixedDamage(user, target)
    return @finalGambitDamage
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp, false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 2 stages each. (Memento)
# User faints (if successful).
#===============================================================================
class Battle::Move::UserFaintsLowerTargetAtkSpAtk2 < Battle::Move::TargetMultiStatDownMove
  def canMagicCoat?; return false; end

  def initialize(battle, move)
    super
    @statDown = [:ATTACK, 2, :SPECIAL_ATTACK, 2]
  end

  # NOTE: The user faints even if the target's stats cannot be changed, so this
  #       method must always return false to allow the move's usage to continue.
  def pbFailsAgainstTarget?(user, target, show_message)
    return false
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp, false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# User faints. The Pokémon that replaces the user is fully healed (HP and
# status). Fails if user won't be replaced. (Healing Wish)
#===============================================================================
class Battle::Move::UserFaintsHealAndCureReplacement < Battle::Move
  def healingMove?; return true; end
  def canSnatch?;   return true; end

  def pbMoveFailed?(user, targets)
    if !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp, false)
    user.pbItemHPHealCheck
    @battle.positions[user.index].effects[PBEffects::HealingWish] = true
  end
end

#===============================================================================
# User faints. The Pokémon that replaces the user is fully healed (HP, PP and
# status). Fails if user won't be replaced. (Lunar Dance)
#===============================================================================
class Battle::Move::UserFaintsHealAndCureReplacementRestorePP < Battle::Move
  def healingMove?; return true; end
  def canSnatch?;   return true; end

  def pbMoveFailed?(user, targets)
    if !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp, false)
    user.pbItemHPHealCheck
    @battle.positions[user.index].effects[PBEffects::LunarDance] = true
  end
end

#===============================================================================
# All current battlers will perish after 3 more rounds. (Perish Song)
#===============================================================================
class Battle::Move::StartPerishCountsForAllBattlers < Battle::Move
  def pbMoveFailed?(user, targets)
    failed = true
    targets.each do |b|
      next if b.effects[PBEffects::PerishSong] > 0   # Heard it before
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return target.effects[PBEffects::PerishSong] > 0   # Heard it before
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::PerishSong]     = 4
    target.effects[PBEffects::PerishSongUser] = user.index
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    super
    @battle.pbDisplay(_INTL("All Pokémon that hear the song will faint in three turns!"))
  end
end

#===============================================================================
# The target will perish after 3 more rounds and cannot escape. The effect is
# lifted if the user of this move faints or switches out. (Doomed Serenade)
#===============================================================================
class Battle::Move::StartTargetDoomedSerenadeCount < Battle::Move
  def pbMoveFailed?(user, targets)
    failed = true
    targets.each do |b|
      next if b.effects[PBEffects::DoomedSerenadeCount] > 0   # Heard it before
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return target.effects[PBEffects::DoomedSerenadeCount] > 0   # Heard it before
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::DoomedSerenadeCount] = 4
    target.effects[PBEffects::DoomedSerenadeUser] = user.index
  end
end

#===============================================================================
# If user is KO'd before it next moves, the battler that caused it also faints.
# (Destiny Bond)
#===============================================================================
class Battle::Move::AttackerFaintsIfUserFaints < Battle::Move
  def pbMoveFailed?(user, targets)
    if Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::DestinyBondPrevious]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::DestinyBond] = true
    @battle.pbDisplay(_INTL("{1} is hoping to take its attacker down with it!", user.pbThis))
  end
end

#===============================================================================
# If user is KO'd before it next moves, the attack that caused it loses all PP.
# (Grudge)
#===============================================================================
class Battle::Move::SetAttackerMovePPTo0IfUserFaints < Battle::Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::Grudge] = true
    @battle.pbDisplay(_INTL("{1} wants its target to bear a grudge!", user.pbThis))
  end
end

#===============================================================================
# Healing move used for Sugar Power ability.
#===============================================================================
class Battle::Move::HealTargetByCustomAmount < Battle::Move::HealTargetHalfOfTotalHP
  attr_accessor :healAmt

  def pbDisplayUseMessage(user, mystery_shroud_type = nil); end

  def pbEffectAgainstTarget(user, target)
    if target.pbRecoverHP(@healAmt) > 0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
  end
end
