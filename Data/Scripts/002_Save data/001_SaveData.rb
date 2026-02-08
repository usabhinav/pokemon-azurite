# The SaveData module is used to manipulate save data. It contains the {Value}s
# that make up the save data and {Conversion}s for resolving incompatibilities
# between Essentials and game versions.
# @see SaveData.register
# @see SaveData.register_conversion
module SaveData
  # Contains the file path of the save file.
  FILE_PATH = if File.directory?(System.data_directory)
                System.data_directory + "/Game.rxdata"
              else
                "./Game.rxdata"
              end
  # Contains the file path of the save file for the runner mode.
  FILE_PATH_RUNNER_MODE = if File.directory?(System.data_directory)
                            System.data_directory + "/Game_RunnerMode.rxdata"
                          else
                            "./Game_RunnerMode.rxdata"
                          end
  # Contains the file path of the save file for custom battle mode.
  # This is not a really a save file that the player would use.
  # The purpose of this is to handle when the system emergency saves if it crashes during the custom battle mode.
  # In this case, it should not mistakenly overwrite one of the other save files (main game or endless mode).
  FILE_PATH_CUSTOM_BATTLE_MODE = if File.directory?(System.data_directory)
                                   System.data_directory + "/Game_CustomBattleMode.rxdata"
                                 else
                                   "./Game_CustomBattleMode.rxdata"
                                 end
  
  def self.get_save_file_path
    return FILE_PATH if $game_temp.nil?
    return {
      :MAIN_GAME           => FILE_PATH,
      :ENDLESS_MODE        => FILE_PATH_RUNNER_MODE,
      :CUSTOM_BATTLE_MODE  => FILE_PATH_CUSTOM_BATTLE_MODE,
    }[$game_temp.game_mode_type]
  end

  # @return [Boolean] whether the save file exists
  def self.exists?(file_path = nil)
    file_path = self.get_save_file_path if file_path.nil?
    return File.file?(file_path)
  end

  # Fetches the save data from the given file.
  # Returns an Array in the case of a pre-v19 save file.
  # @param file_path [String] path of the file to load from
  # @return [Hash, Array] loaded save data
  # @raise [IOError, SystemCallError] if file opening fails
  def self.get_data_from_file(file_path)
    validate file_path => String
    save_data = nil
    File.open(file_path) do |file|
      data = Marshal.load(file)
      if data.is_a?(Hash)
        save_data = data
        next
      end
      save_data = [data]
      save_data << Marshal.load(file) until file.eof?
    end
    return save_data
  end

  # Fetches save data from the given file. If it needed converting, resaves it.
  # @param file_path [String] path of the file to read from
  # @return [Hash] save data in Hash format
  # @raise (see .get_data_from_file)
  def self.read_from_file(file_path)
    validate file_path => String
    save_data = get_data_from_file(file_path)
    save_data = to_hash_format(save_data) if save_data.is_a?(Array)
    if !save_data.empty? && run_conversions(save_data, file_path)
      File.open(file_path, "wb") { |file| Marshal.dump(save_data, file) }
    end
    return save_data
  end

  # Compiles the save data and saves a marshaled version of it into
  # the given file.
  # @param file_path [String] path of the file to save into
  # @raise [InvalidValueError] if an invalid value is being saved
  def self.save_to_file(file_path)
    validate file_path => String
    save_data = self.compile_save_hash
    File.open(file_path, "wb") { |file| Marshal.dump(save_data, file) }
  end

  # Deletes the save file (and a possible .bak backup file if one exists)
  # @raise [Error::ENOENT]
  def self.delete_file(file_path)
    File.delete(file_path)
    File.delete(file_path + ".bak") if File.file?(file_path + ".bak")
  end

  # Converts the pre-v19 format data to the new format.
  # @param old_format [Array] pre-v19 format save data
  # @return [Hash] save data in new format
  def self.to_hash_format(old_format)
    validate old_format => Array
    hash = {}
    @values.each do |value|
      data = value.get_from_old_format(old_format)
      hash[value.id] = data unless data.nil?
    end
    return hash
  end

  # Moves a save file from the old Saved Games folder to the new
  # location specified by {FILE_PATH}. Does nothing if a save file
  # already exists in {FILE_PATH}.
  def self.move_old_windows_save
    return if File.file?(FILE_PATH)
    game_title = System.game_title.gsub(/[^\w ]/, "_")
    home = ENV["HOME"] || ENV["HOMEPATH"]
    return if home.nil?
    old_location = File.join(home, "Saved Games", game_title)
    return unless File.directory?(old_location)
    old_file = File.join(old_location, "Game.rxdata")
    return unless File.file?(old_file)
    File.move(old_file, FILE_PATH)
  end
end
