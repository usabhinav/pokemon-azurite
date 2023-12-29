#===============================================================================
#  Common Animation: AURAON
#===============================================================================
EliteBattle.defineCommonAnimation(:AURAON) do
  cx, cy = @targetSprite.getCenter(true)
  factor = @targetSprite.zoom_x
  filename = "aura_on_#{@battle.auraTypeOfBattler(@targetIndex)}"
  sprite = AnimatedSprite.new("Graphics/EBDX/Animations/Auras/#{filename}", 10, 256, 256, 2, @viewport)
  sprite.x = cx - (sprite.framewidth * factor) / 2
  sprite.y = cy - (sprite.frameheight * factor) / 2
  sprite.zoom_x = factor
  sprite.zoom_y = factor
  sprite.z = @targetSprite.z - 1
  sprite.mirror = @targetIsPlayer
  sprite.play
  for i in 0...36
    sprite.update
    @scene.wait(1, true)
  end
  sprite.visible = false
  sprite.dispose
end
