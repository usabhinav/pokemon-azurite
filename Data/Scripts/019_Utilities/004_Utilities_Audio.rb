SAVE_BATTLE_BGM_FILE_NAME = "SAVE_BATTLE_BGM.txt"
RANDOMIZE_BGM_CONSTANT = "RANDOMIZE_BGM"

ESSENTIALS_BATTLE_TRACKS = [
  "002-Battle02",
  "Battle Champion",
  "Battle Elite",
  "Battle Gym Leader",
  "Battle roaming",
  "Battle trainer",
  "Battle wild",
  "battle1",
  "Triple Triad",
]

def get_audio_metadata_for_file_path(file_path)
  if !file_path.end_with?(".ogg")
    return nil
  end
  decoder = OggDecoder.new(file_path, true)
  return decoder.comment_header
end

def is_audio_file_azurite_ost(filename)
  return $audio_metadata_map["Audio/BGM/" + filename.chomp(File.extname(filename))]&.get_one("ALBUM") == "Project Azurite OST"
end

def save_battle_BGM(audio_filename)
  save_filename = RTP.getSaveFileName(SAVE_BATTLE_BGM_FILE_NAME)
  File.open(save_filename, "w") { |file| file.write(audio_filename) }
end

def load_battle_BGM
  save_filename = RTP.getSaveFileName(SAVE_BATTLE_BGM_FILE_NAME)
  if !File.exist?(save_filename)
    # Default to random Azurite tracks
    return RANDOMIZE_BGM_CONSTANT
  end
  return File.read(save_filename).chomp
end

def randomize_battle_BGM
  save_battle_BGM(RANDOMIZE_BGM_CONSTANT)
end

def is_battle_BGM_set_to_specific_track
  return load_battle_BGM != RANDOMIZE_BGM_CONSTANT
end

def get_display_name_for_battle_BGM(battle_bgm_save_name)
  if battle_bgm_save_name == RANDOMIZE_BGM_CONSTANT
    return "Random track"
  end
  if is_audio_file_azurite_ost(battle_bgm_save_name)
    return $audio_metadata_map["Audio/BGM/" + battle_bgm_save_name].get_one("TITLE")
  end
  return battle_bgm_save_name
end

def get_artist_name_for_battle_BGM(battle_bgm_save_name)
  if is_audio_file_azurite_ost(battle_bgm_save_name)
    return $audio_metadata_map["Audio/BGM/" + battle_bgm_save_name].get_one("ARTIST")
  end
  return "Pokémon Essentials"
end

def get_random_battle_BGM_with_condition(condition_proc)
  battle_BGM_save_names = []
  $audio_metadata_map.keys.each do |filepath|
    filename = filepath.split("/").last
    battle_BGM_save_names.push(filename) if condition_proc.call(filename)
  end
  return battle_BGM_save_names.sample
end

def get_random_battle_BGM
  return get_random_battle_BGM_with_condition(Proc.new { |filename|
    ESSENTIALS_BATTLE_TRACKS.include?(filename) || (is_audio_file_azurite_ost(filename) && filename.start_with?("Battle - "))
  })
end

def get_next_battle_BGM_from_saved_preference
  battle_bgm_save_name = load_battle_BGM
  if battle_bgm_save_name == RANDOMIZE_BGM_CONSTANT
    return get_random_battle_BGM
  end
  return battle_bgm_save_name
end

def play_next_battle_BGM_from_saved_preference
  $game_system.setDefaultBGM(nil)
  $game_system.bgm_stop
  $PokemonGlobal.nextBattleBGM = get_next_battle_BGM_from_saved_preference
end
