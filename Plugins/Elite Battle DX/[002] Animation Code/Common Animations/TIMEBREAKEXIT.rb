#===============================================================================
#  Common Animation: TIMEBREAKEXIT
#===============================================================================
EliteBattle.defineCommonAnimation(:TIMEBREAKEXIT) do |time_break_indices|
  # Un-freeze non Time Break users
  @battle.allBattlers.each do |b|
    @sprites["pokemon_#{b.index}"].unlock if !time_break_indices[0].include?(b.index)
  end
  # Stop ticking sound and play exit sound
  $game_system.bgs_restore
  pbSEPlay("za-warudo-se-exit.mp3", 300)
  @scene.wait(20, true)
  # Speed up new background
  20.times do
    @sprites["battlebg"].getTimeBreakBG.speed += 1 unless @sprites["battlebg"].getTimeBreakBG.speed == 20
    @scene.wait(1, true)
  end
  # Fade out and remove new background
  20.times do
    @sprites["battlebg"].getTimeBreakBG.opacity -= 15
    @scene.wait(1, true)
  end
  @sprites["battlebg"].getTimeBreakBG.dispose
  @sprites["battlebg"].removeTimeBreakBG
  # Resume BGM
  $game_system.bgm_restore
end
