#===============================================================================
#  Common Animation: FORMCHANGE
#===============================================================================
EliteBattle.defineCommonAnimation(:FORMCHANGE) do | pokemon |
  #-----------------------------------------------------------------------------
  # hides Substitute
  if @targetSprite && @battle.battlescene
    subbed = @targetSprite.isSub
    @scene.setSubstitute(@targetIndex, false) if subbed
  end
  #  transition sprite
  10.times do
    @targetSprite.tone.all += 51 if @targetSprite.tone.all < 255
    @scene.wait(1)
  end
  #-----------------------------------------------------------------------------
  #  apply new Pokemon bitmap
  @targetSprite.setPokemonBitmap(pokemon[0], @targetIsPlayer)
  @targetDatabox.refresh
  @scene.wait
  #-----------------------------------------------------------------------------
  #  transition sprite
  10.times do
    @targetSprite.tone.all -= 51 if @targetSprite.tone.all > 0
    @scene.wait(1)
  end
  # restores Substitute
  if @targetSprite && @battle.battlescene
    substituteEffectActive = @battlers[@targetIndex].effects[PBEffects::Substitute] > 0
    @scene.setSubstitute(@targetIndex) if substituteEffectActive
  end
  #-----------------------------------------------------------------------------
end
