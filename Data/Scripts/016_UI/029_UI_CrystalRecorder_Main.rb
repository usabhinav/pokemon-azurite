#===============================================================================
#
#===============================================================================
class CrystalRecorder_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @index = 0
    @last_index = 1
    @sprites = {}
    # Background
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/CrystalRecorder/CR_background")
    # Overlay
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 3
    pbSetSystemFont(@sprites["overlay"].bitmap)
    # Logo
    @sprites["logo"] = IconSprite.new(240, 40, @viewport)
    @sprites["logo"].setBitmap("Graphics/Pictures/CrystalRecorder/CR_logo")
    @sprites["logo"].z = 1
    # Copyright text
    @sprites["copyright_text"] = IconSprite.new(278, 360, @viewport)
    @sprites["copyright_text"].setBitmap("Graphics/Pictures/CrystalRecorder/CR_copyright")
    @sprites["copyright_text"].z = 1
    # Recently Recorded button
    @sprites["recently_recorded_button"] = IconSprite.new(16, 16, @viewport)
    @sprites["recently_recorded_button"].setBitmap("Graphics/Pictures/CrystalRecorder/CRbutton_Recent_norm")
    @sprites["recently_recorded_button"].z = 1
    @sprites["recently_recorded_button_highlight"] = IconSprite.new(16, 16, @viewport)
    @sprites["recently_recorded_button_highlight"].setBitmap("Graphics/Pictures/CrystalRecorder/CRbutton_Recent_hover")
    @sprites["recently_recorded_button_highlight"].z = 2
    # Crystal Pkmn button
    @sprites["crystal_pkmn_button"] = IconSprite.new(250, 140, @viewport)
    @sprites["crystal_pkmn_button"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_CrysPKMN_norm")
    @sprites["crystal_pkmn_button"].z = 1
    @sprites["crystal_pkmn_button_highlight"] = IconSprite.new(250, 140, @viewport)
    @sprites["crystal_pkmn_button_highlight"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_CrysPKMN_hover")
    @sprites["crystal_pkmn_button_highlight"].z = 2
    @sprites["crystal_pkmn_button_highlight"].visible = false
    # Search button
    @sprites["search_button"] = IconSprite.new(250, 186, @viewport)
    @sprites["search_button"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_search_norm")
    @sprites["search_button"].z = 1
    @sprites["search_button_highlight"] = IconSprite.new(250, 186, @viewport)
    @sprites["search_button_highlight"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_search_hover")
    @sprites["search_button_highlight"].z = 2
    @sprites["search_button_highlight"].visible = false
    # Add Recording button
    @sprites["add_recording_button"] = IconSprite.new(250, 232, @viewport)
    @sprites["add_recording_button"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_custom_norm")
    @sprites["add_recording_button"].z = 1
    @sprites["add_recording_button_highlight"] = IconSprite.new(250, 232, @viewport)
    @sprites["add_recording_button_highlight"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_custom_hover")
    @sprites["add_recording_button_highlight"].z = 2
    @sprites["add_recording_button_highlight"].visible = false
    # Shut Off button
    @sprites["shut_off_button"] = IconSprite.new(250, 278, @viewport)
    @sprites["shut_off_button"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_shutoff_norm")
    @sprites["shut_off_button"].z = 1
    @sprites["shut_off_button_highlight"] = IconSprite.new(250, 278, @viewport)
    @sprites["shut_off_button_highlight"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_shutoff_hover")
    @sprites["shut_off_button_highlight"].z = 2
    @sprites["shut_off_button_highlight"].visible = false
    # Crystal Pokemon Info
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    pbUpdateCrystalPokemonInfo
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
  def pbCrystalRecorder
    # TODO: Change this sound effect?
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      last_index = @index
      if Input.trigger?(Input::UP)
        if @index != 0
          @index -= 1
          @index = 4 if @index < 1
        end
        @last_index = last_index if last_index != @index
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        if @index != 0
          @index += 1
          @index = 1 if @index > 4
        end
        @last_index = last_index if last_index != @index
        pbPlayCursorSE
      elsif Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
        @index = (@index == 0) ? @last_index : 0
        @last_index = last_index if last_index != @index
        pbPlayCursorSE
      elsif Input.trigger?(Input::ACTION)

      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
      pbUpdateHighlightedButton
    end
  end

  def pbUpdateHighlightedButton
    @sprites["recently_recorded_button_highlight"].visible  = (@index == 0)
    @sprites["crystal_pkmn_button_highlight"].visible       = (@index == 1)
    @sprites["search_button_highlight"].visible             = (@index == 2)
    @sprites["add_recording_button_highlight"].visible      = (@index == 3)
    @sprites["shut_off_button_highlight"].visible           = (@index == 4)
  end

  def pbUpdateCrystalPokemonInfo
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    crystal_name = "None"
    if $player.pokedex.last_recorded_crystal
      # Get species name
      crystal_form_data = GameData::Species.get($player.pokedex.last_recorded_crystal).get_crystal_form_data
      crystal_name = crystal_form_data.real_name
      # Draw types
      crystal_form_data.types.each_with_index do |type, i|
        type_number = GameData::Type.get(type).icon_position
        type_rect = Rect.new(0, type_number * 27, 63, 27)
        type_x = (crystal_form_data.types.length == 1) ? 98 : 60 + (73 * i)
        overlay.blt(type_x, 284, @typebitmap.bitmap, type_rect)
      end
    end
    textPositions = [
      [_INTL(crystal_name), 130, 70, 2, base, shadow, 1]
    ]
    pbDrawTextPositions(overlay, textPositions)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @typebitmap.dispose
  end
end

#===============================================================================
#
#===============================================================================
class CrystalRecorderScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbCrystalRecorder
    @scene.pbEndScene
  end
end

# TODO: Remove this test function when done!
def testCrystalRecorderScreen
  pbFadeOutIn {
    scene = CrystalRecorder_Scene.new
    screen = CrystalRecorderScreen.new(scene)
    screen.pbStartScreen
  }
end