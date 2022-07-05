class GuildStorageScene < PokemonStorageScene
  def pbAppoint(selected,partyindex)
    # pbHold(selected)
    # pbDropDownPartyTab
    # pbPartySetArrow(@sprites["arrow"],partyindex)
    # pbPlace([-1,partyindex],nil)
    # pbHidePartyTab
    # @sprites["box"].setPokemon(selected[1],heldpokesprite)
  end
end

class GuildStorageScreen < PokemonStorageScreen
  attr_reader :guild
  
  def initialize(scene, storage, guild)
    super(scene, storage)
    @guild = guild
  end

  def pbStartScreen(command)
    $game_temp.in_storage = true
    @heldpkmn = nil
    case command
    when 0, 1, 2   # Appoint Guild Master, Guild Keeper, or Guild member
      @scene.pbStartBox(self, 1)
      loop do
        selected = @scene.pbSelectBox(@storage.party)
        if selected.nil?
          next if pbConfirm(_INTL("Continue Box operations?"))
          break
        else
          case selected[0]
          when -2   # Party Pokémon
            pbDisplay(_INTL("Which one will you take?"))
            next
          when -3   # Close box
            if pbConfirm(_INTL("Exit from the Box?"))
              pbSEPlay("PC close")
              break
            end
            next
          when -4   # Box name
            pbBoxCommands
            next
          end
          pokemon = @storage[selected[0], selected[1]]
          next if !pokemon
          minicommand = pbShowCommands(_INTL("{1} is selected.", pokemon.name),
                                       [(command == 2 ? _INTL("Add") : _INTL("Appoint")),
                                        _INTL("Summary"),
                                        _INTL("Cancel")])
          case minicommand
          when 0
            if command == 2
              pbAddToGuild(selected)
            else
              pbAppoint(selected, command)
            end
          when 1 then pbSummary(selected, nil)
          end
        end
      end
      @scene.pbCloseBox
    end
    $game_temp.in_storage = false
  end

  def pbAppoint(selected, command)
    box = selected[0]
    index = selected[1]
    if box == -1
      raise _INTL("Can't withdraw from party...")
    end
    if @storage[box,index].egg?
      @scene.pbDisplay(_INTL("This is an egg!"))
      return
    end
    @scene.pbAppoint(selected, @storage.party.length)
    box = selected[0]
    index = selected[1]
    if command == 0
      oldmaster = @guild.guildMaster
      @guild.guildMaster = @storage[box, index]
      @storage.pbDelete(box, index)
      @storage[box, index] = oldmaster if oldmaster
      @scene.pbDisplay(_INTL("{1} is the new Guild Master!", @guild.guildMaster.name))
    elsif command == 1
      oldkeeper = @guild.guildKeeper
      @guild.guildKeeper = @storage[box, index]
      @storage.pbDelete(box, index)
      @storage[box, index] = oldkeeper if oldkeeper
      @scene.pbDisplay(_INTL("{1} is the new Guild Keeper!", @guild.guildKeeper.name))
    end
    @scene.pbHardRefresh
  end
  
  def pbAddToGuild(selected)
    box=selected[0]
    index=selected[1]
    if box==-1
      raise _INTL("Can't withdraw from party...");
    end
    if @storage[box, index].egg?
      @scene.pbDisplay(_INTL("This is an egg!"))
      return
    end
    if @guild.guildMembers.length >= 12 || (@guild.guildMembers.length >= 8 && @guild.id < 4)
      @scene.pbDisplay(_INTL("You can't add any more Guild Members at this time!"))
      return
    end
    box = selected[0]
    index = selected[1]
    @guild.guildMembers[@guild.guildMembers.length] = @storage[box,index]
    @storage.pbDelete(box, index)
    @scene.pbDisplay(_INTL("{1} has joined the guild!", @guild.guildMembers[@guild.guildMembers.length - 1].name))
    @scene.pbHardRefresh
  end
end
