class Battle::Battler
  #=============================================================================
  # Ability trigger checks
  #=============================================================================
  def pbAbilitiesOnSwitchOut
    if abilityActive?
      Battle::AbilityEffects.triggerOnSwitchOut(self.ability, self, false)
    end
    # Phantitute with Proxy cannot pass Substitute with Baton Pass
    if isSpecies?(:PHANTITUTE) && self.ability == :PROXY
      @effects[PBEffects::Substitute] = 0
    end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle, @pokemon, @battle.usedInBattle[idxOwnSide][@index / 2])
    # Treat self as fainted
    @hp = 0
    @fainted = true
    # Check for end of Neutralizing Gas/Unnerve
    pbAbilitiesOnNeutralizingGasEnding if hasActiveAbility?(:NEUTRALIZINGGAS, true)
    pbItemsOnUnnerveEnding if hasActiveAbility?(:UNNERVE, true)
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Crystal Energy
    # Check if any other battler still has Crystal Energy active
    if self.ability == :CRYSTALENERGY && !@battle.pbCheckGlobalAbility(:CRYSTALENERGY)
      # Revert battlers on field
      @battle.allBattlers.each do |b|
        if b.crystal? || b.crystalEqualizer?
          @battle.pbUnCrystallize(b.index)
        end
      end
      # Revert player side Pokemon
      @battle.pbParty(0).each do |pkmn|
        pkmn.makeUncrystal
        pkmn.makeUnEqualizer
      end
      # Revert opponent side Pokemon
      @battle.pbParty(1).each do |pkmn|
        pkmn.makeUncrystal
        pkmn.makeUnEqualizer
      end
    end
  end

  def pbAbilitiesOnFainting
    # Self fainted; check all other battlers to see if their abilities trigger
    @battle.pbPriority(true).each do |b|
      next if !b || !b.abilityActive?
      Battle::AbilityEffects.triggerChangeOnBattlerFainting(b.ability, b, self, @battle)
    end
    @battle.pbPriority(true).each do |b|
      next if !b || !b.abilityActive?
      Battle::AbilityEffects.triggerOnBattlerFainting(b.ability, b, self, @battle)
    end
    pbAbilitiesOnNeutralizingGasEnding if hasActiveAbility?(:NEUTRALIZINGGAS, true)
    pbItemsOnUnnerveEnding if hasActiveAbility?(:UNNERVE, true)
    # Crystal Energy
    # Check if any other battler still has Crystal Energy active
    if self.ability == :CRYSTALENERGY && !@battle.pbCheckGlobalAbility(:CRYSTALENERGY)
      # Revert battlers on field
      @battle.allBattlers.each do |b|
        if b.crystal? || b.crystalEqualizer?
          @battle.pbUnCrystallize(b.index)
        end
      end
      # Revert player side Pokemon
      @battle.pbParty(0).each do |pkmn|
        pkmn.makeUncrystal
        pkmn.makeUnEqualizer
      end
      # Revert opponent side Pokemon
      @battle.pbParty(1).each do |pkmn|
        pkmn.makeUncrystal
        pkmn.makeUnEqualizer
      end
    end
  end

  # Used for Emergency Exit/Wimp Out. Returns whether self has switched out.
  def pbAbilitiesOnDamageTaken(move_user = nil)
    return false if !@droppedBelowHalfHP
    return false if !abilityActive?
    return Battle::AbilityEffects.triggerOnHPDroppedBelowHalf(self.ability, self, move_user, @battle)
  end

  def pbAbilityOnTerrainChange(ability_changed = false)
    return if !abilityActive?
    Battle::AbilityEffects.triggerOnTerrainChange(self.ability, self, @battle, ability_changed)
  end

  # Used for Rattled's Gen 8 effect. Called when Intimidate is triggered.
  def pbAbilitiesOnIntimidated
    return if !abilityActive?
    Battle::AbilityEffects.triggerOnIntimidated(self.ability, self, @battle)
  end

  def pbAbilitiesOnNeutralizingGasEnding
    return if @battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS)
    @battle.pbDisplay(_INTL("The effects of the neutralizing gas wore off!"))
    @battle.pbEndPrimordialWeather
    @battle.pbPriority(true).each do |b|
      next if b.fainted?
      next if !b.unstoppableAbility? && !b.abilityActive?
      Battle::AbilityEffects.triggerOnSwitchIn(b.ability, b, @battle)
    end
  end

  # Called when a Pokémon (self) enters battle, at the end of each move used,
  # and at the end of each round.
  def pbContinualAbilityChecks(onSwitchIn = false)
    # Crystal Energy switch in message
    if hasActiveAbility?(:CRYSTALENERGY) && onSwitchIn
      @battle.pbShowAbilitySplash(self)
      @battle.pbDisplay(_INTL("{1} is exuding a powerful crystal energy on the field!", self.pbThis))
      @battle.pbHideAbilitySplash(self)
    end
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Incomprehensible	
    if hasActiveAbility?(:INCOMPREHENSIBLE)	
      abilityList = []	
      GameData::Ability.each { |a|	
        next if ungainableAbility?(a.id) || a.id == self.ability ||
                [:POWEROFALCHEMY, :RECEIVER, :TRACE, :INCOMPREHENSIBLE].include?(a.id)	
        abilityList.push(a.id)	
      }	
      newAbil = abilityList[@battle.pbRandom(abilityList.length)]	
      @battle.pbShowAbilitySplash(self)	
      @battle.pbDisplay(_INTL("{1} gained the ability {2}!", pbThis, GameData::Ability.get(newAbil).name))	
      @battle.pbHideAbilitySplash(self)	
      self.ability = newAbil	
      # Lets this battler switch abilities every turn
      @effects[PBEffects::Incomprehensible] = true	
    end
    # Subtraction message for non-Subtraction users
    if onSwitchIn && !@battle.initialSwitchIn && @battle.pbCheckAllyAbility(:SUBTRACTION, @index) &&
      !hasActiveAbility?(:SUBTRACTION) && !@battle.pbCheckAllyAbility(:ADDITION, @index)
      subtractionCount = 0
      @battle.allSameSideBattlers(@index).each do |b|
        subtractionCount += 1 if b.hasActiveAbility?(:SUBTRACTION)
      end
      typeListString = @effects[PBEffects::SubtractionTypes][0...subtractionCount].join(", ")
      @battle.pbDisplay(_INTL("{1} lost its weakness(es) to the following type(s): {2}", pbThis, typeListString))
    end
    # Trace
    if hasActiveAbility?(:TRACE)
      # NOTE: In Gen 5 only, Trace only triggers upon the Trace bearer switching
      #       in and not at any later times, even if a traceable ability turns
      #       up later. Essentials ignores this, and allows Trace to trigger
      #       whenever it can even in Gen 5 battle mechanics.
      choices = @battle.allOtherSideBattlers(@index).select { |b|
        next !b.ungainableAbility? &&
             ![:POWEROFALCHEMY, :RECEIVER, :TRACE, :INCOMPREHENSIBLE].include?(b.ability_id)
      }
      if choices.length > 0
        choice = choices[@battle.pbRandom(choices.length)]
        @battle.pbShowAbilitySplash(self)
        self.ability = choice.ability
        @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!", pbThis, choice.pbThis(true), choice.abilityName))
        @battle.pbHideAbilitySplash(self)
        if !onSwitchIn && (unstoppableAbility? || abilityActive?)
          Battle::AbilityEffects.triggerOnSwitchIn(self.ability, self, @battle)
        end
      end
    end
    # Kindeshu's Effulge
    if isSpecies?(:KINDESHU) && self.ability == :EFFULGE
      threatened = self.hp <= self.totalhp / 4
      threatenedOpponent = nil
      self.eachOpposing do |b|
        next if b.hp > b.totalhp / 4
        threatenedOpponent = b
        break
      end
      if (threatened || threatenedOpponent != nil) && self.form == 0
        @battle.pbShowAbilitySplash(self)
        if threatened
          pbChangeForm(1, _INTL("{1} revealed its true form!", pbThis))
        else
          pbChangeForm(1, _INTL("{1} is ready to feed off of {2}'s light energy!", pbThis, threatenedOpponent.pbThis(true)))
        end
        @battle.pbHideAbilitySplash(self)
      elsif !threatened && threatenedOpponent.nil? && self.form == 1
        @battle.pbShowAbilitySplash(self)
        pbChangeForm(0, _INTL("{1} reverted to its base form.", pbThis))
        @battle.pbHideAbilitySplash(self)
      end
    end
    # Noctoa's Dark Duality
    if isSpecies?(:NOCTOA) && self.ability == :DARKDUALITY
      if PBDayNight.isNight? || @battle.field.effects[PBEffects::Darkened]
        if self.form == 0
          @battle.pbShowAbilitySplash(self)
          pbChangeForm(1, _INTL("{1} became possessed!", pbThis))
          @battle.pbHideAbilitySplash(self)
        end
      elsif self.form == 1
        @battle.pbShowAbilitySplash(self)
        pbChangeForm(0, _INTL("{1} turned back to normal.", pbThis))
        @battle.pbHideAbilitySplash(self)
      end
    end
    # Negation
    if hasActiveAbility?(:NEGATION) && !@battle.pbCheckGlobalAbility(:CRYSTALENERGY)
      # Revert battlers on field
      @battle.allBattlers.each do |b|
        next if b.index == self.index
        if b.mega? || b.megaEqualizer?
          @battle.pbUnMegaEvolve(b.index)
        elsif b.crystal? || b.crystalEqualizer?
          @battle.pbUnCrystallize(b.index)
        elsif b.primal?
          @battle.pbPrimalUnReversion(b.index)
        elsif b.isSpecies?(:GRENINJA) && b.form == 2
          @battle.battleBond[b.index&1][b.pokemonIndex] = false
          b.pbChangeForm(1,_INTL("{1} reverted to its base form.", b.pbThis))
        elsif b.isSpecies?(:KOSURITE) && b.form == 1
          b.pbChangeForm(0,_INTL("{1} reverted to its encased form.", b.pbThis))
        end
      end
      # Revert player side Pokemon
      @battle.pbParty(0).each do |pkmn|
        pkmn.makeUnmega
        pkmn.makeUncrystal
        pkmn.makeUnEqualizer
        pkmn.makeUnprimal
        if pkmn.isSpecies?(:GRENINJA) && pkmn.form == 2
          pkmn.form = 1
        elsif pkmn.isSpecies?(:KOSURITE) && pkmn.form == 1
          pkmn.form = 0
        end
      end
      # Revert opponent side Pokemon
      @battle.pbParty(1).each do |pkmn|
        pkmn.makeUnmega
        pkmn.makeUncrystal
        pkmn.makeUnEqualizer
        pkmn.makeUnprimal
        if pkmn.isSpecies?(:GRENINJA) && pkmn.form == 2
          pkmn.form = 1
        elsif pkmn.isSpecies?(:KOSURITE) && pkmn.form == 1
          pkmn.form = 0
        end
      end
    end
    # Crystal Energy
    if hasActiveAbility?(:CRYSTALENERGY)
      # Crystallize battlers on field
      @battle.allBattlers.each do |b|
        if (b.hasCrystalWithoutItemCheck? && !b.crystal?) || (b.item == :EQUALIZERC && !b.crystalEqualizer?)
          if b.mega? || b.megaEqualizer?
            side  = self.idxOwnSide
            owner = @battle.pbGetOwnerIndexFromBattlerIndex(b.index)
            @battle.pbUnMegaEvolve(b.index)
          end
          @battle.pbCrystallizeWithoutItemCheck(b.index)
        end
      end
      # Crystallize player side Pokemon
      @battle.pbParty(0).each_with_index do |pkmn, i|
        if (pkmn.hasCrystalFormWithoutItemCheck? && !pkmn.crystal?) || (pkmn.hasItem?(:EQUALIZERC) && !pkmn.crystalEqualizer?)
          if pkmn.mega? || pkmn.megaEqualizer?
            owner = @battle.pbGetOwnerIndexFromPartyIndex(0, i)
            pkmn.mega? ? pkmn.makeUnmega : pkmn.makeUnEqualizer
          end
          pkmn.makeCrystalWithoutItemCheck
        end
      end
      # Crystallize opponent side Pokemon
      @battle.pbParty(1).each_with_index do |pkmn, i|
        if (pkmn.hasCrystalFormWithoutItemCheck? && !pkmn.crystal?) || (pkmn.hasItem?(:EQUALIZERC) && !pkmn.crystalEqualizer?)
          if pkmn.mega? || pkmn.megaEqualizer?
            owner = @battle.pbGetOwnerIndexFromPartyIndex(1, i)
            pkmn.mega? ? pkmn.makeUnmega : pkmn.makeUnEqualizer
          end
          pkmn.makeCrystalWithoutItemCheck
        end
      end
    end
    # Berserker Bracelet
    # NOTE: This code assumes that there are no other effects (e.g. other items, abilities, or other thing)
    # that manipulate a Pokemon's total HP in battle. If any such effect is added, this will need to be modified
    # to take the new effect into account (and vice versa in the new effect code).
    if hasActiveItem?(:BERSERKERBRACELET)
      # Cut totalhp in half if not already done so.
      if @totalhp == @pokemon.totalhp
        @battle.pbDisplay(_INTL("{1} had its total HP cut in half by its {2}!", pbThis, itemName))
        # TODO: Add some kind of animation or visual effect for this
        # Example: Max HP indicator in Dark Souls 2
        if @hp > @pokemon.totalhp / 2
          pbReduceHP(@hp - @pokemon.totalhp / 2)
        end
        @totalhp = @pokemon.totalhp / 2
      end
    else
      # Restore totalhp if this battler previously had the Berserker Bracelet
      # but then lost it.
      if @totalhp != @pokemon.totalhp
        @battle.pbDisplay(_INTL("{1} had its total HP restored to normal.", pbThis))
        # TODO: Add some kind of animation or visual effect for this
        @totalhp = @pokemon.totalhp
      end
    end
  end

  #=============================================================================
  # Ability curing
  #=============================================================================
  # Cures status conditions, confusion and infatuation.
  def pbAbilityStatusCureCheck
    if abilityActive?
      Battle::AbilityEffects.triggerStatusCure(self.ability, self)
    end
  end

  #=============================================================================
  # Ability effects
  #=============================================================================
  # For abilities that grant immunity to moves of a particular type, and raises
  # one of the ability's bearer's stats instead.
  def pbMoveImmunityStatRaisingAbility(user, move, moveType, immuneType, stat, increment, show_message)
    return false if user.index == @index
    return false if moveType != immuneType
    # NOTE: If show_message is false (Dragon Darts only), the stat will not be
    #       raised. This is not how the official games work, but I'm considering
    #       that a bug because Dragon Darts won't be fired at self in the first
    #       place if it's immune, so why would this ability be triggered by them?
    if show_message
      @battle.pbShowAbilitySplash(self)
      if pbCanRaiseStatStage?(stat, self)
        if Battle::Scene::USE_ABILITY_SPLASH
          pbRaiseStatStage(stat, increment, self)
        else
          pbRaiseStatStageByCause(stat, increment, self, abilityName)
        end
      elsif Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!", pbThis, abilityName, move.name))
      end
      @battle.pbHideAbilitySplash(self)
    end
    return true
  end

  # For abilities that grant immunity to moves of a particular type, and heals
  # the ability's bearer by 1/4 of its total HP instead.
  def pbMoveImmunityHealingAbility(user, move, moveType, immuneType, show_message)
    return false if user.index == @index
    return false if moveType != immuneType
    # NOTE: If show_message is false (Dragon Darts only), HP will not be healed.
    #       This is not how the official games work, but I'm considering that a
    #       bug because Dragon Darts won't be fired at self in the first place
    #       if it's immune, so why would this ability be triggered by them?
    if show_message
      @battle.pbShowAbilitySplash(self)
      if canHeal? && pbRecoverHP(@totalhp / 4) > 0
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1}'s HP was restored.", pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.", pbThis, abilityName))
        end
      elsif Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("It doesn't affect {1}...", pbThis(true)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!", pbThis, abilityName, move.name))
      end
      @battle.pbHideAbilitySplash(self)
    end
    return true
  end

  #=============================================================================
  # Ability change
  #=============================================================================
  def pbOnLosingAbility(oldAbil, suppressed = false)
    if oldAbil == :NEUTRALIZINGGAS && (suppressed || !@effects[PBEffects::GastroAcid])
      pbAbilitiesOnNeutralizingGasEnding
    elsif oldAbil == :UNNERVE && (suppressed || !@effects[PBEffects::GastroAcid])
      pbItemsOnUnnerveEnding
    elsif oldAbil == :ILLUSION && @effects[PBEffects::Illusion]
      @effects[PBEffects::Illusion] = nil
      if !@effects[PBEffects::Transform]
        @battle.scene.pbChangePokemon(self, @pokemon)
        @battle.pbDisplay(_INTL("{1}'s {2} wore off!", pbThis, GameData::Ability.get(oldAbil).name))
        @battle.pbSetSeen(self)
      end
    end
    @effects[PBEffects::Incomprehensible] = false
    @effects[PBEffects::GastroAcid] = false if unstoppableAbility?
    @effects[PBEffects::SlowStart]  = 0 if self.ability != :SLOWSTART
    @effects[PBEffects::Truant]     = false if self.ability != :TRUANT
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Revert form if Flower Gift/Forecast was lost
    pbCheckFormOnWeatherChange(true)
    # Abilities that trigger when the terrain changes
    pbAbilityOnTerrainChange(true)
  end

  def pbTriggerAbilityOnGainingIt
    # Ending primordial weather, checking Trace
    pbContinualAbilityChecks(true)   # Don't trigger Traced ability as it's triggered below
    # Abilities that trigger upon switching in
    if (!fainted? && unstoppableAbility?) || abilityActive?
      Battle::AbilityEffects.triggerOnSwitchIn(self.ability, self, @battle)
    end
    # Status-curing ability check
    pbAbilityStatusCureCheck
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
  end

  #=============================================================================
  # Held item consuming/removing
  #=============================================================================
  def canConsumeBerry?
    return false if @battle.pbCheckOpposingAbility(:UNNERVE, @index)
    return true
  end

  def canConsumePinchBerry?(check_gluttony = true)
    return false if !canConsumeBerry?
    return true if @hp <= @totalhp / 4
    return true if @hp <= @totalhp / 2 && (!check_gluttony || hasActiveAbility?(:GLUTTONY))
    return false
  end

  # permanent is whether the item is lost even after battle. Is false for Knock
  # Off.
  def pbRemoveItem(permanent = true)
    @effects[PBEffects::ChoiceBand] = nil if !hasActiveAbility?(:GORILLATACTICS)
    @effects[PBEffects::Unburden]   = true if self.item && hasActiveAbility?(:UNBURDEN)
    setInitialItem(nil) if permanent && self.item == self.initialItem
    self.item = nil
  end

  def pbConsumeItem(recoverable = true, symbiosis = true, belch = true)
    PBDebug.log("[Item consumed] #{pbThis} consumed its held #{itemName}")
    if recoverable
      setRecycleItem(@item_id)
      @effects[PBEffects::PickupItem] = @item_id
      @effects[PBEffects::PickupUse]  = @battle.nextPickupUse
    end
    setBelched if belch && self.item.is_berry?
    pbRemoveItem
    pbSymbiosis if symbiosis
  end

  def pbSymbiosis
    return if fainted?
    return if self.item
    @battle.pbPriority(true).each do |b|
      next if b.opposes?(self)
      next if !b.hasActiveAbility?(:SYMBIOSIS)
      next if !b.item || b.unlosableItem?(b.item)
      next if unlosableItem?(b.item)
      @battle.pbShowAbilitySplash(b)
      if Battle::Scene::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} shared its {2} with {3}!",
                                b.pbThis, b.itemName, pbThis(true)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} let it share its {3} with {4}!",
                                b.pbThis, b.abilityName, b.itemName, pbThis(true)))
      end
      self.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true if b.hasActiveAbility?(:UNBURDEN)
      @battle.pbHideAbilitySplash(b)
      pbHeldItemTriggerCheck
      break
    end
  end

  # item_to_use is an item ID or GameData::Item object. own_item is whether the
  # item is held by self. fling is for Fling only.
  def pbHeldItemTriggered(item_to_use, own_item = true, fling = false)
    # Cheek Pouch
    if hasActiveAbility?(:CHEEKPOUCH) && GameData::Item.get(item_to_use).is_berry? && canHeal?
      @battle.pbShowAbilitySplash(self)
      heal_amt = pbRecoverHP(@totalhp / 3)
      if heal_amt > 0
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1}'s HP was restored.", pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.", pbThis, abilityName))
        end
      end
      @battle.pbHideAbilitySplash(self)
    end
    pbConsumeItem if own_item
    pbSymbiosis if !own_item && !fling   # Bug Bite/Pluck users trigger Symbiosis
  end

  #=============================================================================
  # Held item trigger checks
  #=============================================================================
  # NOTE: A Pokémon using Bug Bite/Pluck, and a Pokémon having an item thrown at
  #       it via Fling, will gain the effect of the item even if the Pokémon is
  #       affected by item-negating effects.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbHeldItemTriggerCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    pbItemHPHealCheck(item_to_use, fling)
    pbItemStatusCureCheck(item_to_use, fling)
    pbItemEndOfMoveCheck(item_to_use, fling)
    # For Enigma Berry, Kee Berry and Maranga Berry, which have their effects
    # when forcibly consumed by Pluck/Fling.
    if item_to_use
      itm = item_to_use || self.item
      if Battle::ItemEffects.triggerOnBeingHitPositiveBerry(itm, self, @battle, true)
        pbHeldItemTriggered(itm, false, fling)
      end
    end
  end

  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemHPHealCheck(item_to_use = nil, fling = false)
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if Battle::ItemEffects.triggerHPHeal(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    elsif !item_to_use
      pbItemTerrainStatBoostCheck
    end
  end

  # Cures status conditions, confusion, infatuation and the other effects cured
  # by Mental Herb.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemStatusCureCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if Battle::ItemEffects.triggerStatusCure(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    end
  end

  # Called at the end of using a move.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemEndOfMoveCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if Battle::ItemEffects.triggerOnEndOfUsingMove(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    elsif Battle::ItemEffects.triggerOnEndOfUsingMoveStatRestore(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    end
  end

  # Used for White Herb (restore lowered stats). Only called by Moody and Sticky
  # Web, as all other stat reduction happens because of/during move usage and
  # this handler is also called at the end of each move's usage.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemStatRestoreCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if Battle::ItemEffects.triggerOnEndOfUsingMoveStatRestore(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    end
  end

  # Called when the battle terrain changes and when a Pokémon loses HP.
  def pbItemTerrainStatBoostCheck
    return if !itemActive?
    if Battle::ItemEffects.triggerTerrainStatBoost(self.item, self, @battle)
      pbHeldItemTriggered(self.item)
    end
  end

  # Used for Adrenaline Orb. Called when Intimidate is triggered (even if
  # Intimidate has no effect on the Pokémon).
  def pbItemOnIntimidatedCheck
    return if !itemActive?
    if Battle::ItemEffects.triggerOnIntimidated(self.item, self, @battle)
      pbHeldItemTriggered(self.item)
    end
  end

  # Used for Retreat Order/Stench Doll. Returns whether self has switched out.
  def pbItemsOnDamageTaken(move_user = nil)
    return false if !itemActive?
    return Battle::ItemEffects.triggerOnDamageTaken(self.item, self, move_user, @battle)
  end

  # Used for Eject Pack. Returns whether self has switched out.
  def pbItemOnStatDropped(move_user = nil)
    return false if !@statsDropped
    return false if !itemActive?
    return Battle::ItemEffects.triggerOnStatLoss(self.item, self, move_user, @battle)
  end

  def pbItemsOnUnnerveEnding
    @battle.pbPriority(true).each do |b|
      b.pbHeldItemTriggerCheck if b.item&.is_berry?
    end
  end

  #=============================================================================
  # Item effects
  #=============================================================================
  def pbConfusionBerry(item_to_use, forced, flavor, confuse_msg)
    return false if !forced && !canHeal?
    return false if !forced && !canConsumePinchBerry?(Settings::MECHANICS_GENERATION >= 7)
    used_item_name = GameData::Item.get(item_to_use).name
    fraction_to_heal = 8   # Gens 6 and lower
    if Settings::MECHANICS_GENERATION == 7
      fraction_to_heal = 2
    elsif Settings::MECHANICS_GENERATION >= 8
      fraction_to_heal = 3
    end
    amt = @totalhp / fraction_to_heal
    ripening = false
    if hasActiveAbility?(:RIPEN)
      @battle.pbShowAbilitySplash(self, forced)
      amt *= 2
      ripening = true
    end
    @battle.pbCommonAnimation("EatBerry", self) if !forced
    @battle.pbHideAbilitySplash(self) if ripening
    amt = pbRecoverHP(amt)
    if amt > 0
      if forced
        PBDebug.log("[Item triggered] Forced consuming of #{used_item_name}")
        @battle.pbDisplay(_INTL("{1}'s HP was restored.", pbThis))
      else
        @battle.pbDisplay(_INTL("{1} restored its health using its {2}!", pbThis, used_item_name))
      end
    end
    flavor_stat = [:ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE][flavor]
    self.nature.stat_changes.each do |change|
      next if change[1] > 0 || change[0] != flavor_stat
      @battle.pbDisplay(confuse_msg)
      pbConfuse if pbCanConfuseSelf?(false)
      break
    end
    return true
  end

  def pbStatIncreasingBerry(item_to_use, forced, stat, increment = 1)
    return false if !forced && !canConsumePinchBerry?
    return false if !pbCanRaiseStatStage?(stat, self)
    used_item_name = GameData::Item.get(item_to_use).name
    ripening = false
    if hasActiveAbility?(:RIPEN)
      @battle.pbShowAbilitySplash(self, forced)
      increment *= 2
      ripening = true
    end
    @battle.pbCommonAnimation("EatBerry", self) if !forced
    @battle.pbHideAbilitySplash(self) if ripening
    return pbRaiseStatStageByCause(stat, increment, self, used_item_name) if !forced
    PBDebug.log("[Item triggered] Forced consuming of #{used_item_name}")
    return pbRaiseStatStage(stat, increment, self)
  end

  def pbMoveTypeWeakeningBerry(berry_type, move_type, mults)
    return if move_type != berry_type
    return if !Effectiveness.super_effective?(@damageState.typeMod) && move_type != :NORMAL
    mults[:final_damage_multiplier] /= 2
    @damageState.berryWeakened = true
    ripening = false
    if hasActiveAbility?(:RIPEN)
      @battle.pbShowAbilitySplash(self)
      mults[:final_damage_multiplier] /= 2
      ripening = true
    end
    @battle.pbCommonAnimation("EatBerry", self)
    @battle.pbHideAbilitySplash(self) if ripening
  end

  def pbMoveTypePoweringUpGem(gem_type, move, move_type, mults)
    return if move.is_a?(Battle::Move::PledgeMove)   # Pledge moves never consume Gems
    return if move_type != gem_type
    @effects[PBEffects::GemConsumed] = @item_id
    if Settings::MECHANICS_GENERATION >= 6
      mults[:base_damage_multiplier] *= 1.3
    else
      mults[:base_damage_multiplier] *= 1.5
    end
  end
end
