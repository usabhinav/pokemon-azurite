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
      # Make sure each Pokemon has at least one non-Normal damaging move so that early Ghost-types aren't guaranteed to win
      $player.party.each do |p|
        next if p.moves.any? { |m| m.base_damage > 0 && m.type != :NORMAL }
        move_to_learn = p.getMoveList.find do |m|
          move_data = GameData::Move.get(m[1])
          next move_data.base_damage > 0 && move_data.type != :NORMAL
        end
        p.learn_move(move_to_learn[1])
      end
      $player.money = 1000
      $bag.add(:POKEBALL, 5)
      $bag.add(:GREYSCALE)
      $bag.add(:MEGAKEYSTONE)
      $PokemonGlobal.runnerModeNextPokemon = getRandomPokemonForRunnerMode(3, $PokemonGlobal.runnerModeBattleCounter)
    end
    skip_battle_anim = false
    while true
      if $PokemonGlobal.runnerModeBattleCounter == 101
        pbMessage(_INTL("Congratulations! You have successfully made your way through 100 grueling battles!"))
        pbMessage(_INTL("From here on out, you will continue to face wild Pokémon for as long as you'd like."))
        pbMessage(_INTL("You can also start a new journey, knowing that you have overcome every obstacle that has come your way!"))
        pbMessage(_INTL("Thank you for playing all the way until the end! And thanks for your continued support throughout our journey!"))
        pbStartCredits
      end
      self.runner_mode_show_options_in_between_battles
      if $PokemonGlobal.runnerModeBattleCounter > 1
        self.autosave_runner_mode
      end
      did_player_win = self.start_runner_mode_battle(skip_battle_anim)
      if !did_player_win
        self.go_back_to_title_from_runner_mode
        return
      end
      $PokemonGlobal.runnerModeBattleCounter += 1
      skip_battle_anim = true
      if $PokemonGlobal.runnerModeBattleCounter == 11
        pbReceiveItem(:EXPALL)
        pbReceiveItem(:EXPSHARE)
        pbReceiveItem(:EXPCHARM)
      end
      if $PokemonGlobal.runnerModeBattleCounter == 41
        pbReceiveItem(:EQUALIZERM)
        pbReceiveItem(:EQUALIZERC)
      end
      # Heal every 10 rounds
      if $PokemonGlobal.runnerModeBattleCounter % 10 == 1
        pbMEPlay("Pokemon Healing")
        $player.heal_party
        pbWait(100)
      end
      self.autosave_runner_mode
    end
  end

  def self.autosave_runner_mode
    pbUpdateSaveDate(Time.now)
    self.save
    $scene.spriteset.addUserSprite(Autosave.new)
  end

  def self.go_back_to_title_from_runner_mode
    # Disable the auto-run event on Endless Mode map. Without this, even after calling the title screen,
    # the event still gets triggered and starts a new battle.
    pbMapInterpreter.pbSetSelfSwitch(1, "A", true, 181)
    $game_temp.title_screen_calling = true
    $game_temp.begun_new_game = false
  end

  def self.start_runner_mode_battle(skip_battle_anim)
    static_encounter_map = {
      5 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new([:BULBASAUR, :CHARMANDER, :SQUIRTLE].sample, level)
          poke.makeAlbino
          next poke
        }
      },
      8 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:SLOOF, level)
          next poke
        }
      },
      10 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:GIRAFARIG, level)
          poke.form = 1
          poke.ability_index = 2
          poke.forget_all_moves
          poke.learn_move(:REST)
          poke.learn_move(:SLEEPTALK)
          poke.learn_move(:BODYSLAM)
          poke.learn_move(:STOMP)
          poke.status = :SLEEP
          poke.statusCount = 4
          next poke
        }
      },
      13 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:PIKACHU, level)
          poke.makeAlbino
          next poke
        }
      },
      15 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:VARYMITE, level)
          poke.learn_move(:DIMENSIONALGAP)
          next poke
        }
      },
      18 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:DITTO, level)
          poke.learn_move(:TRANSFORM)
          next poke
        }
      },
      20 => {
        :type => :trainer,
        :trainer_battle_args => [:LEADER_Banyan, "Banyan"]
      },
      25 => {
        :type => :trainer,
        :trainer_battle_args => [:CAMPER, "Loof"],
        :pre_battle_script => proc {
          EliteBattle.set(:nextBattleScript, :LOOF)
          setBattleRule("double")
        },
        :battle_script_symbol => :LOOF
      },
      28 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new([:NIDORINA, :NIDORINO].sample, level)
          poke.makeAlbino
          next poke
        }
      },
      30 => {
        :type => :trainer,
        :trainer_battle_args => [:LEADER_Deiva, "Deiva"]
      },
      35 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:AEGISLASH, level)
          poke.form = 3
          poke.learn_move(:DELAYEDATTACK)
          next poke
        }
      },
      40 => {
        :type => :trainer,
        :trainer_battle_args => [:LEADER_Koko, "Koko"]
      },
      45 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:PHANTITUTE, level)
          next poke
        }
      },
      50 => {
        :type => :trainer,
        :trainer_battle_args => [:LEADER_Ruyter, "Ruyter"]
      },
      55 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:LUMENY, level)
          next poke
        }
      },
      60 => {
        :type => :trainer,
        :trainer_battle_args => [:LEADER_Gaia, "Gaia"]
      },
      65 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:CELEBI, level)
          poke.forget_all_moves
          poke.learn_move(:TIMEBREAK)
          poke.learn_move(:ANCIENTPOWER)
          poke.learn_move(:RECOVER)
          poke.learn_move(:LEECHSEED)
          next poke
        }
      },
      70 => {
        :type => :trainer,
        :trainer_battle_args => [:LEADER_Marianne, "Marianne"]
      },
      75 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:OKEANIOS, level)
          next poke
        }
      },
      80 => {
        :type => :trainer,
        :trainer_battle_args => [:LEADER_Bialas, "Bialas", :LEADER_Atlas, "Atlas"]
      },
      85 => {
        :type => :wild,
        :get_pokemon => proc { |level|
          poke = Pokemon.new(:KYAZURA, level)
          next poke
        }
      },
      90 => {
        :type => :trainer,
        :trainer_battle_args => [:LEADER_Lucien, "Lucien"]
      },
      96 => {
        :type => :trainer,
        :trainer_battle_args => [:ELITEFOUR_Olympia, "Olympia"]
      },
      97 => {
        :type => :trainer,
        :trainer_battle_args => [:ELITEFOUR_Nicolas, "Nicolas"]
      },
      98 => {
        :type => :trainer,
        :trainer_battle_args => [:ELITEFOUR_Bron, "Bron"]
      },
      99 => {
        :type => :trainer,
        :trainer_battle_args => [:ELITEFOUR_Dahlia, "Dahlia"]
      },
      100 => {
        :type => :trainer,
        :trainer_battle_args => [:CHAMPION_Aiden, "Aiden"]
      },
    }
    self.set_runner_mode_battle_music(static_encounter_map)
    setBattleRule("endlessmode")
    setBattleRule("canLose")
    setBattleRule("skipplayersendout") if skip_battle_anim
    if $game_system.getPlayingBGM.nil? || $PokemonGlobal.nextBattleBGM != $game_system.getPlayingBGM.name
      setBattleRule("showbgmwindow")
    end
    EliteBattle.set(:nextBattleBack, { "backdrop" => "AzuriteArena" })
    # The general pattern is that the level increments by 1 except for every 9th and 10th battle, where it stays constant.
    # Waves 1-10: 3, 3, 3, 4, 5, 6, 7, 8, 8, 8
    # Waves 11-20: 9, 10, 11, 12, 13, 14, 15, 16, 16, 16
    # ...
    # Waves 91-100: 73, 74, 75, 76, 77, 78, 79, 80, 80, 80
    # Waves 101+: 80
    next_round = $PokemonGlobal.runnerModeBattleCounter + 1
    next_opponent_level_cap = [(((next_round - 1) / 10).floor + 1) * 8, 80].min
    unconstrained_level = ((next_round / 10).floor) * 8 + (next_round % 10)
    next_opponent_level = unconstrained_level.clamp(3, next_opponent_level_cap)
    # Lock in the next Pokemon
    next_pokemon_to_lock = getRandomPokemonForRunnerMode(next_opponent_level, next_round)
    if static_encounter_map.key?(next_round) && static_encounter_map[next_round][:type] == :wild
      next_pokemon_to_lock = static_encounter_map[next_round][:get_pokemon].call(next_opponent_level)
    end
    # Start the battle
    battle_ret = nil
    if static_encounter_map.key?($PokemonGlobal.runnerModeBattleCounter)
      encounter_definition = static_encounter_map[$PokemonGlobal.runnerModeBattleCounter]
      encounter_definition[:pre_battle_script].call if encounter_definition[:pre_battle_script]
      if encounter_definition[:type] == :trainer
        battle_ret = TrainerBattle.start(*encounter_definition[:trainer_battle_args])
      else
        battle_ret = WildBattle.start($PokemonGlobal.runnerModeNextPokemon, skip_battle_anim:)
      end
    else
      battle_ret = WildBattle.start($PokemonGlobal.runnerModeNextPokemon, skip_battle_anim:)
    end
    $PokemonGlobal.runnerModeNextPokemon = next_pokemon_to_lock
    return battle_ret
  end

  def self.set_runner_mode_battle_music(static_encounter_map)
    # Use trainer BGM for trainer battles
    if static_encounter_map.has_key?($PokemonGlobal.runnerModeBattleCounter) &&
       static_encounter_map[$PokemonGlobal.runnerModeBattleCounter][:type] == :trainer
      return
    end
    if is_battle_BGM_set_to_specific_track
      $PokemonGlobal.nextBattleBGM = get_next_battle_BGM_from_saved_preference
      return
    end
    # The track changes every 10 rounds
    track_list = [
      "Battle - 001 Wild Pokemon Battle",
      "Battle - 002 Trainer Battle",
      "Battle - 033 Lumeny Battle",
      "Battle - 039 Low Aura Boss",
      "Battle - 040 High Aura Boss",
      "battle1",
      # Repeat
      "Battle - 001 Wild Pokemon Battle",
      "Battle - 033 Lumeny Battle",
      "Battle - 039 Low Aura Boss",
      "Battle - 040 High Aura Boss",
    ]
    $PokemonGlobal.nextBattleBGM = track_list[($PokemonGlobal.runnerModeBattleCounter - 1) / 10]
  end

  def self.runner_mode_show_options_in_between_battles
    header_window = Window_AdvancedTextPokemon.new(_INTL("Round {1}", $PokemonGlobal.runnerModeBattleCounter))
    header_window.letterbyletter = false
    header_window.visible = true
    header_window.update
    msgwindow = pbCreateMessageWindow
    msgwindow.text = _INTL("Manage your party and items before proceeding to the next round.")
    msgwindow.letterbyletter = false
    pokemon_party_sprites = PokemonPartyIconSprites.new(nil, $player.party, 104, 84, false)
    $scene.spriteset.addUserSprite(pokemon_party_sprites)
    loop do
      commands = []
      # Party
      commands[cmdParty = commands.length] = _INTL("Party")
      # Bag
      commands[cmdBag = commands.length] = _INTL("Bag")
      # Shop
      commands[cmdShop = commands.length] = _INTL("Shop")
      # Continue
      commands[cmdContinue = commands.length] = _INTL("Continue")
      command = pbShowCommands(msgwindow, commands)
      case command
      when cmdParty
        pbPokemonScreen
        pokemon_party_sprites.refreshPokemonIconSprites
      when cmdBag
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene, $bag)
          screen.pbStartScreen
        }
      when cmdShop
        shop_item_map = {
          :POTION => {
            :level => 1,
            :mult => 0.2,
          },
          :SUPERPOTION => {
            :level => 21,
            :mult => 0.45,
          },
          :HYPERPOTION => {
            :level => 61,
            :mult => 0.8,
          },
          :MAXPOTION => {
            :level => 81,
            :mult => 1.5,
          },
          :REVIVE => {
            :level => 1,
            :mult => 2,
          },
          :MAXREVIVE => {
            :level => 61,
            :mult => 2.75,
          },
          :ETHER => {
            :level => 1,
            :mult => 0.4,
          },
          :MAXETHER => {
            :level => 51,
            :mult => 1,
          },
          :ELIXIR => {
            :level => 51,
            :mult => 1,
          },
          :MAXELIXIR => {
            :level => 81,
            :mult => 2.5,
          },
          :FULLHEAL => {
            :level => 21,
            :mult => 1,
          },
          :FULLRESTORE => {
            :level => 81,
            :mult => 2.25,
          },
          :POKEBALL => {
            :level => 1,
            :mult => 0.2,
          },
          :GREATBALL => {
            :level => 21,
            :mult => 0.6,
          },
          :ULTRABALL => {
            :level => 61,
            :mult => 1,
          },
        }
        shop_items_to_display = []
        shop_item_map.each do |item_id, item_definition|
          next if $PokemonGlobal.runnerModeBattleCounter < item_definition[:level]
          shop_items_to_display.push(item_id)
          # Using Pokerogue's formula, but without the exponential modifier to reduce complexity
          price = ((10 * ($PokemonGlobal.runnerModeBattleCounter - 1) + 175).floor(-1) * item_definition[:mult].to_f).floor
          pbMapInterpreter.setPrice(item_id, price)
        end
        pbPokemonMartForRunnerMode(shop_items_to_display)
      else
        break
      end
    end
    pokemon_party_sprites.dispose
    pbDisposeMessageWindow(msgwindow)
    pbDisposeMessageWindow(header_window)
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
