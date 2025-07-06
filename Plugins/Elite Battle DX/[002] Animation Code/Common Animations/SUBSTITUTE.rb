#===============================================================================
#  Common Animation: SUBSTITUTE
#===============================================================================
EliteBattle.defineCommonAnimation(:SUBSTITUTE) do | targets, set |
  #-----------------------------------------------------------------------------
  @scene.wait(16, true) if @scene.afterAnim
  #  transition sprites
  8.times do
    for t in targets
      @sprites["pokemon_#{t}"].x += ((t%2==0) ? -6 : 3)
      @sprites["pokemon_#{t}"].y -= ((t%2==0) ? -4 : 2)
      @sprites["pokemon_#{t}"].opacity -= 32
    end
    @scene.wait(1, false)
  end
  #-----------------------------------------------------------------------------
  #  change sprites
  for t in targets
    if (@battle.battlers[t].effects[PBEffects::Substitute] > 0 && !@sprites["pokemon_#{t}"].isSub) || set
      @sprites["pokemon_#{t}"].setSubstitute
    else
      @sprites["pokemon_#{t}"].removeSubstitute
    end
  end
  #-----------------------------------------------------------------------------
  #  transition sprites
  8.times do
    for t in targets
      @sprites["pokemon_#{t}"].x -= ((t%2 == 0) ? -6 : 3)
      @sprites["pokemon_#{t}"].y += ((t%2 == 0) ? -4 : 2)
      @sprites["pokemon_#{t}"].opacity += 32
    end
    @scene.wait(1, false)
  end
  #-----------------------------------------------------------------------------
  @vector.reset
  @scene.wait(16, true)
end
