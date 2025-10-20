# Holds relevant constants
module TeamBuilderTextBasedScreenConstants
  TEXT_BASE_COLOR   = Color.new(0, 0, 0)
  TEXT_SHADOW_COLOR = Color.new(248, 248, 248)

  FOLDER_PATH = "Graphics/Pictures/Team Builder"
  TEAM_DATA_OBJECT_NAME = "team"
  BAG_DATA_OBJECT_NAME = "bag"
  SAVE_FILE_EXTENSION = ".rxdata"

  SAVE_FILE_PREFIX_MAP = {
    TEAM_DATA_OBJECT_NAME => "TEAM_",
    BAG_DATA_OBJECT_NAME => "BAG_",
  }

  SCREEN_LIST = [
    :PlayerTrainerPartySelection,
    :OpponentTrainerPartySelection,
    :SideSizeSelection,
  ]

  def self.get_next_screen(current_screen)
    index = SCREEN_LIST.index(current_screen)
    return index == SCREEN_LIST.length - 1 ? nil : SCREEN_LIST[index + 1]
  end

  def self.get_previous_screen(current_screen)
    index = SCREEN_LIST.index(current_screen)
    return index == 0 ? nil : SCREEN_LIST[index - 1]
  end

  def self.get_save_file_name(data_object_name, input_name)
    return "#{SAVE_FILE_PREFIX_MAP[data_object_name]}#{input_name}#{SAVE_FILE_EXTENSION}"
  end

  def self.is_save_file?(data_object_name, filename)
    return filename.start_with?(SAVE_FILE_PREFIX_MAP[data_object_name])
  end

  def self.get_save_name_from_filename(data_object_name, filename)
    return filename.sub(SAVE_FILE_PREFIX_MAP[data_object_name], "").sub(SAVE_FILE_EXTENSION, "")
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

  def getActiveTrainerIndex
    if @current_screen == :PlayerTrainerPartySelection
      return 0
    elsif @current_screen == :OpponentTrainerPartySelection
      return 1
    end
    return 0
  end

  def pbScene
    @end_scene = false
    loop do
      case @current_screen
      when :PlayerTrainerPartySelection
        partySelectionScene
      when :OpponentTrainerPartySelection
        partySelectionScene
      when :SideSizeSelection
        pbMessage("SIDE SIZES")
        @current_screen = TeamBuilderTextBasedScreenConstants.get_previous_screen(@current_screen)
      end
      break if @end_scene
      refreshPokemonIconSprites
    end
  end

  def partySelectionScene
    command = 0
    loop do
      header_window = Window_AdvancedTextPokemon.new(getActiveTrainerIndex == 0 ? _INTL("Build your team") : _INTL("Build opposing team"))
      header_window.viewport = @viewport
      header_window.x = 0
      header_window.y = 0
      header_window.letterbyletter = false
      header_window.visible = true
      header_window.update
      commands = []
      commands_help = []
      # Edit team
      commands[cmdEditTeam = commands.length] = _INTL("Edit team")
      commands_help[cmdEditTeam] = _INTL("Add, remove, and edit Pokémon in the team.")
      # Random party
      commands[cmdRandomParty = commands.length] = _INTL("Random party")
      commands_help[cmdRandomParty] = _INTL("Generate a random party of 6 Pokémon.")
      # Random Azurite party
      commands[cmdRandomAzuriteParty = commands.length] = _INTL("Random Azurite party")
      commands_help[cmdRandomAzuriteParty] = _INTL("Generate a random party of 6 Azurite Pokémon.")
      # Load team
      commands[cmdLoadTeam = commands.length] = _INTL("Load team")
      commands_help[cmdLoadTeam] = _INTL("Load one of your saved teams.")
      # Save team
      commands[cmdSaveTeam = commands.length] = _INTL("Save team")
      commands_help[cmdSaveTeam] = _INTL("Save the currently selected team.")
      # Edit bag
      commands[cmdEditBag = commands.length] = _INTL("Edit bag")
      commands_help[cmdEditBag] = _INTL("Add and remove items from your bag.")
      # Load bag
      commands[cmdLoadBag = commands.length] = _INTL("Load bag")
      commands_help[cmdLoadBag] = _INTL("Load one of your saved bags.")
      # Save bag
      commands[cmdSaveBag = commands.length] = _INTL("Save bag")
      commands_help[cmdSaveBag] = _INTL("Save the current bag.")
      # Next
      commands[cmdNext = commands.length] = _INTL("Next")
      commands_help[cmdNext] = _INTL("Continue to the next menu.")
      # Exit/back
      commands[cmdExit = commands.length] = TeamBuilderTextBasedScreenConstants.get_previous_screen(@current_screen).nil? ? _INTL("Exit") : _INTL("Back")
      commands_help[cmdExit] = _INTL("Go back to the previous menu.")
      command = pbShowCommandsWithHelp(nil, commands, commands_help, cmdExit + 1, command, true)
      pbDisposeMessageWindow(header_window)
      case command
      when cmdEditTeam
        pbPokemonScreenForTeamBuilder(@parties[getActiveTrainerIndex]) { refreshPokemonIconSprites }
      when cmdRandomParty, cmdRandomAzuriteParty
        if pbConfirmMessage(_INTL("This action will overwrite the current party. Continue?"))
          params = ChooseNumberParams.new
          params.setRange(1, GameData::GrowthRate.max_level)
          params.setDefaultValue(0)
          params.setCancelValue(0)
          level = pbMessageChooseNumber(
            _INTL("Set the party level (max. {1}).", params.maxNumber), params
          )
          if level > 0
            species_data_form_map = getPossibleSpeciesDataFormMapForTeamBuilder(level, command == cmdRandomAzuriteParty ? [99] : nil)
            @parties[getActiveTrainerIndex] = getRandomPartyFromSpeciesDataFormMap(species_data_form_map, level)
            refreshPokemonIconSprites
            pbMessage(_INTL("Successfully generated a new party."))
          end
        end
      when cmdLoadTeam
        loadDataObject(TeamBuilderTextBasedScreenConstants::TEAM_DATA_OBJECT_NAME, Proc.new { |file| @parties[getActiveTrainerIndex] = Marshal.load(file); refreshPokemonIconSprites })
      when cmdSaveTeam
        saveDataObject(TeamBuilderTextBasedScreenConstants::TEAM_DATA_OBJECT_NAME, @parties[getActiveTrainerIndex])
      when cmdEditBag
        pbBagScreenForTeamBuilder(@bags[getActiveTrainerIndex])
      when cmdLoadBag
        loadDataObject(TeamBuilderTextBasedScreenConstants::BAG_DATA_OBJECT_NAME, Proc.new { |file| @bags[getActiveTrainerIndex] = Marshal.load(file) })
      when cmdSaveBag
        saveDataObject(TeamBuilderTextBasedScreenConstants::BAG_DATA_OBJECT_NAME, @bags[getActiveTrainerIndex])
      when cmdNext
        @current_screen = TeamBuilderTextBasedScreenConstants.get_next_screen(@current_screen)
        break
      else
        new_screen = TeamBuilderTextBasedScreenConstants.get_previous_screen(@current_screen)
        if new_screen
          @current_screen = new_screen
          break
        elsif pbConfirmMessage(_INTL("Exit this menu? Any unsaved changes will be lost."))
          @end_scene = true
          break
        end
      end
    end
  end

  def loadDataObject(data_object_name, on_load_method)
    load_commands = []
    Dir.foreach(RTP.getSaveFolder) do |entry|
      next if !TeamBuilderTextBasedScreenConstants.is_save_file?(data_object_name, entry)
      load_commands.push(TeamBuilderTextBasedScreenConstants.get_save_name_from_filename(data_object_name, entry))
    end
    load_commands.push("Cancel")
    while true
      load_command = pbShowCommands(load_commands)
      if load_command == -1 || load_command == load_commands.length - 1
        break
      else
        chosen_name = load_commands[load_command]
        if pbConfirmMessage(_INTL("Load #{data_object_name} #{chosen_name}?"))
          save_filename = RTP.getSaveFileName(TeamBuilderTextBasedScreenConstants.get_save_file_name(data_object_name, chosen_name))
          File.open(save_filename) do |file|
            on_load_method.call(file)
          end
          pbMessage(_INTL("Successfully loaded in #{data_object_name} #{chosen_name}."))
        end
      end
    end
  end

  def saveDataObject(data_object_name, data_object)
    while true
      chosen_name = pbMessageFreeText("Enter a name for this #{data_object_name}.", "", false, 25)
      if chosen_name.empty?
        break
      elsif !chosen_name.match?(/^[a-zA-Z0-9]*$/)
        pbMessage("Name can only contain alphanumeric values.")
      else
        chosen_save_filename = RTP.getSaveFileName(TeamBuilderTextBasedScreenConstants.get_save_file_name(data_object_name, chosen_name))
        if !File.file?(chosen_save_filename) || pbConfirmMessageSerious(_INTL("WARNING: There is already a saved #{data_object_name} with name #{chosen_name}. Overwrite this #{data_object_name}?"))
          File.open(chosen_save_filename, "wb") { |file| Marshal.dump(data_object, file) }
          pbMessage(_INTL("Successfully saved #{data_object_name} #{chosen_name}."))
          break
        end
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
    if (@current_screen == :PlayerTrainerPartySelection || @current_screen == :OpponentTrainerPartySelection) && @parties[getActiveTrainerIndex][i]
      poke = @parties[getActiveTrainerIndex][i]
      if @sprites["pokemonIcon#{i}"].nil?
        icon_sprite = PokemonIconSprite.new(poke, @viewport)
        icon_sprite.setOffset(PictureOrigin::CENTER)
        icon_sprite.x = 44 + 32 + (i % 2 == 0 ? 0 : 64)
        icon_sprite.y = 84 + 32 + (i / 2) * 64
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
    @current_screen = TeamBuilderTextBasedScreenConstants::SCREEN_LIST[0]
    @parties = []
    @bags = []
    for i in 0...2
      @parties.push([Pokemon.new(:PIKACHU, 20)])
      @bags.push(PokemonBag.new)
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
