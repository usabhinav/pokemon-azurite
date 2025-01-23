#===============================================================================
#  Common Animation: TIMEBREAKINTRO
#===============================================================================
EliteBattle.defineCommonAnimation(:TIMEBREAKINTRO) do |time_break_indices|
  # Reset camera and stop current music
  @vector.reset
  $game_system.bgm_memorize
  $game_system.bgm_fade(0.25)
  $game_system.bgs_memorize
  $game_system.bgs_fade(0)
  @scene.wait(10, true)
  # Display text and new background and begin "Za Warudo" sound
  @sprites["battlebg"].createTimeBreakBG
  pbSEPlay("za-warudo-se.mp3", 400)
  @scene.pbDisplay(_INTL("ZA WARUDO!!!"))
  # Pan to one of the Time Break users
  zoom_in_vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  @vector.inc = 0.09
  @vector.set(zoom_in_vector)
  # Really fast invert BG animation with circle going inward at a constant speed
  @scene.invertBG(Proc.new {|r| -7 }, true, @targetIndex)
  15.times do
    @sprites["battlebg"].getTimeBreakBG.opacity += 10
    @scene.wait(1, true)
  end
  # Slower invert BG animation with circle expanding to revert the invert BG animation
  @scene.invertBG(Proc.new {|r| (2 ** (r / 15)) }, false, @targetIndex)
  @scene.wait(15, true)
  # Zoom in really fast on the battler
  zoom_in_total_frames = 10 # Number of frames that this animation should take place over
  zoom_in_factor = 3 # Amount that camera should zoom in by
  zoom_in_vector[4] = zoom_in_factor
  zoom_in_vector[5] = zoom_in_factor
  @vector.inc = 0.2
  @vector.set_linear(zoom_in_vector, zoom_in_total_frames)
  @scene.wait(zoom_in_total_frames, true)
  @vector.reset
  # Zoom out relatively slower
  @vector.inc = 0.02
  @scene.wait(60, true)
  # Zoom out all the way and end the animation
  @vector.inc = 0.2
  20.times do
    # Slow down new BG speed to zero
    @sprites["battlebg"].getTimeBreakBG.speed -= 1 unless @sprites["battlebg"].getTimeBreakBG.speed == 0
    @scene.wait(1, true)
  end
  pbBGSPlay("za-warudo-se-tick.mp3", 200)
  # Freeze non Time Break users
  @battle.allBattlers.each do |b|
    @sprites["pokemon_#{b.index}"].lock if !time_break_indices[0].include?(b.index)
  end
end
