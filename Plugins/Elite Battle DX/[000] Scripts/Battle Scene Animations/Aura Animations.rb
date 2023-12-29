#===============================================================================
#  Various animations related to Auras
#===============================================================================
class Battle::Scene
  def activateAura(battler_index)
    return if !@sprites["pokemon_#{battler_index}"].aura.nil?
    EliteBattle.playCommonAnimation(:AURAON, self, battler_index)
    @sprites["pokemon_#{battler_index}"].initializeAura
  end

  def deactivateAura(battler_index)
    return if @sprites["pokemon_#{battler_index}"].aura.nil?
    @sprites["pokemon_#{battler_index}"].removeAura
    EliteBattle.playCommonAnimation(:AURAOFF, self, battler_index)
  end
end

class Battle
  def activateAura(battler_index);   @scene.activateAura(battler_index);   end
  def deactivateAura(battler_index); @scene.deactivateAura(battler_index); end
end