# Holds relevant constants
module TeamBuilderTextBasedScreenConstants
  TEXT_BASE_COLOR   = Color.new(0, 0, 0)
  TEXT_SHADOW_COLOR = Color.new(248, 248, 248)

  FOLDER_PATH = "Graphics/Pictures/Team Builder"
  TEAM_SAVE_FILE_PREFIX = "TEAM_"
  TEAM_SAVE_FILE_EXTENSION = ".rxdata"

  SCREEN_LIST = [
    :PlayerTrainerPartySelection,
    :PlayerTrainerItemSelection,
    :OpponentTrainerPartySelection,
    :OpponentTrainerItemSelection,
    :SideSizeSelection,
  ]

  def self.get_team_save_file_name(team_name)
    return "#{TEAM_SAVE_FILE_PREFIX}#{team_name}#{TEAM_SAVE_FILE_EXTENSION}"
  end

  def self.is_team_save_file?(filename)
    return filename.start_with?(TEAM_SAVE_FILE_PREFIX)
  end

  def self.get_team_name_from_filename(filename)
    return filename.sub(TEAM_SAVE_FILE_PREFIX, "").sub(TEAM_SAVE_FILE_EXTENSION, "")
  end
end

class TeamBuilderTextBasedScreen
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def endScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
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

  def pbScene
    @end_scene = false
    loop do
      case @current_screen
      when :PlayerTrainerPartySelection
        partySelectionScene
      when :OpponentTrainerPartySelection
      when :SideSizeSelection
      end
      break if @end_scene
    end
  end

  def partySelectionScene
    command = 0
    loop do
      header_window = Window_AdvancedTextPokemon.new("Build your team")
      header_window.viewport = @viewport
      header_window.x = 0
      header_window.y = 0
      header_window.letterbyletter = false
      header_window.visible = true
      header_window.update
      command = pbShowCommandsWithHelp(nil,
       [_INTL("Edit Team"),
        _INTL("Load Team"),
        _INTL("Save Team"),
        _INTL("Next"),
        _INTL("Exit")],
       [_INTL("Add, remove, and edit Pokémon in your team."),
        _INTL("Load one of your saved teams."),
        _INTL("Save the currently selected team."),
        _INTL("Continue to the next menu."),
        _INTL("Go back to the previous menu.")], -1, command, true)
      pbDisposeMessageWindow(header_window)
      case command
      when 0 # Edit
        pbPokemonScreenForTeamBuilder(@parties[0])
        refreshPokemonIconSprites
      when 1 # Load
        load_team_commands = []
        Dir.foreach(RTP.getSaveFolder) do |entry|
          next if !TeamBuilderTextBasedScreenConstants.is_team_save_file?(entry)
          load_team_commands.push(TeamBuilderTextBasedScreenConstants.get_team_name_from_filename(entry))
        end
        load_team_commands.push("Cancel")
        while true
          load_team_command = pbShowCommands(load_team_commands)
          if load_team_command == -1 || load_team_command == load_team_commands.length - 1
            break
          else
            team_name = load_team_commands[load_team_command]
            if pbConfirmMessage(_INTL("Load team #{team_name}?"))
              team_save_filename = RTP.getSaveFileName(TeamBuilderTextBasedScreenConstants.get_team_save_file_name(team_name))
              File.open(team_save_filename) do |file|
                @parties[0] = Marshal.load(file)
              end
              refreshPokemonIconSprites
              pbMessage(_INTL("Successfully loaded in team #{team_name}."))
            end
          end
        end
      when 2 # Save
        while true
          team_name = pbMessageFreeText("Enter a name for this team.", "", false, 25)
          if team_name.empty?
            break
          elsif !team_name.match?(/^[a-zA-Z0-9]*$/)
            pbMessage("Name can only contain alphanumeric values.")
          else
            team_save_filename = RTP.getSaveFileName(TeamBuilderTextBasedScreenConstants.get_team_save_file_name(team_name))
            if !File.file?(team_save_filename) || pbConfirmMessageSerious(_INTL("WARNING: There is already a saved team with name #{team_name}. Overwrite this team?"))
              File.open(team_save_filename, "wb") { |file| Marshal.dump(@parties[0], file) }
              pbMessage(_INTL("Successfully saved team #{team_name}."))
              break
            end
          end
        end
      when 3 # Next
        pbMessage("Next")
      else
        @end_scene = true
        break
      end
    end
  end

  def refreshBackground
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("#{TeamBuilderTextBasedScreenConstants::FOLDER_PATH}/TeamBuilderScreenPlaceholder")
  end

  def refreshPokemonIconSprites
    for i in 0...6
      refreshPokemonAtIndex(i)
    end
  end

  def refreshPokemonAtIndex(i)
    if @parties[0][i]
      poke = @parties[0][i]
      if @sprites["pokemonIcon#{i}"].nil?
        icon_sprite = PokemonIconSprite.new(poke, @viewport)
        icon_sprite.setOffset(PictureOrigin::CENTER)
        icon_sprite.x = 124 + 32 + (i % 2 == 0 ? 0 : 64)
        icon_sprite.y = 90 + 32 + (i / 2) * 64
        icon_sprite.z = 2
        icon_sprite.active = true
        icon_sprite.update
        @sprites["pokemonIcon#{i}"] = icon_sprite
      else
        @sprites["pokemonIcon#{i}"].pokemon = poke
      end
    elsif !@sprites["pokemonIcon#{i}"].nil?
      @sprites["pokemonIcon#{i}"].visible = false
      @sprites["pokemonIcon#{i}"].dispose
      @sprites["pokemonIcon#{i}"] = nil
    end
  end

  def setupInitialSprites
    refreshPokemonIconSprites
  end

  def pbStartScene
    # Set up background and core sprites
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @buttons = {}
    @current_screen = :PlayerTrainerPartySelection
    @parties = []
    for i in 0...2
      @parties.push([Pokemon.new(:PIKACHU, 20), Pokemon.new(:BULBASAUR, 20), Pokemon.new(:SQUIRTLE, 20), Pokemon.new(:CHARMANDER, 20)])
    end
    refreshBackground
    setupInitialSprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end

def pbStartTeamBuilderTextBasedScreen
  pbFadeOutIn {
    scene = TeamBuilderTextBasedScreen.new
    scene.pbStartScene
    scene.pbScene
    scene.endScene
  }
end
