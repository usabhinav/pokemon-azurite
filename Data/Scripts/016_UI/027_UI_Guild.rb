class GuildScreenPokemonSprite < Sprite
  def initialize(guild, viewport = nil)
    super(viewport)
    @guild = guild
    @turn_ticks = 1
    @direction = 2
    @bob_ticks = 1
    @bob_height = 0
    update
  end

  def getBitmapFile(poke)
    return GameData::Species.ow_sprite_filename(poke.species, poke.form, poke.gender, poke.shiny?, poke.shadow)
  end

  def update
    super
    @turn_ticks -= 1
    if @turn_ticks == 0
      @turn_ticks = rand(100) + 150
      @direction = rand(4)
    end
    @bob_ticks -= 1
    if @bob_ticks == 8
      @bob_height = 2
    elsif @bob_ticks == 0
      @bob_ticks = 16
      @bob_height = 0
    end
  end
end

class GuildScreenMasterSprite < GuildScreenPokemonSprite
  def update
    super
    self.visible = (@guild.guildMaster && !@guild.inDungeon?)
    return if !self.visible
    bitmap = Bitmap.new(getBitmapFile(@guild.guildMaster))
    self.bitmap = bitmap
    self.src_rect = Rect.new(0, @direction*self.bitmap.height/4, bitmap.width/4, bitmap.height/4)
    self.x = 366 - bitmap.width/8
    self.y = 94 - bitmap.height/8 + @bob_height
  end
end

class GuildScreenKeeperSprite < GuildScreenPokemonSprite
  def update
    super
    self.visible = !@guild.guildKeeper.nil?
    return if !self.visible
    bitmap = Bitmap.new(getBitmapFile(@guild.guildKeeper))
    self.bitmap = bitmap
    self.src_rect = Rect.new(0, @direction*self.bitmap.height/4, bitmap.width/4, bitmap.height/4)
    self.x = 418 - bitmap.width/8
    self.y = 109 - bitmap.height/8 + @bob_height
  end
end

class GuildScreenMemberSprite < GuildScreenPokemonSprite
  def initialize(index, guild, viewport = nil)
    super(guild, viewport)
    @index = index
    update
  end

  def update
    super
    return if !@index
    self.visible = (@guild.guildMembers[@index] && !@guild.inDungeon?)
    return if !self.visible
    xvalues = [291, 338, 386, 433]
    yvalues = [140, 187, 234]
    bitmap = Bitmap.new(getBitmapFile(@guild.guildMembers[@index]))
    self.bitmap = bitmap
    self.src_rect = Rect.new(0, @direction*self.bitmap.height/4, bitmap.width/4, bitmap.height/4)
    self.x = xvalues[@index % 4] - bitmap.width/8
    self.y = yvalues[(@index / 4).to_i] - bitmap.height/8 + @bob_height
  end
end

class GuildScreen
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def endScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        break
      elsif Input.trigger?(Input::LEFT)
        @guild.guildBackground -= 1
        @guild.guildBackground = 4 if @guild.guildBackground < 0
        drawGuild(@guild.guildBackground)
      elsif Input.trigger?(Input::RIGHT)
        @guild.guildBackground += 1
        @guild.guildBackground = 0 if @guild.guildBackground > 4
        drawGuild(@guild.guildBackground)
      elsif Input.trigger?(Input::MOUSELEFT) && !Mouse.getMousePos.nil?
        mousepos = Mouse.getMousePos
        x = mousepos[0]
        y = mousepos[1]
        if x > 110 && x < 180 && y > 0 && y < 70
          if @guild.inDungeon?
            pbMessage(_INTL("{1} in progress.", @guild.getCurrentDungeon.name))
          else
            pbDungeonMap
          end
        elsif x > 267 && x < 457 && y > 117 && y < 257
          if @guild.inDungeon?
            pbMessage(_INTL("Your guild is out in a dungeon!"))
          else
            command = pbMessage(_INTL("Would you like to add or remove guild members?"), ["Add", "Remove", "Cancel"], -1)
            case command
            when 0
              pbChooseGuildMembers
            when 1
              pbRemoveGuildMembers
            end
          end
        elsif x > 335 && x < 397 && y > 75 && y < 113
          if @guild.inDungeon?
            pbMessage(_INTL("Your guild is out in a dungeon!"))
          else
            if @guild.guildMaster.nil?
              command = pbMessage(_INTL("Would you like to appoint a Guild Master?"), ["Appoint", "Cancel"], -1)
              if command == 0
                pbChooseGuildMaster
              end
            else
              command = pbMessage(_INTL("What would you like to do?"), ["Change", "Remove", "Summary", "Talk", "Cancel"], -1)
              case command
              when 0
                pbChooseGuildMaster
              when 1
                pbRemoveGuildMaster
              when 2
                pbFadeOutIn {
                  summary_scene = PokemonSummary_Scene.new
                  summary_screen = PokemonSummaryScreen.new(summary_scene)
                  summary_screen.pbStartScreen([@guild.guildMaster], 0)
                }
              when 3
                # TODO: Implement "talk" feature using Following Pokemon code (same for Guild Keeper)
                # EventHandlers.trigger_2(:following_pkmn_talk, first_pkmn, random_val)
                pbMessage(_INTL("{1} seems happy.", @guild.guildMaster.name))
              end
            end
          end
        elsif x > 398 && x < 438 && y > 94 && y < 124
          if @guild.inDungeon?
            if @guild.guildKeeper.nil?
              pbMessage(_INTL("Your guild is out in a dungeon!"))
            else
              command = pbMessage(_INTL("What would you like to do?"), ["Summary", "Talk", "Cancel"], -1)
              case command
              when 0
                pbFadeOutIn {
                  summary_scene = PokemonSummary_Scene.new
                  summary_screen = PokemonSummaryScreen.new(summary_scene)
                  summary_screen.pbStartScreen([@guild.guildKeeper], 0)
                }
              when 1
                pbMessage(_INTL("{1} seems happy.", @guild.guildKeeper.name))
              end
            end
          else
            if @guild.guildKeeper.nil?
              command = pbMessage(_INTL("Would you like to appoint a Guild Keeper?"), ["Appoint", "Cancel"], -1)
              if command == 0
                pbChooseGuildKeeper
              end
            else
              command = pbMessage(_INTL("What would you like to do?"), ["Change", "Remove", "Summary", "Talk", "Cancel"], -1)
              case command
              when 0
                pbChooseGuildKeeper
              when 1
                pbRemoveGuildKeeper
              when 2
                pbFadeOutIn {
                  summary_scene = PokemonSummary_Scene.new
                  summary_screen = PokemonSummaryScreen.new(summary_scene)
                  summary_screen.pbStartScreen([@guild.guildKeeper], 0)
                }
              when 3
                pbMessage(_INTL("{1} seems happy.", @guild.guildKeeper.name))
              end
            end
          end
        elsif x > 25 && x < 197 && y > 303 && y < 358
          pbMessage(_INTL("Berry Patches successfully clicked. Congrats, I guess."))
        elsif x > 25 && x < 175 && y > 85 && y < 235
          pbGummiTable
        end
      end
    end
  end
  
  def pbStartScene(guild, trainer, storage, bag)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @guild=guild
    @trainer=trainer
    @storage=storage
    @bag=bag
    @sprites={}
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbFadeInAndShow(@sprites) { pbUpdate }
    @sprites["guildmaster"] = GuildScreenMasterSprite.new(@guild, @viewport)
    @sprites["guildkeeper"] = GuildScreenKeeperSprite.new(@guild, @viewport)
    for i in 0...12
      @sprites["guildmember#{i}"] = GuildScreenMemberSprite.new(i, @guild, @viewport)
    end
    drawGuild(@guild.guildBackground)
    if @guild.dungeonCompleted
      @guild.giveDungeonRewards(self, @trainer)
    end
    # TODO: Add fancy visual pop-up that guild has ranked up
    if @trainer.badge_count >= 4 && @guild.id == 0
      pbMessage(_INTL("The guild has ranked up!"))
      @guild.rankup
    end
    if @trainer.badge_count >= 6 && @guild.id == 1
      pbMessage(_INTL("The guild has ranked up!"))
      @guild.rankup
    end
    if @trainer.badge_count >= 8 && @guild.id == 2
      pbMessage(_INTL("The guild has ranked up!"))
      @guild.rankup
    end
    if @guild.id == 3 # TODO: Add check for having reached Hall of Fame
      pbMessage(_INTL("The guild has ranked up!"))
      @guild.rankup
    end
    drawGuild(@guild.guildBackground)
  end
  
  def drawGuild(i)
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/Guild/guild#{i}")
  end
  
  def pbDungeonMap
    loop do
      dungeon_list = []
      commands = []
      GameData::Dungeon.each do |d|
        dungeon_list.push(d)
        commands.push(d.name)
      end
      commands.push("Cancel")
      command = pbMessage(_INTL("Which dungeon would you like to enter?"), commands, -1)
      if command >= 0 && command < commands.length - 1
        dungeon = dungeon_list[command]
        if @guild.canStartDungeon?(dungeon.id) && pbConfirmMessage(_INTL("Send the guild to {1}?", dungeon.name))
          @guild.startDungeon(dungeon.id)
          @sprites["guildmaster"].update
          for i in 0...12
            @sprites["guildmember#{i}"].update
          end
          break
        end
      else
        break
      end
    end
  end
  
  def pbChooseGuildMaster
    pbFadeOutIn {
      scene = GuildStorageScene.new
      screen = GuildStorageScreen.new(scene, @storage, @guild)
      screen.pbStartScreen(0)
      @sprites["guildmaster"].update
      0 # Dumb thing to ensure that value returned by this proc is an Integer
    }
  end
  
  def pbRemoveGuildMaster
    if $PokemonStorage.pbStoreCaught(@guild.guildMaster) < 0
      pbMessage(_INTL("You have no space in your PC left!"))
    else
      pbMessage(_INTL("{1} has been sent back to the PC.", @guild.guildMaster.name))
      @guild.guildMaster = nil
      @sprites["guildmaster"].update
    end
  end
  
  def pbChooseGuildKeeper
    pbFadeOutIn {
      scene = GuildStorageScene.new
      screen = GuildStorageScreen.new(scene, @storage, @guild)
      screen.pbStartScreen(1)
      @sprites["guildkeeper"].update
      0 # Dumb thing to ensure that value returned by this proc is an Integer
    }
  end
  
  def pbRemoveGuildKeeper
    if $PokemonStorage.pbStoreCaught(@guild.guildKeeper) < 0
      pbMessage(_INTL("You have no space in your PC left!"))
    else
      pbMessage(_INTL("{1} has been sent back to the PC.", @guild.guildKeeper.name))
      @guild.guildKeeper = nil
      @sprites["guildkeeper"].update
    end
  end
  
  def pbChooseGuildMembers
    pbFadeOutIn {
      scene = GuildStorageScene.new
      screen = GuildStorageScreen.new(scene, @storage, @guild)
      screen.pbStartScreen(2)
      for i in 0...12
        @sprites["guildmember#{i}"].update
      end
      0 # Dumb thing to ensure that value returned by this proc is an Integer
    }
  end
  
  def pbRemoveGuildMembers
    loop do
      commands = []
      for i in 0...@guild.guildMembers.length
        commands.push(@guild.guildMembers[i].name)
      end
      commands.push("Cancel")
      command = pbMessage(_INTL("Which Pokemon would you like to remove?"), commands, -1)
      if command >= 0 && command < @guild.guildMembers.length
        oldmember = @guild.guildMembers[command]
        if $PokemonStorage.pbStoreCaught(oldmember) < 0
          pbMessage(_INTL("You have no space in your PC left!"))
        else
          pbMessage(_INTL("{1} has been sent back to the PC.", @guild.guildMembers[command].name))
          @guild.guildMembers[command] = nil
          @guild.guildMembers.compact!
          for i in 0...12
            @sprites["guildmember#{i}"].update
          end
        end
      else
        break
      end
    end
  end
  
  def pbGummiTable
    gummis = [] # Save this list statically somewhere else?
    loop do
      commands = []
      commanditems = []
      for i in gummis
        if @bag.pbHasItem?(i)
          commands.push(PBItems.getName(i))
          commanditems.push(i)
        end
      end
      commands.push("Cancel")
      commanditems.push(-1)
      pbMessage(_INTL("There are currently {1} gummis on the table.", @guild.gummis))
      if commands.length > 1
        command = pbMessage(_INTL("Which gummis would you like to give?", commands, -1))
        if command >= 0 && command < commands.length - 1
          # TODO: Finish this screen
        else
          break
        end
      else
        break
      end
    end
  end

  def pbRefresh
    
  end
end

def pbStartGuildScreen
  scene = GuildScreen.new
  scene.pbStartScene($PokemonGlobal.guild, $player, $PokemonStorage, $bag)
  scene.pbScene
  scene.endScene
end