#===============================================================================
#  Common Animation: SKILLSCAN
#===============================================================================
EliteBattle.defineCommonAnimation(:SKILLSCAN) do
  pbSEPlay("FollowEmote")
  cx, cy = @targetSprite.getCenter(true)
  factor = @targetSprite.zoom_x
  skill_scan_sprite = AnimatedSprite.new("Graphics/EBDX/Animations/Moves/SkillScan", 10, 31, 31, 2, @viewport)
  skill_scan_sprite.x = cx - 16*factor
  skill_scan_sprite.y = cy - (@targetSprite.height/2*factor)
  skill_scan_sprite.zoom_x = factor
  skill_scan_sprite.zoom_y = factor
  skill_scan_sprite.z = @targetIsPlayer ? 29 : 19
  skill_scan_sprite.play
  for i in 0...20
    skill_scan_sprite.update
    @scene.wait(1, true)
  end
  skill_scan_sprite.visible = false
  skill_scan_sprite.dispose
end
