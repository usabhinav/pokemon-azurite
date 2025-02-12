#===============================================================================
# Inflicts a fixed 20HP damage. (Sonic Boom)
#===============================================================================
class Battle::Move::FixedDamage20 < Battle::Move::FixedDamageMove
  def pbFixedDamage(user, target)
    return 20
  end
end

#===============================================================================
# Inflicts a fixed 40HP damage. (Dragon Rage)
#===============================================================================
class Battle::Move::FixedDamage40 < Battle::Move::FixedDamageMove
  def pbFixedDamage(user, target)
    return 40
  end
end

#===============================================================================
# Halves the target's current HP. (Nature's Madness, Super Fang)
#===============================================================================
class Battle::Move::FixedDamageHalfTargetHP < Battle::Move::FixedDamageMove
  def pbFixedDamage(user, target)
    return (target.hp / 2.0).round
  end
end

#===============================================================================
# Inflicts damage equal to the user's level. (Night Shade, Seismic Toss)
#===============================================================================
class Battle::Move::FixedDamageUserLevel < Battle::Move::FixedDamageMove
  def pbFixedDamage(user, target)
    return user.level
  end
end

#===============================================================================
# Inflicts damage between 0.5 and 1.5 times the user's level. (Psywave)
#===============================================================================
class Battle::Move::FixedDamageUserLevelRandom < Battle::Move::FixedDamageMove
  def pbFixedDamage(user, target)
    min = (user.level / 2).floor
    max = (user.level * 3 / 2).floor
    return min + @battle.pbRandom(max - min + 1)
  end
end

#===============================================================================
# Inflicts damage to bring the target's HP down to equal the user's HP. (Endeavor)
#===============================================================================
class Battle::Move::LowerTargetHPToUserHP < Battle::Move::FixedDamageMove
  def pbFailsAgainstTarget?(user, target, show_message)
    if user.hp >= target.hp
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbNumHits(user, targets); return 1; end

  def pbFixedDamage(user, target)
    return target.hp - user.hp
  end
end

#===============================================================================
# Reduces the target's HP by an additional 20 HP. (Crystal Breath)
#===============================================================================
class Battle::Move::LowerTargetHP20 < Battle::Move
  def pbAdditionalEffect(user, target)
    target.pbReduceHP(20, false)
    @battle.pbDisplay(_INTL("Some crystal shards hit {1}!", target.pbThis(true)))
  end
end

#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target.
#===============================================================================
class Battle::Move::OHKO < Battle::Move::FixedDamageMove
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.level > user.level
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
      return true
    end
    if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("But it failed to affect {1}!", target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("But it failed to affect {1} because of its {2}!",
                                  target.pbThis(true), target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
      end
      return true
    end
    return false
  end

  def pbAccuracyCheck(user, target)
    acc = @accuracy + user.level - target.level
    return @battle.pbRandom(100) < acc
  end

  def pbFixedDamage(user, target)
    return target.totalhp
  end

  def pbHitEffectivenessMessages(user, target, numTargets = 1)
    super
    if target.fainted?
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
  end
end

#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target.
# Lower accuracy when used by a non-Ice-type Pokémon. Doesn't affect Ice-type
# Pokémon. (Sheer Cold (Gen 7+))
#===============================================================================
class Battle::Move::OHKOIce < Battle::Move::OHKO
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.pbHasType?(:ICE)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return super
  end

  def pbAccuracyCheck(user, target)
    acc = @accuracy + user.level - target.level
    acc -= 10 if !user.pbHasType?(:ICE)
    return @battle.pbRandom(100) < acc
  end
end

#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target. Hits
# targets that are semi-invulnerable underground. (Fissure)
#===============================================================================
class Battle::Move::OHKOHitsUndergroundTarget < Battle::Move::OHKO
  def hitsDiggingTargets?; return true; end
end

#===============================================================================
# OHKO, only if the target's HP is less than 30%. Also lowers the user's
# defenses by 50% for the turn of use, regardless of the move's success.
# (Finisher)
#===============================================================================
class Battle::Move::OHKOIfTargetLessThan30PercentOfTotalHPAndHalveUserDefenseThisTurn < Battle::Move
  def pbCalcDamage(user, target, numTargets = 1)
    if !shouldTriggerOHKO(user, target)
      @ohkoTriggered = false
      super
      return
    end
    @ohkoTriggered = true
    target.damageState.critical   = false
    target.damageState.calcDamage = pbFixedDamage(user, target)
    target.damageState.calcDamage = 1 if target.damageState.calcDamage < 1
  end

  def pbAccuracyCheck(user, target)
    return super if !shouldTriggerOHKO(user, target)
    acc = @accuracy + user.level - target.level
    return @battle.pbRandom(100) < acc
  end

  def pbFixedDamage(user, target)
    return target.totalhp
  end

  def pbHitEffectivenessMessages(user, target, numTargets = 1)
    super
    if target.fainted? && @ohkoTriggered
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
  end

  def shouldTriggerOHKO(user, target)
    return target.hp < (target.totalhp * 0.3).ceil &&
           target.level <= user.level &&
           !(target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker)
  end
end

#===============================================================================
# The target's ally loses 1/16 of its max HP. (Flame Burst)
#===============================================================================
class Battle::Move::DamageTargetAlly < Battle::Move
  def pbEffectWhenDealingDamage(user, target)
    hitAlly = []
    target.allAllies.each do |b|
      next if !b.near?(target.index)
      next if !b.takesIndirectDamage?
      hitAlly.push([b.index, b.hp])
      b.pbReduceHP(b.totalhp / 16, false)
    end
    if hitAlly.length == 2
      @battle.pbDisplay(_INTL("The bursting flame hit {1} and {2}!",
                              @battle.battlers[hitAlly[0][0]].pbThis(true),
                              @battle.battlers[hitAlly[1][0]].pbThis(true)))
    elsif hitAlly.length > 0
      hitAlly.each do |b|
        @battle.pbDisplay(_INTL("The bursting flame hit {1}!",
                                @battle.battlers[b[0]].pbThis(true)))
      end
    end
    hitAlly.each { |b| @battle.battlers[b[0]].pbItemHPHealCheck }
  end
end

#===============================================================================
# The user brings the target to the ozone layer and throws it back to the ground.
# In Doubles, its ally gets lightly damaged too (base power 40). (Ozone Throw)
#===============================================================================
class Battle::Move::DamageTargetAllyWithPower40 < Battle::Move
  def pbAddTarget(targets, user)
    @ally_targets = []
    targets.each do |t|
      next if !t.opposes?(user)
      t.eachAlly do |t_ally|
        if t.near?(t_ally) && !targets.include?(t_ally) && !@ally_targets.include?(t_ally)
          @ally_targets.push(t_ally)
          user.pbAddTarget(targets, user, t_ally, self, false)
        end
      end
    end
  end

  def pbBaseDamage(baseDmg, user, target)
    return 40 if @ally_targets.include?(target)
    return super
  end
end

#===============================================================================
# Power increases with the user's HP. (Eruption, Water Spout, Inner Force)
#===============================================================================
class Battle::Move::PowerHigherWithUserHP < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    return [150 * user.hp / user.totalhp, 1].max
  end
end

#===============================================================================
# Power increases the less HP the user has. (Flail, Reversal, Aura Storm)
#===============================================================================
class Battle::Move::PowerLowerWithUserHP < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    ret = 20
    n = 48 * user.hp / user.totalhp
    if n < 2
      ret = 200
    elsif n < 5
      ret = 150
    elsif n < 10
      ret = 100
    elsif n < 17
      ret = 80
    elsif n < 33
      ret = 40
    end
    return ret
  end
end

#===============================================================================
# Power increases the less HP the user has. Specifically, base damage increases
# +1 for every 1% max HP the user has lost. (Flaring Pride)
#===============================================================================
class Battle::Move::PowerLowerWithUserHPByPercent < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    return baseDmg + ((user.totalhp - user.hp).to_f * 100 / user.totalhp).floor
  end
end

#===============================================================================
# Power increases with the target's HP. (Crush Grip, Wring Out)
#===============================================================================
class Battle::Move::PowerHigherWithTargetHP < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    return [120 * target.hp / target.totalhp, 1].max
  end
end

#===============================================================================
# Power increases with the user's happiness. (Return)
#===============================================================================
class Battle::Move::PowerHigherWithUserHappiness < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    return [(user.happiness * 2 / 5).floor, 1].max
  end
end

#===============================================================================
# Power decreases with the user's happiness. (Frustration)
#===============================================================================
class Battle::Move::PowerLowerWithUserHappiness < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    return [((255 - user.happiness) * 2 / 5).floor, 1].max
  end
end

#===============================================================================
# Power increases with the user's positive stat changes (ignores negative ones).
# (Power Trip, Stored Power)
#===============================================================================
class Battle::Move::PowerHigherWithUserPositiveStatStages < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    mult = 1
    GameData::Stat.each_battle { |s| mult += user.modifiedStages[s.id] if user.modifiedStages[s.id] > 0 }
    return 20 * mult
  end
end

#===============================================================================
# Power increases with the target's positive stat changes (ignores negative ones).
# (Punishment)
#===============================================================================
class Battle::Move::PowerHigherWithTargetPositiveStatStages < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    mult = 3
    GameData::Stat.each_battle { |s| mult += target.modifiedStages[s.id] if target.modifiedStages[s.id] > 0 }
    return [20 * mult, 200].min
  end
end

#===============================================================================
# Power increases the quicker the user is than the target. (Electro Ball)
#===============================================================================
class Battle::Move::PowerHigherWithUserFasterThanTarget < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    ret = 40
    n = user.pbSpeed / target.pbSpeed
    if n >= 4
      ret = 150
    elsif n >= 3
      ret = 120
    elsif n >= 2
      ret = 80
    elsif n >= 1
      ret = 60
    end
    return ret
  end
end

#===============================================================================
# Power increases the quicker the target is than the user. (Gyro Ball)
#===============================================================================
class Battle::Move::PowerHigherWithTargetFasterThanUser < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    return [[(25 * target.pbSpeed / user.pbSpeed).floor, 150].min, 1].max
  end
end

#===============================================================================
# Power increases the less PP this move has. (Trump Card)
#===============================================================================
class Battle::Move::PowerHigherWithLessPP < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    dmgs = [200, 80, 60, 50, 40]
    ppLeft = [@pp, dmgs.length - 1].min   # PP is reduced before the move is used
    return dmgs[ppLeft]
  end
end

#===============================================================================
# Power increases the heavier the target is. (Grass Knot, Low Kick)
#===============================================================================
class Battle::Move::PowerHigherWithTargetWeight < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    ret = 20
    weight = target.pbWeight
    if weight >= 2000
      ret = 120
    elsif weight >= 1000
      ret = 100
    elsif weight >= 500
      ret = 80
    elsif weight >= 250
      ret = 60
    elsif weight >= 100
      ret = 40
    end
    return ret
  end
end

#===============================================================================
# Power increases the heavier the user is than the target. (Heat Crash, Heavy Slam)
#===============================================================================
class Battle::Move::PowerHigherWithUserHeavierThanTarget < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    ret = 40
    n = (user.pbWeight / target.pbWeight).floor
    if n >= 5
      ret = 120
    elsif n >= 4
      ret = 100
    elsif n >= 3
      ret = 80
    elsif n >= 2
      ret = 60
    end
    return ret
  end
end

#===============================================================================
# Power doubles for each consecutive use. (Fury Cutter)
#===============================================================================
class Battle::Move::PowerHigherWithConsecutiveUse < Battle::Move
  def pbChangeUsageCounters(user, specialUsage)
    oldVal = user.effects[PBEffects::FuryCutter]
    super
    maxMult = 1
    while (@baseDamage << (maxMult - 1)) < 160
      maxMult += 1   # 1-4 for base damage of 20, 1-3 for base damage of 40
    end
    user.effects[PBEffects::FuryCutter] = (oldVal >= maxMult) ? maxMult : oldVal + 1
  end

  def pbBaseDamage(baseDmg, user, target)
    return baseDmg << (user.effects[PBEffects::FuryCutter] - 1)
  end
end

#===============================================================================
# Power is multiplied by the number of consecutive rounds in which this move was
# used by any Pokémon on the user's side. (Echoed Voice)
#===============================================================================
class Battle::Move::PowerHigherWithConsecutiveUseOnUserSide < Battle::Move
  def pbChangeUsageCounters(user, specialUsage)
    oldVal = user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]
    super
    if !user.pbOwnSide.effects[PBEffects::EchoedVoiceUsed]
      user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] = (oldVal >= 5) ? 5 : oldVal + 1
    end
    user.pbOwnSide.effects[PBEffects::EchoedVoiceUsed] = true
  end

  def pbBaseDamage(baseDmg, user, target)
    return baseDmg * user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]   # 1-5
  end
end

#===============================================================================
# Power is multiplied by the number of Bug-type Pokemon in the user's and
# allies' parties. (Swarm Attack)
#===============================================================================
class Battle::Move::PowerHigherWithMoreBugTypesInParty < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    return baseDmg * [@battle.pbGetTypeListsOfBattlersAndParty(user.index).count {|types| types.include?(:BUG)}, 1].max
  end
end

#===============================================================================
# Power is multiplied by the number of Cosmic-type Pokemon in the user's and
# allies' parties (20 per Cosmic-type, minimum of 50). (Star Line)
#===============================================================================
class Battle::Move::PowerHigherWithMoreCosmicTypesInParty < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    return baseDmg + (20 * @battle.pbGetTypeListsOfBattlersAndParty(user.index).count {|types| types.include?(:COSMIC)})
  end
end

#===============================================================================
# Power is raised to 135 if the user was hit by a special attack this turn.
# (Reflective Blast)
#===============================================================================
class Battle::Move::PowerHigherIfUserHitBySpecialAttack < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    # The MirrorCoat effect is set under the same conditions, when the user has
    # been hit by a special attack this turn, so we can just reuse it.
    return 135 if user.effects[PBEffects::MirrorCoat] >= 0
    return super
  end
end

#===============================================================================
# Power is increased by 25 for each fainted Pokemon in the opponent's party.
# Includes all trainers on the opposing side if there is more than one.
# (Tomb Raid)
#===============================================================================
class Battle::Move::PowerHigherWithMoreFaintedPokemonInTargetParty < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    return baseDmg + (25 * @battle.pbParty(target.index).count {|pokemon| pokemon.fainted?})
  end
end

#===============================================================================
# Power is increased by 10 for each Nidoking in the user's and allies' parties.
# (Boyfriends)
#===============================================================================
class Battle::Move::PowerHigherWithMoreNidokingsInParty < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    return baseDmg + (10 * @battle.pbParty(user.index).count {|pokemon| !pokemon.egg? && pokemon.isSpecies?(:NIDOKING)})
  end
end

#===============================================================================
# Power and accuracy are increased by 50% in sunlight. (Light Beam)
#===============================================================================
class Battle::Move::PowerHigherAndAccuracyHigherInSunlight < Battle::Move
  def pbBaseAccuracy(user, target)
    ret = super
    ret = [(ret * 1.5).floor, 100].min if [:Sun, :HarshSun].include?(user.effectiveWeather)
    return ret
  end

  def pbBaseDamage(baseDmg, user, target)
    baseDmg = (baseDmg * 1.5).floor if [:Sun, :HarshSun].include?(user.effectiveWeather)
    return baseDmg
  end
end

#===============================================================================
# Power is increased by 20% if the target has already moved; else, incoming
# damage is reduced by 20%. (Mystic Edge)
#===============================================================================
class Battle::Move::PowerHigherIfTargetActedElseStartReduceIncomingDamage < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if @battle.choices[target.index][0] != :None &&
      ((@battle.choices[target.index][0] != :UseMove &&
      @battle.choices[target.index][0] != :Shift) || target.movedThisRound?)
      baseDmg *= 1.2
    else
      user.effects[PBEffects::MysticEdgeActive] = true
    end
    return baseDmg
  end
end

#===============================================================================
# Power is doubled in sunlight, and 2.5x in Desolate Land. (Crashing Sun)
#===============================================================================
class Battle::Move::PowerHigherWithSunnyWeather < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    case user.effectiveWeather
    when :HarshSun
      baseDmg = (baseDmg * 2.5).floor
    when :Sun
      baseDmg = baseDmg * 2
    end
    return baseDmg
  end
end

#===============================================================================
# Power is chosen at random. Power is doubled if the target is using Dig. Hits
# some semi-invulnerable targets. (Magnitude)
#===============================================================================
class Battle::Move::RandomPowerDoublePowerIfTargetUnderground < Battle::Move
  def hitsDiggingTargets?; return true; end

  def pbOnStartUse(user, targets)
    baseDmg = [10, 30, 50, 70, 90, 110, 150]
    magnitudes = [
      4,
      5, 5,
      6, 6, 6, 6,
      7, 7, 7, 7, 7, 7,
      8, 8, 8, 8,
      9, 9,
      10
    ]
    magni = magnitudes[@battle.pbRandom(magnitudes.length)]
    @magnitudeDmg = baseDmg[magni - 4]
    @battle.pbDisplay(_INTL("Magnitude {1}!", magni))
  end

  def pbBaseDamage(baseDmg, user, target)
    return @magnitudeDmg
  end

  def pbModifyDamage(damageMult, user, target)
    damageMult *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
    damageMult /= 2 if @battle.field.terrain == :Grassy
    return damageMult
  end
end

#===============================================================================
# Power is doubled if the target's HP is down to 1/2 or less. (Brine)
#===============================================================================
class Battle::Move::DoublePowerIfTargetHPLessThanHalf < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if target.hp <= target.totalhp / 2
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the user is burned, poisoned or paralyzed. (Facade)
# Burn's halving of Attack is negated (new mechanics).
#===============================================================================
class Battle::Move::DoublePowerIfUserPoisonedBurnedParalyzed < Battle::Move
  def damageReducedByBurn?; return Settings::MECHANICS_GENERATION <= 5; end

  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if user.poisoned? || user.burned? || user.paralyzed?
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the target is asleep. Wakes the target up. (Wake-Up Slap)
#===============================================================================
class Battle::Move::DoublePowerIfTargetAsleepCureTarget < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if target.asleep? &&
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end

  def pbEffectAfterAllHits(user, target)
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if target.status != :SLEEP
    target.pbCureStatus
  end
end

#===============================================================================
# Power is doubled if the target is poisoned. (Venoshock)
#===============================================================================
class Battle::Move::DoublePowerIfTargetPoisoned < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if target.poisoned? &&
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end
end



#===============================================================================
# Power is doubled if the target is paralyzed. Cures the target of paralysis.
# (Smelling Salts)
#===============================================================================
class Battle::Move::DoublePowerIfTargetParalyzedCureTarget < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if target.paralyzed? &&
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end

  def pbEffectAfterAllHits(user, target)
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if target.status != :PARALYSIS
    target.pbCureStatus
  end
end

#===============================================================================
# Power is doubled if the target has a status problem. (Hex)
#===============================================================================
class Battle::Move::DoublePowerIfTargetStatusProblem < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if target.pbHasAnyStatus? &&
       (target.effects[PBEffects::Substitute] == 0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the user has no held item. (Acrobatics)
#===============================================================================
class Battle::Move::DoublePowerIfUserHasNoItem < Battle::Move
  def pbBaseDamageMultiplier(damageMult, user, target)
    damageMult *= 2 if !user.item || user.effects[PBEffects::GemConsumed]
    return damageMult
  end
end

#===============================================================================
# Power is doubled if the target is using Dive. Hits some semi-invulnerable
# targets. (Surf)
#===============================================================================
class Battle::Move::DoublePowerIfTargetUnderwater < Battle::Move
  def hitsDivingTargets?; return true; end

  def pbModifyDamage(damageMult, user, target)
    damageMult *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderwater")
    return damageMult
  end
end

#===============================================================================
# Power is doubled if the target is using Dig. Power is halved if Grassy Terrain
# is in effect. Hits some semi-invulnerable targets. (Earthquake)
#===============================================================================
class Battle::Move::DoublePowerIfTargetUnderground < Battle::Move
  def hitsDiggingTargets?; return true; end

  def pbModifyDamage(damageMult, user, target)
    damageMult *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
    damageMult /= 2 if @battle.field.terrain == :Grassy
    return damageMult
  end
end

#===============================================================================
# Power is doubled if the target is using Bounce, Fly or Sky Drop. Hits some
# semi-invulnerable targets. (Gust)
#===============================================================================
class Battle::Move::DoublePowerIfTargetInSky < Battle::Move
  def hitsFlyingTargets?; return true; end

  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                            "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                            "TwoTurnAttackInvulnerableInSkyTargetCannotAct") ||
                    target.effects[PBEffects::SkyDrop] >= 0 ||
                    target.effects[PBEffects::AirSupportTurnCount] > 0
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if Electric Terrain applies. (Rising Voltage)
#===============================================================================
class Battle::Move::DoublePowerInElectricTerrain < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if @battle.field.terrain == :Electric && target.affectedByTerrain?
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the user's last move failed. (Stomping Tantrum)
#===============================================================================
class Battle::Move::DoublePowerIfUserLastMoveFailed < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if user.lastRoundMoveFailed
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if a user's teammate fainted last round. (Retaliate)
#===============================================================================
class Battle::Move::DoublePowerIfAllyFaintedLastTurn < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    lrf = user.pbOwnSide.effects[PBEffects::LastRoundFainted]
    baseDmg *= 2 if lrf >= 0 && lrf == @battle.turnCount - 1
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the user has lost HP due to the target's move this round.
# (Avalanche, Revenge)
#===============================================================================
class Battle::Move::DoublePowerIfUserLostHPThisTurn < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if user.lastAttacker.include?(target.index)
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the target has already lost HP this round. (Assurance)
#===============================================================================
class Battle::Move::DoublePowerIfTargetLostHPThisTurn < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if target.tookDamageThisRound
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if any of the user's stats were lowered this round. (Lash Out)
#===============================================================================
class Battle::Move::DoublePowerIfUserStatsLoweredThisTurn < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if user.statsLoweredThisRound
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the target has already moved this round. (Payback)
#===============================================================================
class Battle::Move::DoublePowerIfTargetActed < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if @battle.choices[target.index][0] != :None &&
       ((@battle.choices[target.index][0] != :UseMove &&
       @battle.choices[target.index][0] != :Shift) || target.movedThisRound?)
      baseDmg *= 2
    end
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the user moves before the target, or if the target
# switched in this round. (Bolt Beak, Fishious Rend)
#===============================================================================
class Battle::Move::DoublePowerIfTargetNotActed < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    if @battle.choices[target.index][0] == :None ||   # Switched in
       ([:UseMove, :Shift].include?(@battle.choices[target.index][0]) && !target.movedThisRound?)
      baseDmg *= 2
    end
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the target has the Crystal-type. (Crystal Overload)
#===============================================================================
class Battle::Move::DoublePowerIfTargetHasCrystalType < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if target.pbHasType?(:CRYSTAL)
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if this move is not very effective against the target.
# (Glass Blade)
#===============================================================================
class Battle::Move::DoublePowerIfResistedByTarget < Battle::Move
  def pbModifyDamage(damageMult, user, target)
    damageMult *= 2 if Effectiveness.resistant?(target.damageState.typeMod)
    return damageMult
  end
end

#===============================================================================
# Power is doubled if the target has a higher percentage of their HP remaining
# than the user. (Delta Beam)
#===============================================================================
class Battle::Move::DoublePowerIfTargetHasMoreHPThanUser < Battle::Move
  def pbModifyDamage(damageMult, user, target)
    damageMult *= 2 if (target.hp.to_f / target.totalhp) > (user.hp.to_f / user.totalhp)
    return damageMult
  end
end

#===============================================================================
# Power is doubled if the target has the Dark-type. (Flash Kick)
#===============================================================================
class Battle::Move::DoublePowerIfTargetHasDarkType < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if target.pbHasType?(:DARK)
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if this move strikes before all other moves. (Flash Strike)
#===============================================================================
class Battle::Move::DoublePowerIfNoBattlersActed < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    anyMoved = @battle.allBattlers.any? do |b|
      b.index != user.index && [:UseMove, :Shift].include?(@battle.choices[b.index][0]) && b.movedThisRound?
    end
    baseDmg *= 2 if !anyMoved
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the target shares a type with the user. (Gleam Beam)
#===============================================================================
class Battle::Move::DoublePowerIfTargetSharesTypeWithUser < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if !(user.pbTypes(true) & target.pbTypes(true)).empty?
    return baseDmg
  end
end

#===============================================================================
# Power is doubled if the target is airborne. (Ascendance Kick)
#===============================================================================
class Battle::Move::DoublePowerIfTargetIsAirborne < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if target.airborne?
    return baseDmg
  end
end

#===============================================================================
# This attack is always a critical hit. (Frost Breath, Storm Throw)
#===============================================================================
class Battle::Move::AlwaysCriticalHit < Battle::Move
  def pbCritialOverride(user, target); return 1; end
end

#===============================================================================
# Until the end of the next round, the user's moves will always be critical hits.
# (Laser Focus)
#===============================================================================
class Battle::Move::EnsureNextCriticalHit < Battle::Move
  def canSnatch?; return true; end

  def pbEffectGeneral(user)
    user.effects[PBEffects::LaserFocus] = 2
    @battle.pbDisplay(_INTL("{1} concentrated intensely!", user.pbThis))
  end
end

#===============================================================================
# For 5 rounds, foes' attacks cannot become critical hits. (Lucky Chant)
#===============================================================================
class Battle::Move::StartPreventCriticalHitsAgainstUserSide < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.pbOwnSide.effects[PBEffects::LuckyChant] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::LuckyChant] = 5
    @battle.pbDisplay(_INTL("The Lucky Chant shielded {1} from critical hits!", user.pbTeam(true)))
  end
end

#===============================================================================
# This attack is always super effective. (Surprise Attack)
#===============================================================================
class Battle::Move::AlwaysSuperEffective < Battle::Move
  def pbCalcTypeMod(movetype, user, target)
    ret = super
    # If multiplier is 4x or more, keep that, otherwise minimum should be 2x.
    return [ret, Effectiveness::NORMAL_EFFECTIVE * Effectiveness::NORMAL_EFFECTIVE_ONE].max
  end
end

#===============================================================================
# If target would be KO'd by this attack, it survives with 1HP instead.
# (False Swipe, Hold Back)
#===============================================================================
class Battle::Move::CannotMakeTargetFaint < Battle::Move
  def nonLethal?(user, target); return true; end
end

#===============================================================================
# If user would be KO'd this round, it survives with 1HP instead. (Endure)
#===============================================================================
class Battle::Move::UserEnduresFaintingThisTurn < Battle::Move::ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::Endure
  end

  def pbProtectMessage(user)
    @battle.pbDisplay(_INTL("{1} braced itself!", user.pbThis))
  end
end

#===============================================================================
# Weakens Electric attacks. (Mud Sport)
#===============================================================================
class Battle::Move::StartWeakenElectricMoves < Battle::Move
  def pbMoveFailed?(user, targets)
    if Settings::MECHANICS_GENERATION >= 6
      if @battle.field.effects[PBEffects::MudSportField] > 0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    elsif @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    if Settings::MECHANICS_GENERATION >= 6
      @battle.field.effects[PBEffects::MudSportField] = 5
    else
      user.effects[PBEffects::MudSport] = true
    end
    @battle.pbDisplay(_INTL("Electricity's power was weakened!"))
  end
end

#===============================================================================
# Weakens Fire attacks. (Water Sport)
#===============================================================================
class Battle::Move::StartWeakenFireMoves < Battle::Move
  def pbMoveFailed?(user, targets)
    if Settings::MECHANICS_GENERATION >= 6
      if @battle.field.effects[PBEffects::WaterSportField] > 0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    elsif @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    if Settings::MECHANICS_GENERATION >= 6
      @battle.field.effects[PBEffects::WaterSportField] = 5
    else
      user.effects[PBEffects::WaterSport] = true
    end
    @battle.pbDisplay(_INTL("Fire's power was weakened!"))
  end
end

#===============================================================================
# For 5 rounds, lowers power of physical attacks against the user's side.
# (Reflect)
#===============================================================================
class Battle::Move::StartWeakenPhysicalDamageAgainstUserSide < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.pbOwnSide.effects[PBEffects::Reflect] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::Reflect] = 5
    user.pbOwnSide.effects[PBEffects::Reflect] = 8 if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} raised {2}'s Defense!", @name, user.pbTeam(true)))
  end
end

#===============================================================================
# For 5 rounds, lowers power of special attacks against the user's side. (Light Screen)
#===============================================================================
class Battle::Move::StartWeakenSpecialDamageAgainstUserSide < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.pbOwnSide.effects[PBEffects::LightScreen] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::LightScreen] = 5
    user.pbOwnSide.effects[PBEffects::LightScreen] = 8 if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} raised {2}'s Special Defense!", @name, user.pbTeam(true)))
  end
end

#===============================================================================
# For 5 rounds, lowers power of attacks against the user's side. Fails if
# weather is not hail. (Aurora Veil)
#===============================================================================
class Battle::Move::StartWeakenDamageAgainstUserSideIfHail < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.effectiveWeather != :Hail
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 5
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 8 if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
                            @name, user.pbTeam(true)))
  end
end

#===============================================================================
# Ends the opposing side's Light Screen, Reflect and Aurora Break. (Brick Break,
# Psychic Fangs)
#===============================================================================
class Battle::Move::RemoveScreens < Battle::Move
  def ignoresReflect?; return true; end

  def pbEffectGeneral(user)
    if user.pbOpposingSide.effects[PBEffects::LightScreen] > 0
      user.pbOpposingSide.effects[PBEffects::LightScreen] = 0
      @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!", user.pbOpposingTeam))
    end
    if user.pbOpposingSide.effects[PBEffects::Reflect] > 0
      user.pbOpposingSide.effects[PBEffects::Reflect] = 0
      @battle.pbDisplay(_INTL("{1}'s Reflect wore off!", user.pbOpposingTeam))
    end
    if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
      user.pbOpposingSide.effects[PBEffects::AuroraVeil] = 0
      @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!", user.pbOpposingTeam))
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    if user.pbOpposingSide.effects[PBEffects::LightScreen] > 0 ||
       user.pbOpposingSide.effects[PBEffects::Reflect] > 0 ||
       user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
      hitNum = 1   # Wall-breaking anim
    end
    super
  end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. (Detect, Protect)
#===============================================================================
class Battle::Move::ProtectUser < Battle::Move::ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::Protect
  end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# makes contact with the user while this effect applies, that Pokémon is
# poisoned. (Baneful Bunker)
#===============================================================================
class Battle::Move::ProtectUserBanefulBunker < Battle::Move::ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::BanefulBunker
  end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Attack of
# the user of a stopped contact move by 2 stages. (King's Shield)
#===============================================================================
class Battle::Move::ProtectUserFromDamagingMovesKingsShield < Battle::Move::ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::KingsShield
  end
end

#===============================================================================
# For the rest of this round, the user avoids all damaging moves that would hit
# it. If a move that makes contact is stopped by this effect, decreases the
# Defense of the Pokémon using that move by 2 stages. Contributes to Protect's
# counter. (Obstruct)
#===============================================================================
class Battle::Move::ProtectUserFromDamagingMovesObstruct < Battle::Move::ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::Obstruct
  end
end

#===============================================================================
# User is protected against moves that target it this round. Damages the user of
# a stopped contact move by 1/8 of its max HP. (Spiky Shield)
#===============================================================================
class Battle::Move::ProtectUserFromTargetingMovesSpikyShield < Battle::Move::ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::SpikyShield
  end
end

#===============================================================================
# User is protected against moves that target it this round. Raises the user's
# Attack or Special Attack depending on the category of the move that targets
# it. (Bark Armor)
#===============================================================================
class Battle::Move::ProtectUserBoostAttackOrSpAtkBasedOnTargetAttack < Battle::Move::ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::BarkArmor
  end
end

#===============================================================================
# User is protected against moves that target it this round. The user's typing
# changes to the type of the move that targets it. (Refraction)
#===============================================================================
class Battle::Move::ProtectUserChangeUserTypeToIncomingAttackType < Battle::Move::ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::Refraction
  end
end

#===============================================================================
# This round, the user's side is unaffected by damaging moves. (Mat Block)
#===============================================================================
class Battle::Move::ProtectUserSideFromDamagingMovesIfUserFirstTurn < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.turnCount > 1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedLastInRound?(user)
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::MatBlock] = true
    @battle.pbDisplay(_INTL("{1} intends to flip up a mat and block incoming attacks!", user.pbThis))
  end
end

#===============================================================================
# User's side is protected against status moves this round. (Crafty Shield)
#===============================================================================
class Battle::Move::ProtectUserSideFromStatusMoves < Battle::Move
  def pbMoveFailed?(user, targets)
    if user.pbOwnSide.effects[PBEffects::CraftyShield]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedLastInRound?(user)
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::CraftyShield] = true
    @battle.pbDisplay(_INTL("Crafty Shield protected {1}!", user.pbTeam(true)))
  end
end

#===============================================================================
# User's side is protected against moves with priority greater than 0 this round.
# (Quick Guard)
#===============================================================================
class Battle::Move::ProtectUserSideFromPriorityMoves < Battle::Move::ProtectMove
  def canSnatch?; return true; end

  def initialize(battle, move)
    super
    @effect      = PBEffects::QuickGuard
    @sidedEffect = true
  end
end

#===============================================================================
# User's side is protected against moves that target multiple battlers this round.
# (Wide Guard)
#===============================================================================
class Battle::Move::ProtectUserSideFromMultiTargetDamagingMoves < Battle::Move::ProtectMove
  def canSnatch?; return true; end

  def initialize(battle, move)
    super
    @effect      = PBEffects::WideGuard
    @sidedEffect = true
  end
end

#===============================================================================
# User's side is protected against all moves. (Grand Rebound)
#===============================================================================
class Battle::Move::ProtectUserSide < Battle::Move::ProtectMove
  def canSnatch?; return true; end

  def initialize(battle, move)
    super
    @effect      = PBEffects::GrandRebound
    @sidedEffect = true
  end
end

#===============================================================================
# Ends target's protections immediately. (Feint)
#===============================================================================
class Battle::Move::RemoveProtections < Battle::Move
  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Obstruct]               = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.effects[PBEffects::BarkArmor]              = false
    target.effects[PBEffects::Refraction]             = false
    target.effects[PBEffects::BlackHoleActive]        = false
    target.effects[PBEffects::PortalReboundActive]    = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
    target.pbOwnSide.effects[PBEffects::GrandRebound] = false
  end
end

#===============================================================================
# Ends target's protections immediately. (Hyperspace Hole, Energy Wave)
#===============================================================================
class Battle::Move::RemoveProtectionsBypassSubstitute < Battle::Move
  def ignoresSubstitute?(user); return true; end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Obstruct]               = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.effects[PBEffects::BarkArmor]              = false
    target.effects[PBEffects::Refraction]             = false
    target.effects[PBEffects::BlackHoleActive]        = false
    target.effects[PBEffects::PortalReboundActive]    = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
    target.pbOwnSide.effects[PBEffects::GrandRebound] = false
  end
end

#===============================================================================
# Decreases the user's Defense by 1 stage. Ends target's protections
# immediately. (Hyperspace Fury)
#===============================================================================
class Battle::Move::HoopaRemoveProtectionsBypassSubstituteLowerUserDef1 < Battle::Move::StatDownMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle, move)
    super
    @statDown = [:DEFENSE, 1]
  end

  def pbMoveFailed?(user, targets)
    if !user.isSpecies?(:HOOPA)
      @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true)))
      return true
    elsif user.form != 1
      @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true)))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Obstruct]               = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.effects[PBEffects::BarkArmor]              = false
    target.effects[PBEffects::Refraction]             = false
    target.effects[PBEffects::BlackHoleActive]        = false
    target.effects[PBEffects::PortalReboundActive]    = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
    target.pbOwnSide.effects[PBEffects::GrandRebound] = false
  end
end

#===============================================================================
# User takes recoil damage equal to 1/4 of the damage this move dealt.
#===============================================================================
class Battle::Move::RecoilQuarterOfDamageDealt < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
    recoil_damage = (target.damageState.totalHPLost / 4.0).round
    recoil_damage = (recoil_damage * 1.5).floor if user.hasActiveAbility?(:EXPLOSIVEEXHAUST)
    return recoil_damage
  end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
#===============================================================================
class Battle::Move::RecoilThirdOfDamageDealt < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
    recoil_damage = (target.damageState.totalHPLost / 3.0).round
    recoil_damage = (recoil_damage * 1.5).floor if user.hasActiveAbility?(:EXPLOSIVEEXHAUST)
    return recoil_damage
  end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May paralyze the target. (Volt Tackle)
#===============================================================================
class Battle::Move::RecoilThirdOfDamageDealtParalyzeTarget < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
    recoil_damage = (target.damageState.totalHPLost / 3.0).round
    recoil_damage = (recoil_damage * 1.5).floor if user.hasActiveAbility?(:EXPLOSIVEEXHAUST)
    return recoil_damage
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
  end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May burn the target. (Flare Blitz)
#===============================================================================
class Battle::Move::RecoilThirdOfDamageDealtBurnTarget < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
    recoil_damage = (target.damageState.totalHPLost / 3.0).round
    recoil_damage = (recoil_damage * 1.5).floor if user.hasActiveAbility?(:EXPLOSIVEEXHAUST)
    return recoil_damage
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbBurn(user) if target.pbCanBurn?(user, false, self)
  end
end

#===============================================================================
# User takes recoil damage equal to 10% of their max HP. May burn the target.
# (Combustion)
#===============================================================================
class Battle::Move::RecoilTenPercentOfTotalHPBurnTarget < Battle::Move
  def recoilMove?;                 return true; end

  def pbAddTarget(targets, user)
    # Should not target itself.
    targets.reject! {|t| t.index == user.index}
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbBurn(user) if target.pbCanBurn?(user, false, self)
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    return if user.fainted? || numHits == 0
    return if !user.takesIndirectDamage?
    return if user.hasActiveAbility?(:ROCKHEAD)
    amt = (user.totalhp / 10.0).round
    amt = (amt * 1.5).floor if user.hasActiveAbility?(:EXPLOSIVEEXHAUST)
    amt = 1 if amt < 1
    user.pbReduceHP(amt, false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May freeze the target. (Frost Blitz)
#===============================================================================
class Battle::Move::RecoilThirdOfDamageDealtFreezeTarget < Battle::Move::RecoilThirdOfDamageDealt
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbFreeze if target.pbCanFreeze?(user, false, self)
  end
end

#===============================================================================
# User takes recoil damage equal to 1/2 of the damage this move dealt.
# (Head Smash, Light of Ruin)
#===============================================================================
class Battle::Move::RecoilHalfOfDamageDealt < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
    recoil_damage = (target.damageState.totalHPLost / 2.0).round
    recoil_damage = (recoil_damage * 1.5).floor if user.hasActiveAbility?(:EXPLOSIVEEXHAUST)
    return recoil_damage
  end
end

#===============================================================================
# User takes recoil damage equal to 1/2 of their current HP. (Sunder Surge)
#===============================================================================
class Battle::Move::RecoilHalfOfUserCurrentHP < Battle::Move::RecoilMove
  def pbRecoilDamage(user,target)
    recoil_damage = (user.hp / 2.0).round
    recoil_damage = (recoil_damage * 1.5).floor if user.hasActiveAbility?(:EXPLOSIVEEXHAUST)
    return recoil_damage
  end
end

#===============================================================================
# User takes recoil damage equal to 30% of the damage this move dealt, unless
# the user was hit by a contact move in the same turn, in which case, this
# move's power increases by 50%, won't miss, and no recoil. (Comet Swing)
#===============================================================================
class Battle::Move::Recoil30PercentUnlessHitByContactMoveThenPowerHigherBy50PercentAndNoRecoil < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
    recoil_damage = (target.damageState.totalHPLost * 0.3).round
    recoil_damage = (recoil_damage * 1.5).floor if user.hasActiveAbility?(:EXPLOSIVEEXHAUST)
    return recoil_damage
  end

  def pbBaseDamage(baseDmg, user, target)
    baseDmg = baseDmg * 3 / 2 if user.effects[PBEffects::CometSwingEffectsActive]
    return baseDmg
  end

  def pbBaseAccuracy(user, target)
    return 0 if user.effects[PBEffects::CometSwingEffectsActive]
    return super
  end

  def pbEffectAfterAllHits(user, target)
    return if user.effects[PBEffects::CometSwingEffectsActive]
    super
  end
end

#===============================================================================
# User takes recoil damage equal to 30% of the damage this move dealt and may
# confuse the target. (Suplex)
#===============================================================================
class Battle::Move::Recoil30PercentAndConfuseTarget < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
    recoil_damage = (target.damageState.totalHPLost * 0.3).round
    recoil_damage = (recoil_damage * 1.5).floor if user.hasActiveAbility?(:EXPLOSIVEEXHAUST)
    return recoil_damage
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    return if !target.pbCanConfuse?(user, false, self)
    target.pbConfuse
  end
end

#===============================================================================
# User takes recoil damage equal to 40% of the damage this move dealt and may
# burn the target. (Flare Fist)
#===============================================================================
class Battle::Move::Recoil40PercentAndBurnTarget < Battle::Move::RecoilMove
  def pbRecoilDamage(user, target)
    recoil_damage = (target.damageState.totalHPLost * 4 / 10.0).round
    recoil_damage = (recoil_damage * 1.5).floor if user.hasActiveAbility?(:EXPLOSIVEEXHAUST)
    return recoil_damage
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbBurn(user) if target.pbCanBurn?(user, false, self)
  end
end

#===============================================================================
# User takes recoil damage equal to 1/2 of their max HP. Fails if the user's
# current HP is less than or equal to half of their max HP. (Energy Bomb)
#===============================================================================
class Battle::Move::RecoilHalfOfUserTotalHPFailsIfUserHPNotGreaterThanHalfOfTotalHP < Battle::Move::RecoilMove
  def pbMoveFailed?(user, targets)
    if user.hp <= (user.totalhp / 2)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbRecoilDamage(user,target)
    # Not affected by Explosive Exhaust
    return user.totalhp / 2
  end
end

#===============================================================================
# Type effectiveness is multiplied by the Flying-type's effectiveness against
# the target. (Flying Press)
#===============================================================================
class Battle::Move::EffectivenessIncludesFlyingType < Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = super
    if GameData::Type.exists?(:FLYING)
      flyingEff = Effectiveness.calculate_one(:FLYING, defType)
      ret *= flyingEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
    end
    return ret
  end
end

#===============================================================================
# Type effectiveness is multiplied by the Fire-type's effectiveness against
# the target. (Searing Meteor)
#===============================================================================
class Battle::Move::EffectivenessIncludesFireType < Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = super
    fireEff = Effectiveness.calculate_one(:FIRE, defType)
    ret *= fireEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
    return ret
  end
end

#===============================================================================
# Type effectiveness is multiplied by the Sound-type's effectiveness against
# the target. (Volt Wave)
#===============================================================================
class Battle::Move::EffectivenessIncludesSoundType < Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = super
    eff = Effectiveness.calculate_one(:SOUND, defType)
    ret *= eff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
    return ret
  end
end

#===============================================================================
# Type effectiveness is multiplied by the Grass-type's effectiveness against
# the target. (Magical Roots)
#===============================================================================
class Battle::Move::EffectivenessIncludesGrassType < Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = super
    eff = Effectiveness.calculate_one(:GRASS, defType)
    ret *= eff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
    return ret
  end
end

#===============================================================================
# Type effectiveness is overridden in cases where Light-type would be super
# effective against the defending type. (Luminous Gust)
#===============================================================================
class Battle::Move::EffectivenessIncludesLightTypeOnlyIfSuperEffective < Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    if Effectiveness.calculate_one(:LIGHT, defType) == Effectiveness::SUPER_EFFECTIVE_ONE
      return Effectiveness::SUPER_EFFECTIVE_ONE
    end
    return super
  end
end

#===============================================================================
# Super effective against Fire-types, and neutral effective against Ice-types.
# (Heat Drop)
#===============================================================================
class Battle::Move::SuperEffectiveAgainstFireNeutralEffectiveAgainstIce < Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :FIRE
    return Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :ICE
    return super
  end
end

#===============================================================================
# Super effective against Flying-types. Lowers the user's Defense if it misses.
# (Sand Hammer)
#===============================================================================
class Battle::Move::SuperEffectiveAgainstFlyingAndLowerUserDefense1IfMisses < Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :FLYING
    return super
  end

  # Re-using this method since it triggers on all targets missed.
  def pbCrashDamage(user)
    if user.pbCanLowerStatStage?(:DEFENSE, user, self)
      user.pbLowerStatStage(:DEFENSE, 1, user)
    end
  end
end

#===============================================================================
# Super effective against types that the user is weak to.
# (Wonder Strike, Wonder Wind)
#===============================================================================
class Battle::Move::SuperEffectiveAgainstUserWeaknesses < Battle::Move
  def pbCalcTypeModSingle(moveType, defType, user, target)
    user_types = user.pbTypes(true)
    user_weak_types = []
    GameData::Type.each do |i|
      user_weak_types.push(i.id) if i != :QMARKS && Effectiveness.super_effective_type?(i.id, *user_types)
    end
    if user_weak_types.include?(defType)
      return Effectiveness::SUPER_EFFECTIVE_ONE
    end
    return super
  end
end

#===============================================================================
# Poisons the target. This move becomes physical or special, whichever will deal
# more damage (only considers stats, stat stages and Wonder Room). Makes contact
# if it is a physical move. Has a different animation depending on the move's
# category. (Shell Side Arm)
#===============================================================================
class Battle::Move::CategoryDependsOnHigherDamagePoisonTarget < Battle::Move::PoisonTarget
  def initialize(battle, move)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType = nil); return (@calcCategory == 0); end
  def specialMove?(thisType = nil);  return (@calcCategory == 1); end
  def contactMove?;                  return physicalMove?;        end

  def pbOnStartUse(user, targets)
    target = targets[0]
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8, 9]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2, 2]
    # Calculate user's effective attacking values
    attack_stage         = user.modifiedStages[:ATTACK] + 6
    real_attack          = (user.attack.to_f * stageMul[attack_stage] / stageDiv[attack_stage]).floor
    special_attack_stage = user.modifiedStages[:SPECIAL_ATTACK] + 6
    real_special_attack  = (user.spatk.to_f * stageMul[special_attack_stage] / stageDiv[special_attack_stage]).floor
    # Calculate target's effective defending values
    defense_stage         = target.modifiedStages[:DEFENSE] + 6
    real_defense          = (target.defense.to_f * stageMul[defense_stage] / stageDiv[defense_stage]).floor
    special_defense_stage = target.modifiedStages[:SPECIAL_DEFENSE] + 6
    real_special_defense  = (target.spdef.to_f * stageMul[special_defense_stage] / stageDiv[special_defense_stage]).floor
    # Perform simple damage calculation
    physical_damage = real_attack.to_f / real_defense
    special_damage = real_special_attack.to_f / real_special_defense
    # Determine move's category
    if physical_damage == special_damage
      @calcCategry = @battle.pbRandom(2)
    else
      @calcCategory = (physical_damage > special_damage) ? 0 : 1
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if physicalMove?
    super
  end
end

#===============================================================================
# Ignores all abilities that alter this move's success or damage. This move is
# physical if user's Attack is higher than its Special Attack (after applying
# stat stages), and special otherwise. (Photon Geyser)
#===============================================================================
class Battle::Move::CategoryDependsOnHigherDamageIgnoreTargetAbility < Battle::Move::IgnoreTargetAbility
  def initialize(battle, move)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType = nil); return (@calcCategory == 0); end
  def specialMove?(thisType = nil);  return (@calcCategory == 1); end

  def pbOnStartUse(user, targets)
    # Calculate user's effective attacking value
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8, 9]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2, 2]
    atk        = user.attack
    atkStage   = user.modifiedStages[:ATTACK] + 6
    realAtk    = (atk.to_f * stageMul[atkStage] / stageDiv[atkStage]).floor
    spAtk      = user.spatk
    spAtkStage = user.modifiedStages[:SPECIAL_ATTACK] + 6
    realSpAtk  = (spAtk.to_f * stageMul[spAtkStage] / stageDiv[spAtkStage]).floor
    # Determine move's category
    @calcCategory = (realAtk > realSpAtk) ? 0 : 1
  end
end

#===============================================================================
# The user's Defense (and its Defense stat stages) are used instead of the
# user's Attack (and Attack stat stages) to calculate damage. All other effects
# are applied normally, applying the user's Attack modifiers and not the user's
# Defence modifiers. (Body Press)
#===============================================================================
class Battle::Move::UseUserBaseDefenseInsteadOfUserBaseAttack < Battle::Move
  def pbGetAttackStats(user, target)
    return user.defense, user.modifiedStages[:DEFENSE] + 6
  end
end

#===============================================================================
# Target's Attack is used instead of user's Attack for this move's calculations.
# (Foul Play)
#===============================================================================
class Battle::Move::UseTargetAttackInsteadOfUserAttack < Battle::Move
  def pbGetAttackStats(user, target)
    if pbSpecialMove?(user)
      return target.spatk, target.modifiedStages[:SPECIAL_ATTACK] + 6
    end
    return target.attack, target.modifiedStages[:ATTACK] + 6
  end
end

#===============================================================================
# Target's Defense is used instead of its Special Defense for this move's
# calculations. (Psyshock, Psystrike, Secret Sword, Star Shock)
#===============================================================================
class Battle::Move::UseTargetDefenseInsteadOfTargetSpDef < Battle::Move
  def pbGetDefenseStats(user, target)
    return target.defense, target.modifiedStages[:DEFENSE] + 6
  end
end

#===============================================================================
# Target's Special Defense is used instead of its Defense for this move's
# calculations. (Arcane Strike, Throw Hands)
#===============================================================================
class Battle::Move::UseTargetSpDefInsteadOfTargetDefense < Battle::Move
  def pbGetDefenseStats(user, target)
    return target.spdef, target.modifiedStages[:SPECIAL_DEFENSE] + 6
  end
end

#===============================================================================
# User's attack next round against the target will definitely hit.
# (Lock-On, Mind Reader)
#===============================================================================
class Battle::Move::EnsureNextMoveAlwaysHits < Battle::Move
  def pbEffectAgainstTarget(user, target)
    user.effects[PBEffects::LockOn]    = 2
    user.effects[PBEffects::LockOnPos] = target.index
    user.effects[PBEffects::LockOnMove] = @id
    @battle.pbDisplay(_INTL("{1} took aim at {2}!", user.pbThis, target.pbThis(true)))
  end
end

#===============================================================================
# User's allies' attacks next round against the target will definitely hit.
# (Beacon Recon)
#===============================================================================
class Battle::Move::EnsureNextMovesFromAlliesAlwaysHits < Battle::Move
  def pbMoveFailed?(user, targets)
    if user.allAllies.empty?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    user.allAllies.each do |b|
      b.effects[PBEffects::LockOn]    = 2
      b.effects[PBEffects::LockOnPos] = target.index
      b.effects[PBEffects::LockOnMove] = @id
    end
    @battle.pbDisplay(_INTL("{1} helped its allies take aim at {2}!", user.pbThis, target.pbThis(true)))
  end
end

#===============================================================================
# Target's evasion stat changes are ignored from now on. (Foresight, Odor Sleuth)
# Normal and Fighting moves have normal effectiveness against the Ghost-type target.
#===============================================================================
class Battle::Move::StartNegateTargetEvasionStatStageAndGhostImmunity < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Foresight] = true
    @battle.pbDisplay(_INTL("{1} was identified!", target.pbThis))
  end
end

#===============================================================================
# Target's evasion stat changes are ignored from now on. (Miracle Eye)
# Psychic moves have normal effectiveness against the Dark-type target.
#===============================================================================
class Battle::Move::StartNegateTargetEvasionStatStageAndDarkImmunity < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::MiracleEye] = true
    @battle.pbDisplay(_INTL("{1} was identified!", target.pbThis))
  end
end

#===============================================================================
# This move ignores target's Defense, Special Defense and evasion stat changes.
# (Chip Away, Darkest Lariat, Sacred Sword)
#===============================================================================
class Battle::Move::IgnoreTargetDefSpDefEvaStatStages < Battle::Move
  def pbCalcAccuracyMultipliers(user, target, multipliers)
    super
    modifiers[:evasion_stage] = 0
  end

  def pbGetDefenseStats(user, target)
    ret1, _ret2 = super
    return ret1, 6   # Def/SpDef stat stage
  end
end

#===============================================================================
# This move's type is the same as the user's first type. (Revelation Dance)
#===============================================================================
class Battle::Move::TypeIsUserFirstType < Battle::Move
  def pbBaseType(user)
    userTypes = user.pbTypes(true)
    return userTypes[0] || @type
  end
end

#===============================================================================
# Power and type depends on the user's IVs. (Hidden Power)
#===============================================================================
class Battle::Move::TypeDependsOnUserIVs < Battle::Move
  def pbBaseType(user)
    hp = pbHiddenPower(user.pokemon)
    return hp[0]
  end

  def pbBaseDamage(baseDmg, user, target)
    return super if Settings::MECHANICS_GENERATION >= 6
    hp = pbHiddenPower(user.pokemon)
    return hp[1]
  end
end

# NOTE: This allows Hidden Power to be Fairy-type (if you have that type in your
#       game). I don't care that the official games don't work like that.
def pbHiddenPower(pkmn)
  iv = pkmn.iv
  idxType = 0
  power = 60
  types = []
  GameData::Type.each do |t|
    types[t.icon_position] ||= []
    types[t.icon_position].push(t.id) if !t.pseudo_type && ![:NORMAL, :SHADOW].include?(t.id)
  end
  types.flatten!.compact!
  idxType |= (iv[:HP] & 1)
  idxType |= (iv[:ATTACK] & 1) << 1
  idxType |= (iv[:DEFENSE] & 1) << 2
  idxType |= (iv[:SPEED] & 1) << 3
  idxType |= (iv[:SPECIAL_ATTACK] & 1) << 4
  idxType |= (iv[:SPECIAL_DEFENSE] & 1) << 5
  idxType = (types.length - 1) * idxType / 63
  type = types[idxType]
  # Use typology to determine type
  type = pkmn.typology.damage_boost_type
  if Settings::MECHANICS_GENERATION <= 5
    powerMin = 30
    powerMax = 70
    power |= (iv[:HP] & 2) >> 1
    power |= (iv[:ATTACK] & 2)
    power |= (iv[:DEFENSE] & 2) << 1
    power |= (iv[:SPEED] & 2) << 2
    power |= (iv[:SPECIAL_ATTACK] & 2) << 3
    power |= (iv[:SPECIAL_DEFENSE] & 2) << 4
    power = powerMin + ((powerMax - powerMin) * power / 63)
  end
  return [type, power]
end

#===============================================================================
# Power and type depend on the user's held berry. Destroys the berry.
# (Natural Gift)
#===============================================================================
class Battle::Move::TypeAndPowerDependOnUserBerry < Battle::Move
  def pbMoveFailed?(user, targets)
    # NOTE: Unnerve does not stop a Pokémon using this move.
    item = user.item
    if !item || !item.is_berry? || !user.itemActive? ||
       item.flags.none? { |f| f[/^NaturalGift_/i] }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  # NOTE: The AI calls this method via pbCalcType, and this method returns a
  #       type assuming user has an item even though it might not. Since the AI
  #       won't want to use this move if the user has no item, though, perhaps
  #       this is good enough.
  def pbBaseType(user)
    item = user.item
    ret = :NORMAL
    if item
      item.flags.each do |flag|
        next if !flag[/^NaturalGift_(\w+)_(?:\d+)$/i]
        typ = $~[1].to_sym
        ret = typ if GameData::Type.exists?(typ)
        break
      end
    end
    return ret
  end

  # This is a separate method so that the AI can use it as well
  def pbNaturalGiftBaseDamage(heldItem)
    if heldItem
      GameData::Item.get(heldItem).flags.each do |flag|
        return [$~[1].to_i, 10].max if flag[/^NaturalGift_(?:\w+)_(\d+)$/i]
      end
    end
    return 1
  end

  def pbBaseDamage(baseDmg, user, target)
    return pbNaturalGiftBaseDamage(user.item.id)
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    # NOTE: The item is consumed even if this move was Protected against or it
    #       missed. The item is not consumed if the target was switched out by
    #       an effect like a target's Red Card.
    # NOTE: There is no item consumption animation.
    user.pbConsumeItem(true, true, false) if user.item
  end
end

#===============================================================================
# Type depends on the user's held Plate. (Judgment)
#===============================================================================
class Battle::Move::TypeDependsOnUserPlate < Battle::Move
  def initialize(battle, move)
    super
    @itemTypes = {
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
  end

  def pbBaseType(user)
    ret = :NORMAL
    if user.itemActive?
      @itemTypes.each do |item, itemType|
        next if user.item != item
        ret = itemType if GameData::Type.exists?(itemType)
        break
      end
    end
    return ret
  end
end

#===============================================================================
# Type depends on the user's held Memory. (Multi-Attack)
#===============================================================================
class Battle::Move::TypeDependsOnUserMemory < Battle::Move
  def initialize(battle, move)
    super
    @itemTypes = {
      :FIGHTINGMEMORY => :FIGHTING,
      :FLYINGMEMORY   => :FLYING,
      :POISONMEMORY   => :POISON,
      :GROUNDMEMORY   => :GROUND,
      :ROCKMEMORY     => :ROCK,
      :BUGMEMORY      => :BUG,
      :GHOSTMEMORY    => :GHOST,
      :STEELMEMORY    => :STEEL,
      :FIREMEMORY     => :FIRE,
      :WATERMEMORY    => :WATER,
      :GRASSMEMORY    => :GRASS,
      :ELECTRICMEMORY => :ELECTRIC,
      :PSYCHICMEMORY  => :PSYCHIC,
      :ICEMEMORY      => :ICE,
      :DRAGONMEMORY   => :DRAGON,
      :DARKMEMORY     => :DARK,
      :FAIRYMEMORY    => :FAIRY
    }
  end

  def pbBaseType(user)
    ret = :NORMAL
    if user.itemActive?
      @itemTypes.each do |item, itemType|
        next if user.item != item
        ret = itemType if GameData::Type.exists?(itemType)
        break
      end
    end
    return ret
  end
end

#===============================================================================
# Type depends on the user's held Drive. (Techno Blast)
#===============================================================================
class Battle::Move::TypeDependsOnUserDrive < Battle::Move
  def initialize(battle, move)
    super
    @itemTypes = {
      :SHOCKDRIVE => :ELECTRIC,
      :BURNDRIVE  => :FIRE,
      :CHILLDRIVE => :ICE,
      :DOUSEDRIVE => :WATER
    }
  end

  def pbBaseType(user)
    ret = :NORMAL
    if user.itemActive?
      @itemTypes.each do |item, itemType|
        next if user.item != item
        ret = itemType if GameData::Type.exists?(itemType)
        break
      end
    end
    return ret
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    t = pbBaseType(user)
    hitNum = 0
    hitNum = 1 if t == :ELECTRIC
    hitNum = 2 if t == :FIRE
    hitNum = 3 if t == :ICE
    hitNum = 4 if t == :WATER
    super
  end
end

#===============================================================================
# Increases the user's Speed by 1 stage. This move's type depends on the user's
# form (Electric if Full Belly, Dark if Hangry). Fails if the user is not
# Morpeko (works if transformed into Morpeko). (Aura Wheel)
#===============================================================================
class Battle::Move::TypeDependsOnUserMorpekoFormRaiseUserSpeed1 < Battle::Move::RaiseUserSpeed1
  def pbMoveFailed?(user, targets)
    if !user.isSpecies?(:MORPEKO) && user.effects[PBEffects::TransformSpecies] != :MORPEKO
      @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis))
      return true
    end
    return false
  end

  def pbBaseType(user)
    return :DARK if user.form == 1 && GameData::Type.exists?(:DARK)
    return @type
  end
end

#===============================================================================
# Power is doubled in weather. Type changes depending on the weather. (Weather Ball)
#===============================================================================
class Battle::Move::TypeAndPowerDependOnWeather < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if user.effectiveWeather != :None
    return baseDmg
  end

  def pbBaseType(user)
    ret = :NORMAL
    case user.effectiveWeather
    when :Sun, :HarshSun, :Firestorm
      ret = :FIRE if GameData::Type.exists?(:FIRE)
    when :Rain, :HeavyRain, :Thunderstorm
      ret = :WATER if GameData::Type.exists?(:WATER)
    when :Sandstorm
      ret = :ROCK if GameData::Type.exists?(:ROCK)
    when :Hail
      ret = :ICE if GameData::Type.exists?(:ICE)
    end
    return ret
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    t = pbBaseType(user)
    hitNum = 1 if t == :FIRE   # Type-specific anims
    hitNum = 2 if t == :WATER
    hitNum = 3 if t == :ROCK
    hitNum = 4 if t == :ICE
    super
  end
end

#===============================================================================
# Power is doubled if a terrain applies and user is grounded; also, this move's
# type and animation depends on the terrain. (Terrain Pulse)
#===============================================================================
class Battle::Move::TypeAndPowerDependOnTerrain < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if @battle.field.terrain != :None && user.affectedByTerrain?
    return baseDmg
  end

  def pbBaseType(user)
    ret = :NORMAL
    case @battle.field.terrain
    when :Electric
      ret = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
    when :Grassy
      ret = :GRASS if GameData::Type.exists?(:GRASS)
    when :Misty
      ret = :FAIRY if GameData::Type.exists?(:FAIRY)
    when :Psychic
      ret = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
    when :Lava
      ret = :FIRE
    when :Crystal
      ret = :CRYSTAL
    when :Icy
      ret = :ICE
    end
    return ret
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    t = pbBaseType(user)
    hitNum = 1 if t == :ELECTRIC   # Type-specific anims
    hitNum = 2 if t == :GRASS
    hitNum = 3 if t == :FAIRY
    hitNum = 4 if t == :PSYCHIC
    super
  end
end

#===============================================================================
# Target's moves become Electric-type for the rest of the round. (Electrify)
#===============================================================================
class Battle::Move::TargetMovesBecomeElectric < Battle::Move
  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Electrify]
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Electrify] = true
    @battle.pbDisplay(_INTL("{1}'s moves have been electrified!", target.pbThis))
  end
end

#===============================================================================
# All Normal-type moves become Electric-type for the rest of the round.
# (Ion Deluge, Plasma Fists)
#===============================================================================
class Battle::Move::NormalMovesBecomeElectric < Battle::Move
  def pbMoveFailed?(user, targets)
    return false if damagingMove?
    if @battle.field.effects[PBEffects::IonDeluge]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedLastInRound?(user)
    return false
  end

  def pbEffectGeneral(user)
    return if @battle.field.effects[PBEffects::IonDeluge]
    @battle.field.effects[PBEffects::IonDeluge] = true
    @battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
  end
end

#===============================================================================
# For 5 rounds, the types of all moves become randomized. (Mystery Shroud)
#===============================================================================
class Battle::Move::StartRandomTypeMoves < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.effects[PBEffects::MysteryShroud] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::MysteryShroud] = 5
    @battle.pbDisplay(_INTL("A chaotic mist descends on the battlefield!"))
  end
end

#===============================================================================
# For 5 rounds, boost Mystic, Ghost, and Dark-type moves by 50% and weaken
# Fairy, Light, and Psychic-type moves by 50%. (Ritual)
#===============================================================================
class Battle::Move::StartBoostMysticGhostDarkWeakenFairyLightPsychic < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.field.effects[PBEffects::Ritual] > 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.field.effects[PBEffects::Ritual] = 5
    @battle.pbDisplay(_INTL("{1} began a dark ritual!", user.pbThis))
  end
end

#===============================================================================
# Sound Pulse
#===============================================================================
class Battle::Move::DoublePowerIfTargetEvasionAtLeastOne < Battle::Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if target.modifiedStages[:EVASION] >= 1
    return baseDmg
  end
end

#===============================================================================
# Noise Ripple
#===============================================================================
class Battle::Move::EffectivenessIncludesWaterType < Battle::Move
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = super(moveType,defType,user,target)
    waterEff = Effectiveness.calculate_one(:WATER, defType)
    ret *= waterEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
    return ret
  end
end

#===============================================================================
# Ring Through
#===============================================================================
class Battle::Move::PowerDependsOnTargetDefenseStats < Battle::Move
  def pbBaseDamage(baseDmg,user,target)
    if target.defense > target.spdef
      return target.defense
    else
      return target.spdef
    end
  end
end

#===============================================================================
# Boil
#===============================================================================
class Battle::Move::DoublePowerIfTargetIsBurnedNoSubstitute < Battle::Move
  def pbBaseDamage(baseDmg,user,target)
    if target.burned? && (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end
end