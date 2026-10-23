#-------------------------------------------------------------------------------
#  Searing Meteor
#  Elite Battle: DX move animation for Pokemon Essentials v20
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:SEARINGMETEOR) do
  fp = {}
  move_path = "Graphics/EBDX/Animations/Moves/"

  user_vector = @scene.getRealVector(@userIndex, @userIsPlayer)
  @sprites["battlebg"].defocus
  @vector.set(user_vector)
  @vector.inc = 0.1

  fp["meteor"] = Sprite.new(@viewport)
  fp["meteor"].bitmap = pbBitmap(move_path + "SearingMeteor")
  fp["meteor"].ox = fp["meteor"].bitmap.width / 2
  fp["meteor"].oy = fp["meteor"].bitmap.height / 2
  fp["meteor"].z = @userSprite.z + 20
  fp["meteor"].opacity = 0

  fp["glow"] = Sprite.new(@viewport)
  fp["glow"].bitmap = pbBitmap(move_path + "eb263_3")
  fp["glow"].ox = fp["glow"].bitmap.width / 2
  fp["glow"].oy = fp["glow"].bitmap.height / 2
  fp["glow"].z = @userSprite.z + 18
  fp["glow"].color = Color.new(255, 80, 0, 150)
  fp["glow"].opacity = 0

  fp["fire"] = Sprite.new(@viewport)
  fp["fire"].bitmap = pbBitmap(move_path + "Cosmic1")
  fp["fire"].ox = fp["fire"].bitmap.width / 2
  fp["fire"].oy = fp["fire"].bitmap.height / 2
  fp["fire"].z = @userSprite.z + 19
  fp["fire"].opacity = 0

  for i in 0...8
    fp["flame#{i}"] = Sprite.new(@viewport)
    fp["flame#{i}"].bitmap = pbBitmap(move_path + "Fire1")
    fp["flame#{i}"].ox = fp["flame#{i}"].bitmap.width / 2
    fp["flame#{i}"].oy = fp["flame#{i}"].bitmap.height / 2
    fp["flame#{i}"].z = @userSprite.z + 21
    fp["flame#{i}"].opacity = 0
    scale = [0.35, 0.45, 0.55, 0.65][rand(4)]
    fp["flame#{i}"].zoom_x = scale
    fp["flame#{i}"].zoom_y = scale
  end

  ux, uy = @userSprite.getCenter(true)
  meteor_x = ux
  meteor_y = uy - 44 * @userSprite.zoom_y
  fp["meteor"].x = meteor_x
  fp["meteor"].y = meteor_y
  fp["glow"].x = meteor_x
  fp["glow"].y = meteor_y

  pbSEPlay("Anim/Will-O-Wisp", 80)
  for i in 0...36
    ux, uy = @userSprite.getCenter(true)
    meteor_x = ux
    meteor_y = uy - (42 + [i, 24].min * 0.35) * @userSprite.zoom_y
    fp["meteor"].x = meteor_x
    fp["meteor"].y = meteor_y
    fp["meteor"].opacity = [i * 18, 255].min
    fp["meteor"].angle += 4 + i * 0.18
    scale = 0.45 + [i, 30].min * 0.022
    fp["meteor"].zoom_x = scale
    fp["meteor"].zoom_y = scale

    fp["glow"].x = meteor_x
    fp["glow"].y = meteor_y
    fp["glow"].angle -= 3
    fp["glow"].zoom_x = 0.45 + (i % 8) * 0.045
    fp["glow"].zoom_y = 0.45 + (i % 8) * 0.045
    fp["glow"].opacity = [70 + i * 5, 220].min
    fp["fire"].x = meteor_x
    fp["fire"].y = meteor_y + 8
    fp["fire"].angle = (i * 9) - 25
    fp["fire"].zoom_x = 0.48 + [i, 30].min * 0.012
    fp["fire"].zoom_y = 0.48 + [i, 30].min * 0.012
    fp["fire"].opacity = [i * 9, 220].min

    for j in 0...8
      angle = (i * 13 + j * 45) * Math::PI / 180.0
      radius = (26 + (i % 6) * 2) * @userSprite.zoom_x
      fp["flame#{j}"].x = meteor_x + Math.cos(angle) * radius
      fp["flame#{j}"].y = meteor_y + Math.sin(angle) * radius
      fp["flame#{j}"].angle = -20 + Math.sin(angle) * 35
      fp["flame#{j}"].opacity = [80 + i * 5, 230].min
      fp["flame#{j}"].zoom_x = 0.35 + (i % 5) * 0.07
      fp["flame#{j}"].zoom_y = fp["flame#{j}"].zoom_x
    end
    # A stronger pulse in the final part of the charge.
    if i >= 24 && i % 4 == 0
      pbSEPlay("Anim/Ember", 80)
    end
    @scene.wait(1, true)
  end

  target_vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  @vector.set(target_vector)
  @vector.inc = 0.1
  pbSEPlay("Anim/Comet Punch", 100)
  x0 = fp["meteor"].x
  y0 = fp["meteor"].y
  fp["glow"].opacity = 0
  fp["fire"].opacity = 0
  for i in 0...24
    t = (i + 1).to_f / 24
    tx, ty = @targetSprite.getCenter(true)
    arc = Math.sin(Math::PI * t) * 34
    fp["meteor"].x = x0 + (tx - x0) * t
    fp["meteor"].y = y0 + (ty - y0) * t - arc
    fp["meteor"].angle += 24
    fp["meteor"].zoom_x = 0.98 + t * 0.22
    fp["meteor"].zoom_y = fp["meteor"].zoom_x
    fp["meteor"].opacity = 255

    for j in 0...8
      trail_t = [t - (j + 1) * 0.055, 0].max
      trail_arc = Math.sin(Math::PI * trail_t) * 34
      fp["flame#{j}"].x = x0 + (tx - x0) * trail_t
      fp["flame#{j}"].y = y0 + (ty - y0) * trail_t - trail_arc
      fp["flame#{j}"].angle = fp["meteor"].angle + j * 18
      fp["flame#{j}"].opacity = [230 - j * 24, 0].max
      fp["flame#{j}"].zoom_x = 0.65 + (7 - j) * 0.045
      fp["flame#{j}"].zoom_y = fp["flame#{j}"].zoom_x
    end
    @scene.wait(1, true)
  end

  fp["meteor"].opacity = 0
  for j in 0...8
    fp["flame#{j}"].opacity = 0
  end

  cx, cy = @targetSprite.getCenter(true)
  impact_z = @targetSprite.z + 5

  fp["blast"] = Sprite.new(@viewport)
  fp["blast"].bitmap = pbBitmap(move_path + "eb263_3")
  fp["blast"].ox = fp["blast"].bitmap.width / 2
  fp["blast"].oy = fp["blast"].bitmap.height / 2
  fp["blast"].x = cx
  fp["blast"].y = cy
  fp["blast"].z = impact_z
  fp["blast"].color = Color.new(255, 75, 0, 120)
  fp["blast"].opacity = 255
  fp["blast"].zoom_x = 0.35
  fp["blast"].zoom_y = 0.35

  fp["burst"] = Sprite.new(@viewport)
  fp["burst"].bitmap = pbBitmap(move_path + "eb129_2")
  fp["burst"].ox = fp["burst"].bitmap.width / 2
  fp["burst"].oy = fp["burst"].bitmap.height / 2
  fp["burst"].x = cx
  fp["burst"].y = cy
  fp["burst"].z = impact_z + 2
  fp["burst"].color = Color.new(255, 120, 20, 100)
  fp["burst"].opacity = 255
  fp["burst"].zoom_x = 0.25
  fp["burst"].zoom_y = 0.25

  fp["flash"] = Sprite.new(@viewport)
  fp["flash"].bitmap = pbBitmap(move_path + "eb263")
  fp["flash"].ox = fp["flash"].bitmap.width / 2
  fp["flash"].oy = fp["flash"].bitmap.height / 2
  fp["flash"].x = cx
  fp["flash"].y = cy
  fp["flash"].z = impact_z + 3
  fp["flash"].opacity = 0
  fp["flash"].zoom_x = 0.3
  fp["flash"].zoom_y = 0.3

  fp["smoke"] = Sprite.new(@viewport)
  fp["smoke"].bitmap = pbBitmap(move_path + "eb642")
  fp["smoke"].ox = fp["smoke"].bitmap.width / 2
  fp["smoke"].oy = fp["smoke"].bitmap.height / 2
  fp["smoke"].x = cx
  fp["smoke"].y = cy + 12
  fp["smoke"].z = impact_z + 1
  fp["smoke"].opacity = 0
  fp["smoke"].zoom_x = 0.5
  fp["smoke"].zoom_y = 0.5

  pbSEPlay("Anim/Explosion7", 100)
  original_ox = @targetSprite.bitmap.width / 2
  shake = 6
  for i in 0...28
    fp["blast"].zoom_x = 0.35 + i * 0.085
    fp["blast"].zoom_y = 0.35 + i * 0.075
    fp["blast"].opacity = [255 - i * 7, 0].max
    fp["blast"].angle += 2
    fp["burst"].zoom_x = 0.25 + i * 0.105
    fp["burst"].zoom_y = 0.25 + i * 0.09
    fp["burst"].angle += 5
    fp["burst"].opacity = [255 - i * 8, 0].max
    fp["flash"].opacity = (i < 4 ? 230 - i * 45 : 0)
    fp["flash"].zoom_x = 0.3 + i * 0.07
    fp["flash"].zoom_y = 0.3 + i * 0.06
    fp["smoke"].zoom_x = 0.5 + i * 0.045
    fp["smoke"].zoom_y = 0.5 + i * 0.04
    fp["smoke"].angle -= 1
    fp["smoke"].opacity = (i < 5 ? 0 : [((i - 5) * 13), 150].min) - [((i - 19) * 8), 0].max
    fp["smoke"].opacity = [[fp["smoke"].opacity, 0].max, 150].min

    if i < 15
      @targetSprite.color = Color.new(255, 95, 20, [180 - i * 10, 0].max)
      @targetSprite.ox += shake
      shake = -6 if @targetSprite.ox > original_ox + 6
      shake = 6 if @targetSprite.ox < original_ox - 6
    else
      @targetSprite.color = Color.new(255, 55, 0, [100 - (i - 15) * 8, 0].max)
    end
    @targetSprite.still
    @scene.wait(1, true)
  end

  8.times do
    fp["blast"].opacity -= 20 if fp["blast"].opacity > 0
    fp["burst"].opacity -= 20 if fp["burst"].opacity > 0
    fp["flash"].opacity -= 24 if fp["flash"].opacity > 0
    @targetSprite.still
    @scene.wait(1, true)
  end

  @targetSprite.ox = original_ox
  @targetSprite.color = Color.new(0, 0, 0, 0)
  @targetSprite.still
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
