module SaveDataObjectManagement
  TEAM_DATA_OBJECT_NAME = "team"
  BAG_DATA_OBJECT_NAME = "bag"
  SAVE_FILE_EXTENSION = ".rxdata"

  SAVE_FILE_PREFIX_MAP = {
    TEAM_DATA_OBJECT_NAME => "TEAM_",
    BAG_DATA_OBJECT_NAME => "BAG_",
  }

  def self.get_save_file_name(data_object_name, input_name)
    return "#{SAVE_FILE_PREFIX_MAP[data_object_name]}#{input_name}#{SAVE_FILE_EXTENSION}"
  end

  def self.is_save_file?(data_object_name, filename)
    return filename.start_with?(SAVE_FILE_PREFIX_MAP[data_object_name])
  end

  def self.get_save_name_from_filename(data_object_name, filename)
    return filename.sub(SAVE_FILE_PREFIX_MAP[data_object_name], "").sub(SAVE_FILE_EXTENSION, "")
  end

  def self.get_data_object_commands(data_object_name)
    commands = []
    Dir.foreach(RTP.getSaveFolder) do |entry|
      next if !SaveDataObjectManagement.is_save_file?(data_object_name, entry)
      commands.push(SaveDataObjectManagement.get_save_name_from_filename(data_object_name, entry))
    end
    return commands
  end

  def self.load_data_object(data_object_name, data_object_save_name)
    data_object = nil
    save_filename = RTP.getSaveFileName(SaveDataObjectManagement.get_save_file_name(data_object_name, data_object_save_name))
    File.open(save_filename) do |file|
      data_object = Marshal.load(file)
    end
    return data_object
  end

  def self.save_data_object(data_object, data_object_name, data_object_save_name)
    chosen_save_filename = RTP.getSaveFileName(SaveDataObjectManagement.get_save_file_name(data_object_name, data_object_save_name))
    File.open(chosen_save_filename, "wb") { |file| Marshal.dump(data_object, file) }
  end

  def self.save_data_object_with_new_name(data_object_name, data_object, previous_save_name = nil)
    ret = false
    while true
      chosen_name = pbMessageFreeText("Enter a name for this #{data_object_name}.", "", false, 25)
      if chosen_name.empty?
        break
      elsif !chosen_name.match?(/^[a-zA-Z0-9]*$/)
        pbMessage("Name can only contain alphanumeric values.")
      elsif previous_save_name && previous_save_name == chosen_name
        pbMessage("Name must not match previous name #{previous_save_name}.")
      else
        chosen_save_filename = RTP.getSaveFileName(SaveDataObjectManagement.get_save_file_name(data_object_name, chosen_name))
        if !File.file?(chosen_save_filename) || pbConfirmMessageSerious(_INTL("WARNING: There is already a saved #{data_object_name} with name #{chosen_name}. Overwrite this #{data_object_name}?"))
          self.save_data_object(data_object, data_object_name, chosen_name)
          pbMessage(_INTL("Successfully saved #{data_object_name} #{chosen_name}."))
          ret = true
          break
        end
      end
    end
    return ret
  end

  def self.delete_data_object(data_object_name, data_object_save_name)
    chosen_save_filename = RTP.getSaveFileName(SaveDataObjectManagement.get_save_file_name(data_object_name, data_object_save_name))
    File.delete(chosen_save_filename)
  end

  def self.delete_data_object_with_confirmation(data_object_name, data_object_save_name)
    if pbConfirmMessageSerious(_INTL("Delete #{data_object_name} #{data_object_save_name}?"))
      self.delete_data_object(data_object_name, data_object_save_name)
      pbMessage(_INTL("Deleted #{data_object_name} #{data_object_save_name}."))
      return true
    end
    return false
  end
end
