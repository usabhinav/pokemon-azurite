#===============================================================================
#
#===============================================================================
class PokemonJukebox_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands, is_azurite_screen = false)
    @commands = commands
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/jukeboxbg")
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Jukebox"), 2, -18, 128, 64, @viewport
    )
    @sprites["header"].baseColor   = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.new(0, 0, 0)
    @sprites["header"].windowskin  = nil
    @sprites["commands"] = Window_CommandPokemon.newWithSize(
      @commands, 94, 92, 324, 224, @viewport
    )
    @sprites["commands"].windowskin = nil
    if is_azurite_screen
      @sprites["currentTrack"] = Window_UnformattedTextPokemon.new("t")
      @sprites["currentTrack"].width = Graphics.width
      refreshCurrentTrackText
      @sprites["currentTrack"].viewport = @viewport
      pbBottomLeft(@sprites["currentTrack"])
      @sprites["specificTrackHeader"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("t"), 94, 92, 324, 64, @viewport
      )
      @sprites["specificTrackHeader"].contents.font.bold = true
      @sprites["specificTrackHeader"].windowskin  = nil
      @sprites["specificTrackHeader"].visible     = false
      @sprites["specificTrackHeaderArtist"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("t"), 94, 124, 324, 64, @viewport
      )
      @sprites["specificTrackHeaderArtist"].windowskin  = nil
      @sprites["specificTrackHeaderArtist"].visible     = false
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        break
      elsif Input.trigger?(Input::USE)
        ret = @sprites["commands"].index
        break
      end
    end
    return ret
  end

  def pbSetCommands(newcommands, newindex)
    @sprites["commands"].commands = (!newcommands) ? @commands : newcommands
    @sprites["commands"].index    = newindex
  end

  def shiftCommandsDown
    @sprites["commands"].y += 64
  end

  def shiftCommandsUp
    @sprites["commands"].y -= 64
  end

  def pbShowCommands(commands, index = 0)
    ret = -1
    using(cmdwindow = Window_CommandPokemon.new(commands)) {
      cmdwindow.z = @viewport.z + 1
      cmdwindow.index = index
      pbBottomRight(cmdwindow)
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = -1
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          ret = cmdwindow.index
          break
        end
      end
    }
    return ret
  end

  def refreshCurrentTrackText
    @sprites["currentTrack"].text = _INTL("Default battle track: {1}", get_display_name_for_battle_BGM(load_battle_BGM))
    @sprites["currentTrack"].refreshWithoutLineBreaks
  end

  def showSpecificTrackHeader(display_name, artist_name)
    @sprites["specificTrackHeader"].text = _INTL(display_name)
    @sprites["specificTrackHeader"].visible = true
    @sprites["specificTrackHeader"].refreshWithoutLineBreaks
    if artist_name
      @sprites["specificTrackHeaderArtist"].text = _INTL("by: {1}", artist_name)
      @sprites["specificTrackHeaderArtist"].visible = true
      @sprites["specificTrackHeaderArtist"].refreshWithoutLineBreaks
    end
  end

  def hideSpecificTrackHeader
    @sprites["specificTrackHeader"].visible = false
    @sprites["specificTrackHeader"].refreshWithoutLineBreaks
    @sprites["specificTrackHeaderArtist"].visible = false
    @sprites["specificTrackHeaderArtist"].refreshWithoutLineBreaks
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonJukeboxScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands = []
    cmdMarch   = -1
    cmdLullaby = -1
    cmdOak     = -1
    cmdCustom  = -1
    cmdTurnOff = -1
    commands[cmdMarch = commands.length]   = _INTL("Play: Pokémon March")
    commands[cmdLullaby = commands.length] = _INTL("Play: Pokémon Lullaby")
    commands[cmdOak = commands.length]     = _INTL("Play: Oak")
    commands[cmdCustom = commands.length]  = _INTL("Play: Custom...")
    commands[cmdTurnOff = commands.length] = _INTL("Stop")
    commands[commands.length]              = _INTL("Exit")
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
      if cmd < 0
        pbPlayCloseMenuSE
        break
      elsif cmdMarch >= 0 && cmd == cmdMarch
        pbPlayDecisionSE
        pbBGMPlay("Radio - March", 100, 100)
        $PokemonMap.whiteFluteUsed = true if $PokemonMap
        $PokemonMap.blackFluteUsed = false if $PokemonMap
      elsif cmdLullaby >= 0 && cmd == cmdLullaby
        pbPlayDecisionSE
        pbBGMPlay("Radio - Lullaby", 100, 100)
        $PokemonMap.blackFluteUsed = true if $PokemonMap
        $PokemonMap.whiteFluteUsed = false if $PokemonMap
      elsif cmdOak >= 0 && cmd == cmdOak
        pbPlayDecisionSE
        pbBGMPlay("Radio - Oak", 100, 100)
        $PokemonMap.whiteFluteUsed = false if $PokemonMap
        $PokemonMap.blackFluteUsed = false if $PokemonMap
      elsif cmdCustom >= 0 && cmd == cmdCustom
        pbPlayDecisionSE
        files = []
        Dir.chdir("Audio/BGM/") {
          Dir.glob("*.ogg") { |f| files.push(f) }
          Dir.glob("*.wav") { |f| files.push(f) }
          Dir.glob("*.mid") { |f| files.push(f) }
          Dir.glob("*.midi") { |f| files.push(f) }
        }
        files.map! { |f| f.chomp(File.extname(f)) }
        files.uniq!
        files.sort! { |a, b| a.downcase <=> b.downcase }
        @scene.pbSetCommands(files, 0)
        loop do
          cmd2 = @scene.pbScene
          if cmd2 < 0
            pbPlayCancelSE
            break
          end
          pbPlayDecisionSE
          $game_system.setDefaultBGM(files[cmd2])
          $PokemonMap.whiteFluteUsed = false if $PokemonMap
          $PokemonMap.blackFluteUsed = false if $PokemonMap
        end
        @scene.pbSetCommands(nil, cmdCustom)
      elsif cmdTurnOff >= 0 && cmd == cmdTurnOff
        pbPlayDecisionSE
        $game_system.setDefaultBGM(nil)
        pbBGMPlay(pbResolveAudioFile($game_map.bgm_name, $game_map.bgm.volume, $game_map.bgm.pitch))
        $PokemonMap.whiteFluteUsed = false if $PokemonMap
        $PokemonMap.blackFluteUsed = false if $PokemonMap
      else   # Exit
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene
  end

  def trackOptions(display_name, filename)
    commands = []
    cmdPlay   = -1
    cmdSetBGM = -1
    commands[cmdPlay = commands.length]   = _INTL("Play")
    commands[cmdSetBGM = commands.length] = _INTL("Set as default battle track")
    commands[commands.length]             = _INTL("Cancel")
    @scene.pbSetCommands(commands, 0)
    @scene.shiftCommandsDown
    @scene.showSpecificTrackHeader(display_name, get_artist_name_for_battle_BGM(filename))
    loop do
      command = @scene.pbScene
      if command < 0 || command == commands.length - 1
        pbPlayCancelSE
        break
      end
      pbPlayDecisionSE
      if cmdPlay >= 0 && command == cmdPlay
        $game_system.setDefaultBGM(filename)
        break
      elsif cmdSetBGM >= 0 && command == cmdSetBGM
        save_battle_BGM(filename)
        @scene.refreshCurrentTrackText
        $game_system.setDefaultBGM(filename)
        break
      end
    end
    @scene.shiftCommandsUp
    @scene.hideSpecificTrackHeader
  end

  def showTrackList(file_filter_proc = nil)
    files = []
    Dir.chdir("Audio/BGM/") {
      Dir.glob("*.ogg") { |f| files.push(f) }
      Dir.glob("*.wav") { |f| files.push(f) }
      Dir.glob("*.mid") { |f| files.push(f) }
      Dir.glob("*.midi") { |f| files.push(f) }
    }
    files.select!(&file_filter_proc) if file_filter_proc
    display_name_to_filename_map = {}
    files.map! do |f|
      filename = f.chomp(File.extname(f))
      display_name = filename
      if is_audio_file_azurite_ost(f)
        display_name = get_display_name_for_battle_BGM(filename)
      end
      if display_name_to_filename_map.key?(display_name)
        raise "Found multiple tracks with the same name or Title metadata: #{display_name}"
      end
      display_name_to_filename_map[display_name] = filename
      next display_name
    end
    files.uniq!
    files.sort! { |a, b| a.downcase <=> b.downcase }
    @scene.pbSetCommands(files, 0)
    loop do
      cmd2 = @scene.pbScene
      if cmd2 < 0
        pbPlayCancelSE
        break
      end
      pbPlayDecisionSE
      trackOptions(files[cmd2], display_name_to_filename_map[files[cmd2]])
      @scene.pbSetCommands(files, cmd2)
    end
  end

  def pbStartAzuriteJukeboxScreen
    commands = []
    cmdCustom  = -1
    cmdCustomAzurite = -1
    cmdSetRandom = -1
    cmdTurnOff = -1
    commands[cmdCustom = commands.length]           = _INTL("View all tracks...")
    commands[cmdCustomAzurite = commands.length]    = _INTL("View Azurite tracks...")
    commands[cmdSetRandom = commands.length]        = _INTL("Set random track in battle")
    commands[cmdTurnOff = commands.length]          = _INTL("Stop current track")
    commands[commands.length]                       = _INTL("Exit")
    @scene.pbStartScene(commands, true)
    loop do
      cmd = @scene.pbScene
      if cmd < 0
        pbPlayCloseMenuSE
        break
      elsif cmdCustom >= 0 && cmd == cmdCustom
        pbPlayDecisionSE
        showTrackList
        @scene.pbSetCommands(nil, cmdCustom)
      elsif cmdCustomAzurite >= 0 && cmd == cmdCustomAzurite
        pbPlayDecisionSE
        showTrackList(Proc.new { |f| is_audio_file_azurite_ost(f) })
        @scene.pbSetCommands(nil, cmdCustomAzurite)
      elsif cmdSetRandom >= 0 && cmd == cmdSetRandom
        pbPlayDecisionSE
        randomize_battle_BGM
        @scene.refreshCurrentTrackText
        $game_system.setDefaultBGM(nil)
        $game_system.bgm_stop
      elsif cmdTurnOff >= 0 && cmd == cmdTurnOff
        pbPlayDecisionSE
        $game_system.setDefaultBGM(nil)
        $game_system.bgm_stop
      else   # Exit
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene
  end
end
