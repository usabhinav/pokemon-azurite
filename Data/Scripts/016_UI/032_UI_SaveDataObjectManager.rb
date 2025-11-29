class SaveDataObjectManagerScreen
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def endScene
    pbFadeOutAndHide(@sprites)
    pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbShowCommands(helptext, commands, index = 0)
    ret = -1
    @sprites["textbox"].text = helptext
    @sprites["textbox"].visible = true
    using(cmdwindow = Window_CommandPokemon.new(commands)) {
      cmdwindow.z = @viewport.z + 1
      cmdwindow.index = index
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
    @sprites["textbox"].visible = false
    return ret
  end

  def pbScene
    loop do
      commands = []
      # Teams
      commands[cmdTeams = commands.length] = _INTL("Teams")
      # Bags
      commands[cmdBags = commands.length] = _INTL("Bags")
      # Exit
      commands[cmdExit = commands.length] = _INTL("Exit")
      command = pbShowCommands(_INTL("Choose which saved data to manage."), commands)
      case command
      when cmdTeams
        actionsForDataObject(SaveDataObjectManagement::TEAM_DATA_OBJECT_NAME)
      when cmdBags
        actionsForDataObject(SaveDataObjectManagement::BAG_DATA_OBJECT_NAME)
      else
        break
      end
    end
  end
  
  def actionsForDataObject(data_object_name)
    commands = SaveDataObjectManagement.get_data_object_commands(data_object_name)
    commands.push("Cancel")
    while true
      command = pbShowCommands(_INTL("Select a #{data_object_name}."), commands)
      if command == -1 || command == commands.length - 1
        break
      else
        chosen_name = commands[command]
        should_break = actionsForSpecificDataObject(data_object_name, chosen_name)
        break if should_break
      end
    end
  end

  def actionsForSpecificDataObject(data_object_name, data_object_save_name)
    loop do
      commands = []
      # Edit
      commands[cmdEdit = commands.length] = _INTL("Edit #{data_object_name}")
      # Rename
      commands[cmdRename = commands.length] = _INTL("Rename #{data_object_name}")
      # Delete
      commands[cmdDelete = commands.length] = _INTL("Delete #{data_object_name}")
      # Cancel
      commands[cmdCancel = commands.length] = _INTL("Cancel")
      command = pbShowCommands(_INTL("Do what with #{data_object_name} #{data_object_save_name}?"), commands)
      case command
      when cmdEdit
        data_object = SaveDataObjectManagement.load_data_object(data_object_name, data_object_save_name)
        if data_object_name == SaveDataObjectManagement::TEAM_DATA_OBJECT_NAME
          pbPokemonScreenForTeamBuilder(data_object)
          SaveDataObjectManagement.save_data_object(data_object, data_object_name, data_object_save_name)
        elsif data_object_name == SaveDataObjectManagement::BAG_DATA_OBJECT_NAME
          pbBagScreenForTeamBuilder(data_object)
          if pbConfirmMessage(_INTL("Save changes to #{data_object_name} #{data_object_save_name}?"))
            SaveDataObjectManagement.save_data_object(data_object, data_object_name, data_object_save_name)
            pbMessage(_INTL("Successfully saved #{data_object_name} #{data_object_save_name}."))
          end
        end
      when cmdRename
        data_object = SaveDataObjectManagement.load_data_object(data_object_name, data_object_save_name)
        did_save = SaveDataObjectManagement.save_data_object_with_new_name(data_object_name, data_object, data_object_save_name)
        if did_save
          SaveDataObjectManagement.delete_data_object(data_object_name, data_object_save_name)
          return true
        end
      when cmdDelete
        did_delete = SaveDataObjectManagement.delete_data_object_with_confirmation(data_object_name, data_object_save_name)
        return true if did_delete
      else
        break
      end
    end
    return false
  end

  def pbStartScene
    # Set up background and core sprites
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["textbox"] = pbCreateMessageWindow(@viewport)
    @sprites["textbox"].visible = false
    @sprites["textbox"].letterbyletter = false
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end

def pbStartSaveDataObjectManagerScreen
  pbFadeOutIn {
    scene = SaveDataObjectManagerScreen.new
    scene.pbStartScene
    scene.pbScene
    scene.endScene
  }
end
