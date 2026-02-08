# The Game module contains methods for saving and loading the game.
module Game
  # Initializes various global variables and loads the game data.
  def self.initialize
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    pbLoadBattleAnimations
    Compiler.cache_map_mirrors if $DEBUG
    GameData.load_all
    map_file = sprintf("Data/Map%03d.rxdata", $data_system.start_map_id)
    if $data_system.start_map_id == 0 || !pbRgssExists?(map_file)
      raise _INTL("No starting position was set in the map editor.")
    end
    self.load_audio_metadata
  end

  # Loads bootup data from save file (if it exists) or creates bootup data (if
  # it doesn't).
  def self.set_up_system
    SaveData.move_old_windows_save if System.platform[/Windows/]
    save_data = (SaveData.exists?) ? SaveData.read_from_file(SaveData.get_save_file_path) : {}
    if save_data.empty?
      SaveData.initialize_bootup_values
    else
      SaveData.load_bootup_values(save_data)
    end
    # Set resize factor
    pbSetResizeFactor([$PokemonSystem.screensize, 4].min)
    # Set language (and choose language if there is no save file)
    if Settings::LANGUAGES.length >= 2
      $PokemonSystem.language = pbChooseLanguage if save_data.empty?
      pbLoadMessages("Data/" + Settings::LANGUAGES[$PokemonSystem.language][1])
    end
  end

  # Called when starting a new game. Initializes global variables
  # and transfers the player into the map scene.
  def self.start_new
    if $game_map&.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $game_temp.begun_new_game = true
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $stats.play_sessions += 1
    $map_factory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
  end

  def self.start_runner_mode
    $game_switches[Settings::NO_MONEY_LOSS] = true
    if $game_temp.begun_new_game
      pbAddPokemonSilent(:KUUBY, 5)
      pbAddPokemonSilent(:TWIGIT, 5)
      pbAddPokemonSilent(:KIKRO, 5)
      $bag.add(:TRUEENIGMACHAIN)
    else
      # save_data = SaveData.read_from_file(SaveData::FILE_PATH)
    end
    skip_battle_anim = false
    while true
      play_next_battle_BGM_from_saved_preference
      setBattleRule("endlessmode")
      setBattleRule("canLose")
      setBattleRule("skipplayersendout") if skip_battle_anim
      did_player_win = WildBattle.start(getRandomPokemonForRunnerMode(3), skip_battle_anim:)
      if !did_player_win
        # Disable the auto-run event on Endless Mode map. Without this, even after calling the title screen,
        # the event still gets triggered and starts a new battle.
        pbMapInterpreter.pbSetSelfSwitch(1, "A", true, 181)
        $game_temp.title_screen_calling = true
        $game_temp.begun_new_game = false
        return
      end
      $PokemonGlobal.runnerModeBattleCounter += 1
      skip_battle_anim = true
      pbUpdateSaveDate(Time.now)
      self.save
    end
  end

  # Loads the game from the given save data and starts the map scene.
  # @param save_data [Hash] hash containing the save data
  # @raise [SaveData::InvalidValueError] if an invalid value is being loaded
  def self.load(save_data)
    validate save_data => Hash
    SaveData.load_all_values(save_data)
    $stats.play_sessions += 1
    self.load_map
    pbAutoplayOnSave
    $game_map.update
    $PokemonMap.updateMap
    $scene = Scene_Map.new
  end

  # Loads and validates the map. Called when loading a saved game.
  def self.load_map
    $game_map = $map_factory.map
    magic_number_matches = ($game_system.magic_number == $data_system.magic_number)
    if !magic_number_matches || $PokemonGlobal.safesave
      if pbMapInterpreterRunning?
        pbMapInterpreter.setup(nil, 0)
      end
      begin
        $map_factory.setup($game_map.map_id)
      rescue Errno::ENOENT
        if $DEBUG
          pbMessage(_INTL("Map {1} was not found.", $game_map.map_id))
          map = pbWarpToMap
          exit unless map
          $map_factory.setup(map[0])
          $game_player.moveto(map[1], map[2])
        else
          raise _INTL("The map was not found. The game cannot continue.")
        end
      end
      $game_player.center($game_player.x, $game_player.y)
    else
      $map_factory.setMapChanged($game_map.map_id)
    end
    if $game_map.events.nil?
      raise _INTL("The map is corrupt. The game cannot continue.")
    end
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    pbUpdateVehicle
  end

  # Saves the game. Returns whether the operation was successful.
  # @param save_file [String] the save file path
  # @param safe [Boolean] whether $PokemonGlobal.safesave should be set to true
  # @return [Boolean] whether the operation was successful
  # @raise [SaveData::InvalidValueError] if an invalid value is being saved
  def self.save(save_file = nil, safe: false)
    save_file = SaveData.get_save_file_path if save_file.nil?
    validate save_file => String, safe => [TrueClass, FalseClass]
    $PokemonGlobal.safesave = safe
    $game_system.save_count += 1
    $game_system.magic_number = $data_system.magic_number
    $stats.set_time_last_saved
    begin
      SaveData.save_to_file(save_file)
      Graphics.frame_reset
    rescue IOError, SystemCallError
      $game_system.save_count -= 1
      return false
    end
    return true
  end

  def self.load_audio_metadata
    $audio_metadata_map = {}
    files = []
    Dir.chdir("Audio/BGM/") {
      Dir.glob("*.ogg") { |f| files.push(f) }
      Dir.glob("*.wav") { |f| files.push(f) }
      Dir.glob("*.mid") { |f| files.push(f) }
      Dir.glob("*.midi") { |f| files.push(f) }
    }
    files.each do |f|
      file_path = "Audio/BGM/" + f
      file_path_without_extension = "Audio/BGM/" + f.chomp(File.extname(f))
      if $audio_metadata_map.key?(file_path_without_extension)
        raise _INTL("Found duplicate entries for file {1} when saving audio metadata.")
      end
      $audio_metadata_map[file_path_without_extension] = get_audio_metadata_for_file_path(file_path)
    end
  end
end
