#===============================================================================
#  Common Animation: MOSAICTRANSFORM
#===============================================================================
EliteBattle.defineCommonAnimation(:MOSAICTRANSFORM) do | pokemon |
  #-----------------------------------------------------------------------------
  #  load new Pokemon bitmap file ahead of time and pixelate current and new bitmaps
  frame_count = 10
  pokemon_bitmap = BitmapEBDX.new(pbPokemonBitmapFileName(pokemon[0], pokemon[0].species, @targetIsPlayer), 2, 1, true)
  pokemon_bitmap.refresh_mosaic(frame_count, false)
  @targetSprite.actualBitmap.refresh_mosaic(frame_count)
  @targetSprite.actualBitmap.frameSkip = 1
  @targetSprite.actualBitmap.currentIndex = frame_count - 1
  #-----------------------------------------------------------------------------
  #  do pixelate animation
  frame_count.times do
    @scene.wait(2)
  end
  #-----------------------------------------------------------------------------
  #  apply new Pokemon bitmap
  @targetSprite.setPokemonBitmap(pokemon[0], @targetIsPlayer, nil, pokemon_bitmap)
  @targetDatabox.refresh
  #-----------------------------------------------------------------------------
  #  pixelate final sprite
  old_frame_skip = @targetSprite.actualBitmap.frameSkip
  @targetSprite.actualBitmap.frameSkip = 1
  @targetSprite.actualBitmap.currentIndex = frame_count - 1
  #-----------------------------------------------------------------------------
  #  do un-pixelate animation
  frame_count.times do
    @scene.wait(2)
  end
  #-----------------------------------------------------------------------------
  #  load new Pokemon bitmap again without refreshing other things like shadow and metrics
  @targetSprite.setBitmapForced(pokemon[0], @targetIsPlayer)
  @targetSprite.actualBitmap.currentIndex = 9 % @targetSprite.actualBitmap.totalFrames
end
