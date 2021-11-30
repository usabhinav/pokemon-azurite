class PokeBattle_Battler
  #=============================================================================
  # Increase stat stages
  #=============================================================================
  def statStageAtMax?(stat)
    return @stages[stat]>=6
  end

  def pbCanRaiseStatStage?(stat,user=nil,move=nil,showFailMsg=false,ignoreContrary=false)
    return false if fainted?
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbCanLowerStatStage?(stat,user,move,showFailMsg,true)
    end
	# Reversal Herb
	if hasActiveItem?(:REVERSALHERB) && !ignoreContrary && !@battle.moldBreaker
      return pbLowerStatStage?(stat,user,move,showFailMsg,true)
    end
    # Check the stat stage
    if statStageAtMax?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!",
         pbThis, GameData::Stat.get(stat).name)) if showFailMsg
      return false
    end
    return true
  end

  def pbRaiseStatStageBasic(stat,increment,ignoreContrary=false)
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbLowerStatStageBasic(stat,increment,true)
      end
	  # Reversal Herb
	  if hasActiveItem?(:REVERSALHERB) && !ignoreContrary
	    pbConsumeItem
        return pbLowerStatStageBasic(stat,increment,user,cause,showAnim,true)
      end
      # Simple
      increment *= 2 if hasActiveAbility?(:SIMPLE)
    end
    # Change the stat stage
    increment = [increment,6-@stages[stat]].min
    if increment>0
      stat_name = GameData::Stat.get(stat).name
      new = @stages[stat]+increment
      PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@stages[stat]} -> #{new} (+#{increment})")
      @stages[stat] += increment
    end
    return increment
  end

  def pbRaiseStatStage(stat,increment,user,showAnim=true,ignoreContrary=false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbLowerStatStage(stat,increment,user,showAnim,true)
    end
	# Reversal Herb
	if hasActiveItem?(:REVERSALHERB) && !ignoreContrary && !@battle.moldBreaker
	  @battle.pbDisplay(_INTL("{1}'s {2} reversed stat boosts!",self.pbThis,self.itemName))
	  pbConsumeItem
      return pbLowerStatStage(stat,increment,user,cause,showAnim,true)
    end
    # Perform the stat stage change
    increment = pbRaiseStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat up animation and message
    @battle.pbCommonAnimation("StatUp",self) if showAnim
    arrStatTexts = [
       _INTL("{1}'s {2} rose!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} rose sharply!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} rose drastically!",pbThis,GameData::Stat.get(stat).name)]
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat gain
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatGain(self.ability,self,stat,user)
    end
    return true
  end

  def pbRaiseStatStageByCause(stat,increment,user,cause,showAnim=true,ignoreContrary=false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbLowerStatStageByCause(stat,increment,user,cause,showAnim,true)
    end
	# Reversal Herb
	if hasActiveItem?(:REVERSALHERB) && !ignoreContrary && !@battle.moldBreaker
	  @battle.pbDisplay(_INTL("{1}'s {2} reversed stat boosts!",self.pbThis,self.itemName))
	  pbConsumeItem
      return pbLowerStatStageByCause(stat,increment,user,cause,showAnim,true)
    end
    # Perform the stat stage change
    increment = pbRaiseStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat up animation and message
    @battle.pbCommonAnimation("StatUp",self) if showAnim
    if user.index==@index
      arrStatTexts = [
         _INTL("{1}'s {2} raised its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} sharply raised its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} drastically raised its {3}!",pbThis,cause,GameData::Stat.get(stat).name)]
    else
      arrStatTexts = [
         _INTL("{1}'s {2} raised {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} sharply raised {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} drastically raised {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name)]
    end
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat gain
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatGain(self.ability,self,stat,user)
    end
    return true
  end

  def pbRaiseStatStageByAbility(stat,increment,user,splashAnim=true)
    return false if fainted?
    ret = false
    @battle.pbShowAbilitySplash(user) if splashAnim
    if pbCanRaiseStatStage?(stat,user,nil,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        ret = pbRaiseStatStage(stat,increment,user)
      else
        ret = pbRaiseStatStageByCause(stat,increment,user,user.abilityName)
      end
    end
    @battle.pbHideAbilitySplash(user) if splashAnim
    return ret
  end

  #=============================================================================
  # Decrease stat stages
  #=============================================================================
  def statStageAtMin?(stat)
    return @stages[stat]<=-6
  end

  def pbCanLowerStatStage?(stat,user=nil,move=nil,showFailMsg=false,ignoreContrary=false)
    return false if fainted?
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbCanRaiseStatStage?(stat,user,move,showFailMsg,true)
    end
	# Reversal Herb
	if hasActiveItem?(:REVERSALHERB) && !ignoreContrary && !@battle.moldBreaker
      return pbCanRaiseStatStage?(stat,user,move,showFailMsg,true)
    end
    if !user || user.index!=@index   # Not self-inflicted
      if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user))
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis)) if showFailMsg
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist]>0 &&
         !(user && user.hasActiveAbility?(:INFILTRATOR))
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showFailMsg
        return false
      end
      if abilityActive?
        return false if BattleHandlers.triggerStatLossImmunityAbility(
           self.ability,self,stat,@battle,showFailMsg) if !@battle.moldBreaker
        return false if BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(
           self.ability,self,stat,@battle,showFailMsg)
      end
      if !@battle.moldBreaker
        eachAlly do |b|
          next if !b.abilityActive?
          return false if BattleHandlers.triggerStatLossImmunityAllyAbility(
             b.ability,b,self,stat,@battle,showFailMsg)
        end
      end
    end
    # Check the stat stage
    if statStageAtMin?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",
         pbThis, GameData::Stat.get(stat).name)) if showFailMsg
      return false
    end
    return true
  end

  def pbLowerStatStageBasic(stat,increment,ignoreContrary=false)
    if !@battle.moldBreaker
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary
        return pbRaiseStatStageBasic(stat,increment,true)
      end
	  # Reversal Herb
	  if hasActiveItem?(:REVERSALHERB) && !ignoreContrary
	    pbConsumeItem
        return pbRaiseStatStageBasic(stat,increment,true)
      end
      # Simple
      increment *= 2 if hasActiveAbility?(:SIMPLE)
    end
    # Change the stat stage
    increment = [increment,6+@stages[stat]].min
    if increment>0
      stat_name = GameData::Stat.get(stat).name
      new = @stages[stat]-increment
      PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@stages[stat]} -> #{new} (-#{increment})")
      @stages[stat] -= increment
    end
    return increment
  end

  def pbLowerStatStage(stat,increment,user,showAnim=true,ignoreContrary=false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbRaiseStatStage(stat,increment,user,showAnim,true)
    end
	# Reversal Herb
	if hasActiveItem?(:REVERSALHERB) && !ignoreContrary && !@battle.moldBreaker
	  @battle.pbDisplay(_INTL("{1}'s {2} reversed stat boosts!",self.pbThis,self.itemName))
	  pbConsumeItem
      return pbRaiseStatStage(stat,increment,user,showAnim,true)
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    arrStatTexts = [
       _INTL("{1}'s {2} fell!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} harshly fell!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} severely fell!",pbThis,GameData::Stat.get(stat).name)]
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
    return true
  end

  def pbLowerStatStageByCause(stat,increment,user,cause,showAnim=true,ignoreContrary=false)
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbRaiseStatStageByCause(stat,increment,user,cause,showAnim,true)
    end
	# Reversal Herb
	if hasActiveItem?(:REVERSALHERB) && !ignoreContrary && !@battle.moldBreaker
	  @battle.pbDisplay(_INTL("{1}'s {2} reversed stat boosts!",self.pbThis,self.itemName))
	  pbConsumeItem
      return pbRaiseStatStageByCause(stat,increment,user,cause,showAnim,true)
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    if user.index==@index
      arrStatTexts = [
         _INTL("{1}'s {2} lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} harshly lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} severely lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name)]
    else
      arrStatTexts = [
         _INTL("{1}'s {2} lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} harshly lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} severely lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name)]
    end
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
    return true
  end

  def pbLowerStatStageByAbility(stat,increment,user,splashAnim=true,checkContact=false)
    ret = false
    @battle.pbShowAbilitySplash(user) if splashAnim
    if pbCanLowerStatStage?(stat,user,nil,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       (!checkContact || affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH))
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        ret = pbLowerStatStage(stat,increment,user)
      else
        ret = pbLowerStatStageByCause(stat,increment,user,user.abilityName)
      end
    end
    @battle.pbHideAbilitySplash(user) if splashAnim
    return ret
  end

  def pbLowerAttackStatStageIntimidate(user)
    return false if fainted?
    # NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
    if @effects[PBEffects::Substitute]>0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
           pbThis,user.pbThis(true),user.abilityName))
      end
      return false
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(:ATTACK,1,user,false)
    end
    # NOTE: These checks exist to ensure appropriate messages are shown if
    #       Intimidate is blocked somehow (i.e. the messages should mention the
    #       Intimidate ability by name).
    if !hasActiveAbility?(:CONTRARY) || !hasActiveItem?(:REVERSALHERB)
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,user.pbThis(true),user.abilityName))
        return false
      end
      if abilityActive?
        if BattleHandlers.triggerStatLossImmunityAbility(self.ability,self,:ATTACK,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(self.ability,self,:ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityName,user.pbThis(true),user.abilityName))
          return false
        end
      end
      eachAlly do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,:ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
             pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(:ATTACK,user)
    return pbLowerStatStageByCause(:ATTACK,1,user,user.abilityName)
  end

  # Copied from pbLowerAttackStatStageIntimidate
  def pbLowerSpecialAttackStatStageChilling(user)
    return false if fainted?
    # NOTE: Substitute intentially blocks Chilling even if self has Contrary.
    if @effects[PBEffects::Substitute]>0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
           pbThis,user.pbThis(true),user.abilityName))
      end
      return false
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,user,false)
    end
    # NOTE: These checks exist to ensure appropriate messages are shown if
    #       Chilling is blocked somehow (i.e. the messages should mention the
    #       Chilling ability by name).
    if !hasActiveAbility?(:CONTRARY) || !hasActiveItem?(:REVERSALHERB)
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,user.pbThis(true),user.abilityName))
        return false
      end
      if abilityActive?
        if BattleHandlers.triggerStatLossImmunityAbility(self.ability,self,:SPECIAL_ATTACK,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(self.ability,self,:SPECIAL_ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityName,user.pbThis(true),user.abilityName))
          return false
        end
      end
      eachAlly do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,:SPECIAL_ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
             pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
    return pbLowerStatStageByCause(:SPECIAL_ATTACK,1,user,user.abilityName)
  end

  #=============================================================================
  # Reset stat stages
  #=============================================================================
  def hasAlteredStatStages?
    GameData::Stat.each_battle { |s| return true if @stages[s.id] != 0 }
    return false
  end

  def hasRaisedStatStages?
    GameData::Stat.each_battle { |s| return true if @stages[s.id] > 0 }
    return false
  end

  def hasLoweredStatStages?
    GameData::Stat.each_battle { |s| return true if @stages[s.id] < 0 }
    return false
  end

  def pbResetStatStages
    GameData::Stat.each_battle { |s| @stages[s.id] = 0 }
  end

  #=============================================================================
  # Stat methods
  #=============================================================================

  def getTotalStats
    stats = self.plainStats
    stats[:HP] = self.totalhp
    totalStats = 0
    GameData::Stat.each_main do |s|
      totalStats += stats[s.id]
    end
    return totalStats
  end

  def getTotalEVs
    totalEVs = 0
    GameData::Stat.each_main do |s|
      totalEVs += self.pokemon.ev[s.id]
    end
    return totalEVs
  end
end
