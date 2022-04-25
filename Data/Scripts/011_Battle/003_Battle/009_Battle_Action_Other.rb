class PokeBattle_Battle
  #=============================================================================
  # Shifting a battler to another position in a battle larger than double
  #=============================================================================
  def pbCanShift?(idxBattler)
    return false if pbSideSize(0)<=2 && pbSideSize(1)<=2   # Double battle or smaller
    idxOther = -1
    case pbSideSize(idxBattler)
    when 1
      return false   # Only one battler on that side
    when 2
      idxOther = (idxBattler+2)%4
    when 3
      return false if idxBattler==2 || idxBattler==3   # In middle spot already
      idxOther = ((idxBattler%2)==0) ? 2 : 3
    end
    return false if pbGetOwnerIndexFromBattlerIndex(idxBattler)!=pbGetOwnerIndexFromBattlerIndex(idxOther)
    return true
  end

  def pbRegisterShift(idxBattler)
    @choices[idxBattler][0] = :Shift
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = nil
    return true
  end

  #=============================================================================
  # Calling at a battler
  #=============================================================================
  def pbRegisterCall(idxBattler)
    @choices[idxBattler][0] = :Call
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = nil
    return true
  end

  def pbCall(idxBattler)
    battler = @battlers[idxBattler]
    trainerName = pbGetOwnerName(idxBattler)
    pbDisplay(_INTL("{1} called {2}!",trainerName,battler.pbThis(true)))
    pbDisplay(_INTL("{1}!",battler.name))
    if battler.shadowPokemon?
      if battler.inHyperMode?
        battler.pokemon.hyper_mode = false
        battler.pokemon.adjustHeart(-300)
        pbDisplay(_INTL("{1} came to its senses from the Trainer's call!",battler.pbThis))
      else
        pbDisplay(_INTL("But nothing happened!"))
      end
    elsif battler.status == :SLEEP
      battler.pbCureStatus
    elsif battler.pbCanRaiseStatStage?(:ACCURACY,battler)
      battler.pbRaiseStatStage(:ACCURACY,1,battler)
    else
      pbDisplay(_INTL("But nothing happened!"))
    end
  end

  #=============================================================================
  # Choosing to Mega Evolve a battler
  #=============================================================================
  def pbHasMegaRing?(idxBattler)
    return true if !pbOwnedByPlayer?(idxBattler)   # Assume AI trainer have a ring
    Settings::MEGA_RINGS.each { |item| return true if $PokemonBag.pbHasItem?(item) }
    return false
  end

  def pbGetMegaRingName(idxBattler)
    if pbOwnedByPlayer?(idxBattler)
      Settings::MEGA_RINGS.each do |item|
        return GameData::Item.get(item).name if $PokemonBag.pbHasItem?(item)
      end
    end
    # NOTE: Add your own Mega objects for particular NPC trainers here.
#    if pbGetOwnerFromBattlerIndex(idxBattler).trainer_type == :BUGCATCHER
#      return _INTL("Mega Net")
#    end
    return _INTL("Mega Ring")
  end

  def pbCanMegaEvolve?(idxBattler)
    return false if $game_switches[Settings::NO_MEGA_EVOLUTION]
    return false if !@battlers[idxBattler].hasMega?
    return false if wildBattle? && opposes?(idxBattler)
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false if @battlers[idxBattler].effects[PBEffects::SkyDrop]>=0
    return false if !pbHasMegaRing?(idxBattler)
    return false if pbCheckGlobalAbility(:NEGATION) && !pbCheckGlobalAbility(:CRYSTALENERGY)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner]==-1
  end

  def pbRegisterMegaEvolution(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = idxBattler
  end

  def pbUnregisterMegaEvolution(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = -1 if @megaEvolution[side][owner]==idxBattler
  end

  def pbToggleRegisteredMegaEvolution(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @megaEvolution[side][owner]==idxBattler
      @megaEvolution[side][owner] = -1
    else
      @megaEvolution[side][owner] = idxBattler
    end
  end

  def pbRegisteredMegaEvolution?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner]==idxBattler
  end

  #=============================================================================
  # Mega Evolving a battler
  #=============================================================================
  def pbMegaEvolve(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasMega? || battler.mega?
    return if pbCheckGlobalAbility(:NEGATION) && !pbCheckGlobalAbility(:CRYSTALENERGY)
    trainerName = pbGetOwnerName(idxBattler)
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    # Mega Evolve
    case battler.pokemon.megaMessage
    when 1   # Rayquaza
      pbDisplay(_INTL("{1}'s fervent wish has reached {2}!",trainerName,battler.pbThis))
    else
      pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!",
         battler.pbThis,battler.itemName,trainerName,pbGetMegaRingName(idxBattler)))
    end
    pbCommonAnimation("MegaEvolution",battler)
    battler.pokemon.makeMega

    # In case of Equalizers, message displayed is different and Pokémon doesn't change visually:
    if (battler.pokemon.hasItem?(:EQUALIZERM))
      battler.pbUpdate(true)
      pbCommonAnimation("MegaEvolution2",battler)
      pbDisplay(_INTL("{1} has acquired the power of Mega Evolution!",battler.pbThis))
      side  = battler.idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      @megaEvolution[side][owner] = -2
      pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
      return
    end

    # Regular mega-evolution:
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation("MegaEvolution2",battler)
    megaName = battler.pokemon.megaName
    megaName = _INTL("Mega {1}", battler.pokemon.speciesName) if nil_or_empty?(megaName)
    pbDisplay(_INTL("{1} has Mega Evolved into {2}!",battler.pbThis,megaName))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = -2
    if battler.isSpecies?(:GENGAR) && battler.mega?
      battler.effects[PBEffects::Telekinesis] = 0
    end
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
    # Trigger ability
    battler.pbEffectsOnSwitchIn
  end

  #=============================================================================
  # Un-Mega-Evolving a battler
  #=============================================================================
  def pbUnMegaEvolve(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.mega?
    trainerName = pbGetOwnerName(idxBattler)
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    pbCommonAnimation("MegaEvolution",battler)
    battler.pokemon.makeUnmega

    if !battler.pokemon.hasItem?(:EQUALIZERM)
      battler.form = battler.pokemon.form
      battler.pbUpdate(true)
      @scene.pbChangePokemon(battler,battler.pokemon)
      @scene.pbRefreshOne(idxBattler)
    end
    
    pbCommonAnimation("MegaEvolution2",battler)
    pbDisplay(_INTL("{1} has reverted to its base form!",battler.pbThis))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
  end

  #=============================================================================
  # Choosing to Crystallize a battler
  #=============================================================================
  def pbHasCrystalData?(idxBattler)
    return true if !pbOwnedByPlayer?(idxBattler)   # Assume AI trainer has the crystal data
    # TODO: Implement crystal recorder data
    return true
    # return false
  end

  def pbCanCrystallize?(idxBattler)
    return false if $game_switches[Settings::NO_MEGA_EVOLUTION]
    return false if !@battlers[idxBattler].hasCrystal?
    return false if wildBattle? && opposes?(idxBattler)
    return true if $DEBUG && Input.press?(Input::CTRL)
    return true if pbCheckGlobalAbility(:CRYSTALENERGY)
    return false if @battlers[idxBattler].effects[PBEffects::SkyDrop]>=0
    return false if !pbHasCrystalData?(idxBattler)
    return false if pbCheckGlobalAbility(:NEGATION)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @crystallization[side][owner]==-1
  end

  def pbRegisterCrystallization(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @crystallization[side][owner] = idxBattler
  end

  def pbUnregisterCrystallization(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @crystallization[side][owner] = -1 if @crystallization[side][owner]==idxBattler
  end

  def pbToggleRegisteredCrystallization(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @crystallization[side][owner]==idxBattler
      @crystallization[side][owner] = -1
    else
      @crystallization[side][owner] = idxBattler
    end
  end

  def pbRegisteredCrystallization?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @crystallization[side][owner]==idxBattler
  end

  #=============================================================================
  # Crystallizing a battler
  #=============================================================================
  def pbCrystallize(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasCrystal? || battler.crystal?
    return if pbCheckGlobalAbility(:NEGATION) && !pbCheckGlobalAbility(:CRYSTALENERGY)
    trainerName = pbGetOwnerName(idxBattler)
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    # Crystallize
    case battler.pokemon.megaMessage
    when 1   # Rayquaza
      pbDisplay(_INTL("{1}'s fervent wish has reached {2}!",trainerName,battler.pbThis))
    else
      pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s crystal data!",
         battler.pbThis,battler.itemName,trainerName))
    end
    pbCommonAnimation("MegaEvolution",battler)
    battler.pokemon.makeCrystal

    # In case of Equalizers, message displayed is different and Pokémon doesn't change visually:
    if (battler.pokemon.hasItem?(:EQUALIZERC))
      battler.pbUpdate(true)
      pbCommonAnimation("MegaEvolution2",battler)
      pbDisplay(_INTL("{1} has acquired the power of Crystallization!",battler.pbThis))
      side  = battler.idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      @crystallization[side][owner] = -2
      @powerWithin[battler.index&1][battler.pokemonIndex] = 4 if battler.ability == :POWERWITHIN
      pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
      return
    end

    # Regular Crystallization
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation("MegaEvolution2",battler)
    megaName = battler.pokemon.megaName
    megaName = _INTL("Crystal {1}", battler.pokemon.speciesName) if nil_or_empty?(megaName)
    pbDisplay(_INTL("{1} has Crystallized into {2}!",battler.pbThis,megaName))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @crystallization[side][owner] = -2
    @powerWithin[battler.index&1][battler.pokemonIndex] = 4 if battler.ability == :POWERWITHIN
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
    # Trigger ability
    battler.pbEffectsOnSwitchIn
  end

  def pbCrystallizeWithoutItemCheck(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasCrystalWithoutItemCheck? || battler.crystal?
    return if pbCheckGlobalAbility(:NEGATION) && !pbCheckGlobalAbility(:CRYSTALENERGY)
    trainerName = pbGetOwnerName(idxBattler)
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    # Crystallize
    case battler.pokemon.megaMessage
    when 1   # Rayquaza
      pbDisplay(_INTL("{1}'s fervent wish has reached {2}!",trainerName,battler.pbThis))
    else
      pbDisplay(_INTL("{1} is crystallizing!", battler.pbThis))
    end
    pbCommonAnimation("MegaEvolution",battler)
    battler.pokemon.makeCrystalWithoutItemCheck
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation("MegaEvolution2",battler)
    megaName = battler.pokemon.megaName
    megaName = _INTL("Crystal {1}", battler.pokemon.speciesName) if nil_or_empty?(megaName)
    pbDisplay(_INTL("{1} has Crystallized into {2}!",battler.pbThis,megaName))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @crystallization[side][owner] = -2
    @powerWithin[battler.index&1][battler.pokemonIndex] = 4 if battler.ability == :POWERWITHIN
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
    # Trigger ability
    battler.pbEffectsOnSwitchIn
  end

  #=============================================================================
  # Uncrystallizing a battler
  #=============================================================================
  def pbUnCrystallize(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.crystal?
    return if pbCheckGlobalAbility(:CRYSTALENERGY)
    trainerName = pbGetOwnerName(idxBattler)
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    pbCommonAnimation("MegaEvolution",battler)
    battler.pokemon.makeUncrystal

    if !battler.pokemon.hasItem?(:EQUALIZERC)
      battler.form = battler.pokemon.form
      battler.pbUpdate(true)
      @scene.pbChangePokemon(battler,battler.pokemon)
      @scene.pbRefreshOne(idxBattler)
    end

    pbCommonAnimation("MegaEvolution2",battler)
    pbDisplay(_INTL("{1} has reverted to its base form!",battler.pbThis))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @powerWithin[battler.index&1][battler.pokemonIndex] = -1
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
  end

  #=============================================================================
  # Primal Reverting a battler
  #=============================================================================
  def pbPrimalReversion(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasPrimal? || battler.primal?
    return if pbCheckGlobalAbility(:NEGATION) && !pbCheckGlobalAbility(:CRYSTALENERGY)
    if battler.isSpecies?(:KYOGRE)
      pbCommonAnimation("PrimalKyogre",battler)
    elsif battler.isSpecies?(:GROUDON)
      pbCommonAnimation("PrimalGroudon",battler)
    end
    battler.pokemon.makePrimal
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    if battler.isSpecies?(:KYOGRE)
      pbCommonAnimation("PrimalKyogre2",battler)
    elsif battler.isSpecies?(:GROUDON)
      pbCommonAnimation("PrimalGroudon2",battler)
    end
    pbDisplay(_INTL("{1}'s Primal Reversion!\nIt reverted to its primal form!",battler.pbThis))
  end

  #=============================================================================
  # Primal Un-Reverting a battler
  #=============================================================================
  def pbPrimalUnReversion(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.primal?
    if battler.isSpecies?(:KYOGRE)
      pbCommonAnimation("PrimalKyogre",battler)
    elsif battler.isSpecies?(:GROUDON)
      pbCommonAnimation("PrimalGroudon",battler)
    end
    battler.pokemon.makeUnprimal
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    if battler.isSpecies?(:KYOGRE)
      pbCommonAnimation("PrimalKyogre2",battler)
    elsif battler.isSpecies?(:GROUDON)
      pbCommonAnimation("PrimalGroudon2",battler)
    end
    pbDisplay(_INTL("{1} went back to its regular form!",battler.pbThis))
  end
end
