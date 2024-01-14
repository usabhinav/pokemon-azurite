#===============================================================================
#  Common Animation: STATUP
#===============================================================================
EliteBattle.defineCommonAnimation(:STATUP) do
  # TODO: Come back to this once we finalize what our plan is for this animation
  #-----------------------------------------------------------------------------
  #  set up pattern
  @scene.wait(16, true) if @scene.afterAnim
  @targetSprite.sprite.pattern = Bitmap.new("Graphics/Pictures/StatUp")
  @targetSprite.sprite.pattern_opacity = 0
  #-----------------------------------------------------------------------------
  #  play animation
  pbSEPlay("Anim/increase")
  31.times do
    @targetSprite.sprite.pattern_scroll_y -= 7
    @targetSprite.sprite.pattern_opacity += 4
    @scene.wait(1, true)
  end
  31.times do
    @targetSprite.sprite.pattern_scroll_y -= 7
    @targetSprite.sprite.pattern_opacity -= 4
    @scene.wait(1, true)
  end
  #-----------------------------------------------------------------------------
  #  dispose sprites
  @targetSprite.sprite.pattern.dispose
  @targetSprite.sprite.pattern = nil
  #-----------------------------------------------------------------------------
end
