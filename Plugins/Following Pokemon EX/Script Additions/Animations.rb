#-------------------------------------------------------------------------------
# New sendout animation for Following Pokemon to slide in when sent out for
# the first time in battle. Toggleable.
#-------------------------------------------------------------------------------
class Battle::Scene::Animation::PokeballPlayerSendOut < Battle::Scene::Animation
  def initialize(sprites, viewport, idxTrainer, battler, startBattle, idxOrder=0)
    @idxTrainer     = idxTrainer
    @battler        = battler
    @showingTrainer = startBattle
    @idxOrder       = idxOrder
    @trainer        = @battler.battle.pbGetOwnerFromBattlerIndex(@battler.index)
    @shadowVisible  = sprites["shadow_#{battler.index}"].visible
    @sprites        = sprites
    @viewport       = viewport
    @pictureEx      = []   # For all the PictureEx
    @pictureSprites = []   # For all the sprites
    @tempSprites    = []   # For sprites that exist only for this animation
    @animDone       = false
    if FollowingPkmn.active? && startBattle &&
       battler.index == 0 && FollowingPkmn::SLIDE_INTO_BATTLE
      createFollowerProcesses
    else
      createProcesses
    end
  end

  def createFollowerProcesses
    delay = 0
    delay = 5 if @showingTrainer
    batSprite = @sprites["pokemon_#{@battler.index}"]
    shaSprite = @sprites["shadow_#{@battler.index}"]
    battlerY = batSprite.y
    battler = addSprite(batSprite, PictureOrigin::BOTTOM)
    battler.setVisible(delay, true)
    battler.setZoomXY(delay, 100, 100)
    battler.setColor(delay, Color.new(0, 0, 0, 0))
    battler.setDelta(0, -240, 0)
    battler.moveDelta(delay, 12, 240, 0)
    battler.setCallback(delay + 12, [batSprite,:pbPlayIntroAnimation])
    if @shadowVisible
      shadow = addSprite(shaSprite, PictureOrigin::CENTER)
      shadow.setVisible(delay, @shadowVisible)
      shadow.setDelta(0, -Graphics.width/2, 0)
      shadow.setDelta(delay, 12, Graphics.width/2, 0)
    end
  end
end

#-------------------------------------------------------------------------------
# Tiny fix for emote Animations not playing in v20 since people are unable to
# read instructions and can't close RMXP before adding the Following Pokemon
# EX emote animations
#-------------------------------------------------------------------------------
class SpriteAnimation
  def effect?; return @_animation_duration > 0 if @_animation_duration; end
end
