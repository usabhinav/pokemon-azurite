echoln "BEP: " + $:.to_s

# Check if lib folder exists that is needed for require 'date'
if File.exists?("lib")
  #echoln "Exists."
else
  #echoln "Doesnt exist."
  raise RuntimeError.new("You need to get the lib folder from the Dropbox!")
end

require 'date'

#===============================================================================
#
#===============================================================================
class PokemonLoadPanel < SpriteWrapper
  attr_reader :selected
  attr_reader :btn_type

  TEXTCOLOR             = Color.new(255,255,255)
  TEXTSHADOWCOLOR       = Color.new(66,66,81)
  MALETEXTCOLOR         = Color.new(56,160,248)
  MALETEXTSHADOWCOLOR   = Color.new(56,104,168)
  FEMALETEXTCOLOR       = Color.new(240,72,88)
  FEMALETEXTSHADOWCOLOR = Color.new(160,64,64)

  def initialize(index,title,isContinue,trainer,pokemon_global,framecount,mapid,btn_type,viewport=nil,text_align=-1)
    super(viewport)
    @index = index
    @title = title
    @isContinue = isContinue
    @trainer = trainer
    @pokemon_global = pokemon_global
    @totalsec = (framecount || 0) / Graphics.frame_rate
    @mapid = mapid
    @selected = (index==0)
    @text_align = text_align
    
    # Choose image based on button type.
    @btn_type = btn_type

    #@bgbitmap = AnimatedBitmap.new("Graphics/Pictures/loadPanels")
    
    @refreshBitmap = true
    @refreshing = false
    refresh
  end

  def dispose
    @bgbitmap.dispose
    self.bitmap.dispose
    super
  end

  def selected=(value)
    return if @selected==value
    @selected = value
    @refreshBitmap = true
    refresh
  end

  def pbRefresh
    @refreshBitmap = true
    refresh
  end

  def refresh
    return if @refreshing
    return if disposed?
    @refreshing = true
    
    # Load the correct graphic. The image names start with sel for selected or unsel
    # for not selected and follow up with a number corresponding to the constants
    # inside LoadMenu_Model.
    bmp_path = "Graphics/Pictures/Load Menu/"
    if @selected
      bmp_path += "sel"
    else
      bmp_path += "unsel" 
    end
    bmp_path += @btn_type.to_s
    bmp_path += ".png"
    @bgbitmap = AnimatedBitmap.new(bmp_path)
    
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap = BitmapWrapper.new(@bgbitmap.width, @bgbitmap.height)
      pbSetSmallFont(self.bitmap)
      #self.bitmap.font.size = 29
      
    end
    if @refreshBitmap
      @refreshBitmap = false
      self.bitmap.clear if self.bitmap
      
      self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, 0, @bgbitmap.width, @bgbitmap.height))
      textpos = []
      if @isContinue
        # Standard format for now.
        date_format = "%Y/%m/%d"
        # Draw last time saved.
        if @pokemon_global.savedate != nil
          date = @pokemon_global.savedate
          date_str = date.strftime(date_format + "   %H:%M")
          textpos.push([date_str,185,54,0,TEXTCOLOR,TEXTSHADOWCOLOR,1])
        end
        
        # Draw map name.
        mapname = pbGetMapNameFromId(@mapid)
        mapname.gsub!(/\\PN/,@trainer.name)
        textpos.push([mapname,197,90,0,TEXTCOLOR,TEXTSHADOWCOLOR,1])
        
        # Draw playtime.
        textpos.push([_INTL("Playtime"),220,126,2,TEXTCOLOR,TEXTSHADOWCOLOR,1])
        hour = @totalsec / 60 / 60
        min  = @totalsec / 60 % 60
        if hour>0
          textpos.push([_INTL("{1}h {2}m",hour,min),275,126,0,TEXTCOLOR,TEXTSHADOWCOLOR,1])
        else
          textpos.push([_INTL("{1}m",min),275,126,0,TEXTCOLOR,TEXTSHADOWCOLOR,1])
        end
        
        # Draw amount of seen pokemon.
        textpos.push([_INTL("Seen"),209,162,2,TEXTCOLOR,TEXTSHADOWCOLOR,1])
        textpos.push([@trainer.pokedex.seen_count.to_s,275,162,0,TEXTCOLOR,TEXTSHADOWCOLOR,1])
        
        # Draw amount of caught pokemon.
        textpos.push([_INTL("Caught"),193,196,2,TEXTCOLOR,TEXTSHADOWCOLOR,1])
        textpos.push([@trainer.pokedex.owned_count.to_s,275,196,0,TEXTCOLOR,TEXTSHADOWCOLOR,1])

        # Draw trainer name.
        textpos.push([@trainer.name,92,10,2,TEXTCOLOR,TEXTSHADOWCOLOR,1])
        
        # end
      else
        # Draw the button text.
        # Position and alignment depends on the button type.
        if @btn_type == LoadMenu_Model::BTN_NORMAL_BIG || 
           @btn_type == LoadMenu_Model::BTN_NORMAL_SMALL
          text_x = 181
          alignment = 2
        elsif @btn_type == LoadMenu_Model::BTN_LEFT_DOWN ||
              @btn_type == LoadMenu_Model::BTN_LEFT_UP
          text_x = 158
          alignment = 1
        elsif @btn_type == LoadMenu_Model::BTN_RIGHT_DOWN ||
              @btn_type == LoadMenu_Model::BTN_RIGHT_UP 
          text_x = 17
          alignment = 3
        else
          text_x = 86
          alignment = 2
        end
        # Overwrite specified text alignment if given.
        alignment = @text_align if @text_align > -1
        
        textpos.push([@title,text_x,10,alignment,TEXTCOLOR,TEXTSHADOWCOLOR,1])
      end
      pbDrawTextPositions(self.bitmap,textpos)
    end
    @refreshing = false
  end
end

#===============================================================================
#
#===============================================================================
class PokemonLoad_Scene
  def pbStartScene(commands, show_continue, trainer, pokemon_global, frame_count, map_id, btn_types)
    @commands = commands
    @btn_types = btn_types
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    addBackgroundOrColoredPlane(@sprites,"background","Load Menu/opMenuBack.png",Color.new(248,248,248),@viewport)
    
    for i in 0...commands.length
     btn_type = btn_types[i]
          
     @sprites["panel#{i}"] = PokemonLoadPanel.new(i,commands[i],
         (show_continue) ? (i==0) : false,trainer,pokemon_global,frame_count,map_id,btn_type,@viewport)
      
      # The x positions of the non-continue buttons.
      left_btn_x = 75
      right_btn_x = 264
      
      # Determine button positioning based on the previous button.
      if i > 0
        # Take the opposite x position of the previous button, unless it is a big button.
        # Also increase y position.
        previous_btn = @sprites["panel#{i-1}"]
        if previous_btn.btn_type != LoadMenu_Model::BTN_CONTINUE &&
           previous_btn.btn_type != LoadMenu_Model::BTN_NORMAL_BIG &&
           previous_btn.x == left_btn_x
        
        panel_x = right_btn_x
        
        else 
          panel_x = left_btn_x
          if previous_btn.btn_type == LoadMenu_Model::BTN_CONTINUE
            panel_y += 248 
          else
            panel_y += 56
          end
        end
      else # Starting point, there was no previous button yet.
        if @sprites["panel#{i}"].btn_type == LoadMenu_Model::BTN_CONTINUE
          panel_x = 48
        else
          panel_x = left_btn_x
        end
        panel_y = 32
      end
      
      @sprites["panel#{i}"].x = panel_x
      @sprites["panel#{i}"].y = panel_y
      @sprites["panel#{i}"].pbRefresh
      #y += (show_continue && i==0) ? 112*2 : 24*2
    end
    # Create multiple cmd windows based on how often we need to switch
    # between column amount per row.
    # Initialization: We start off with a single cmd window
    # and try to find out whether or not it will have one or
    # two columns. Two columns are of course needed for sections
    # where there are two buttons per row, so that you can use the
    # LEFT and RIGHT arrow keys to move to them.
    @seg_window = Window_Segmented.new
    cmdwindows = []
    first_cmdwindow = Window_CommandPokemon.new([])
    if(@btn_types[0] == LoadMenu_Model::BTN_CONTINUE ||
       @btn_types[0] == LoadMenu_Model::BTN_NORMAL_BIG)
      first_cmdwindow.columns = 1
    else
      first_cmdwindow.columns = 2
    end
    first_cmdwindow.viewport = @viewport
    first_cmdwindow.visible = false
    cmdwindows.push(first_cmdwindow)
    cmdwindow_commands = [commands[0]] # Get added at the end.
    
    # For the rest of the commands, we either put them in the previous current
    # cmd window or create a new one with different column amount if needed.
    for i in 1...@btn_types.length
      previous_btn = @btn_types[i-1]
      current_btn = @btn_types[i]
      
      # Case 1: The current button fits into the current cmdwindow which has one column.
      if ((current_btn == LoadMenu_Model::BTN_CONTINUE ||
           current_btn == LoadMenu_Model::BTN_NORMAL_BIG) &&
           cmdwindows.last.columns == 1)
        
        cmdwindow_commands.push(@commands[i])
        
        
      # Case 2: The current button fits into the current cmdwindow which has one column.
      elsif ((current_btn != LoadMenu_Model::BTN_CONTINUE &&
              current_btn != LoadMenu_Model::BTN_NORMAL_BIG) &&
              cmdwindows.last.columns == 2)
        
        cmdwindow_commands.push(@commands[i])
      
      # Case 3: The current button does not fit into the current cmdwindow.
      else
        # Create a new cmdwindow with opposite column amount 
        # and put the next command in as its first.
        new_cmdwindow = Window_CommandPokemon.new([])
        new_cmdwindow.columns = (cmdwindows.last.columns == 1) ? 2 : 1
        new_cmdwindow.viewport = @viewport
        new_cmdwindow.visible = false
        cmdwindows.last.commands = cmdwindow_commands
        cmdwindows.push(new_cmdwindow)
        cmdwindow_commands = [commands[i]]
      end
    end
    cmdwindows.last.commands = cmdwindow_commands
    @seg_window.addSegments(cmdwindows)
  end

  def pbStartScene2
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartDeleteScene
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99998
    addBackgroundOrColoredPlane(@sprites,"background","Load Menu/opMenuBack.png",Color.new(248,248,248),@viewport)
  end

  def pbUpdate
    oldi = @seg_window.index rescue 0
    pbUpdateSpriteHash(@sprites)
    @seg_window.update
    newi = @seg_window.index rescue 0
    if oldi!=newi
      @sprites["panel#{oldi}"].selected = false
      @sprites["panel#{oldi}"].pbRefresh
      @sprites["panel#{newi}"].selected = true
      @sprites["panel#{newi}"].pbRefresh
      while @sprites["panel#{newi}"].y>Graphics.height-40*2
        for i in 0...@commands.length
          @sprites["panel#{i}"].y -= 24*2
        end
        for i in 0...6
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y -= 24*2
        end
        @sprites["player"].y -= 24*2 if @sprites["player"]
      end
      while @sprites["panel#{newi}"].y<16*2
        for i in 0...@commands.length
          @sprites["panel#{i}"].y += 24*2
        end
        for i in 0...6
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y += 24*2
        end
        @sprites["player"].y += 24*2 if @sprites["player"]
      end
    end
  end

  def pbSetParty(trainer)
    return if !trainer || !trainer.party
    meta = GameData::Metadata.get_player(trainer.character_ID)
    if meta

      @sprites["player"] = IconSprite.new(0,0, @viewport)
      @sprites["player"].setBitmap("Graphics/Characters/Apparel/TrainerID/Base/Base1.png")
      charwidth  = @sprites["player"].bitmap.width
      charheight = @sprites["player"].bitmap.height
      @sprites["player"].x        = 110
      @sprites["player"].y        = 95
      @sprites["player"].zoom_x   = 1.8
      @sprites["player"].zoom_y   = 1.8
      
      #@sprites["player"].src_rect = Rect.new(0,0,charwidth,charheight)
      trainer.outfitstate.applyToIdBitmap(@sprites["player"].bitmap)
    end
    # Drawing your party is disabled (for now, maybe forever).
    # for i in 0...trainer.party.length
      # @sprites["party#{i}"] = PokemonIconSprite.new(trainer.party[i],@viewport)
      # @sprites["party#{i}"].setOffset(PictureOrigin::Center)
      # @sprites["party#{i}"].x = (167+33*(i%2))*2
      # @sprites["party#{i}"].y = (56+25*(i/2))*2
      # @sprites["party#{i}"].z = 99999
    # end
  end

  def pbChoose(commands)
    #@sprites["cmdwindow"].commands = commands # Moved to pbStartScene because why tf would this be in here.
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::USE)
        return @seg_window.index
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbCloseScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonLoadScreen
  def initialize(scene)
    @scene = scene
    if SaveData.exists?
      @save_data = load_save_file(SaveData::FILE_PATH)
    else
      @save_data = {}
    end
  end

  # @param file_path [String] file to load save data from
  # @return [Hash] save data
  def load_save_file(file_path)
    save_data = SaveData.read_from_file(file_path)
    unless SaveData.valid?(save_data)
      if File.file?(file_path + '.bak')
        pbMessage(_INTL('The save file is corrupt. A backup will be loaded.'))
        save_data = load_save_file(file_path + '.bak')
      else
        self.prompt_save_deletion
        return {}
      end
    end
    return save_data
  end

  # Called if all save data is invalid.
  # Prompts the player to delete the save files.
  def prompt_save_deletion
    pbMessage(_INTL('The save file is corrupt, or is incompatible with this game.'))
    exit unless pbConfirmMessageSerious(
      _INTL('Do you want to delete the save file and start anew?')
    )
    self.delete_save_data
    $game_system   = Game_System.new
    $PokemonSystem = PokemonSystem.new
  end

  def pbStartDeleteScreen
    @scene.pbStartDeleteScene
    @scene.pbStartScene2
    if SaveData.exists?
      if pbConfirmMessageSerious(_INTL("Delete all saved data?"))
        pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
        if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
          pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
          self.delete_save_data
        end
      end
    else
      pbMessage(_INTL("No save file was found."))
    end
    @scene.pbEndScene
    $scene = pbCallTitle
  end

  def delete_save_data
    begin
      SaveData.delete_file
      pbMessage(_INTL('The saved data was deleted.'))
    rescue SystemCallError
      pbMessage(_INTL('All saved data could not be deleted.'))
    end
  end

  def pbStartLoadScreen
    commands     = []
    buttonFormat = [] # Dictates which sprite the scene will use for each command button.
    cmd_continue     = -1
    cmd_new_game     = -1
    cmd_new_nuzlocke = -1
    cmd_options      = -1
    cmd_language     = -1
    cmd_mystery_gift = -1
    cmd_debug        = -1
    cmd_quit         = -1
    show_continue = !@save_data.empty?
    
    if show_continue
      commands[cmd_continue = commands.length] = _INTL('Continue')
      commands[cmd_new_game = commands.length]  = _INTL('New Journey')
      if @save_data[:player].mystery_gift_unlocked || true
        commands[cmd_mystery_gift = commands.length] = _INTL('Mystery Gift')
        buttonFormat[cmd_new_game] = LoadMenu_Model::BTN_LEFT_UP
        buttonFormat[cmd_mystery_gift] = LoadMenu_Model::BTN_RIGHT_UP
      else
        buttonFormat[cmd_new_game] = LoadMenu_Model::BTN_NORMAL_BIG
      end
      #commands[cmd_language = commands.length]  = _INTL('Language') if Settings::LANGUAGES.length >= 2
      commands[cmd_options = commands.length]   = _INTL('Options')
      commands[cmd_quit = commands.length]      = _INTL('Quit Game')
      commands[cmd_debug = commands.length]     = _INTL('Debug') if $DEBUG
      
      buttonFormat[cmd_continue] = LoadMenu_Model::BTN_CONTINUE
      buttonFormat[cmd_options] = LoadMenu_Model::BTN_LEFT_DOWN
      buttonFormat[cmd_quit] = LoadMenu_Model::BTN_RIGHT_DOWN
      buttonFormat[cmd_debug] = LoadMenu_Model::BTN_NORMAL_BIG if $DEBUG
    else
      commands[cmd_new_game = commands.length]  = _INTL('Start The Journey')
      commands[cmd_new_nuzlocke = commands.length]  = _INTL('Start The Dangerous Journey')
      commands[cmd_options = commands.length]  = _INTL('Settings')
      commands[cmd_quit = commands.length]  = _INTL('Quit Game')
      commands[cmd_debug = commands.length]     = _INTL('Debug') if $DEBUG

      buttonFormat[cmd_new_game] = LoadMenu_Model::BTN_NORMAL_BIG
      buttonFormat[cmd_new_nuzlocke] = LoadMenu_Model::BTN_NORMAL_BIG
      buttonFormat[cmd_options] = LoadMenu_Model::BTN_LEFT_DOWN
      buttonFormat[cmd_quit] = LoadMenu_Model::BTN_RIGHT_DOWN
      buttonFormat[cmd_debug] = LoadMenu_Model::BTN_NORMAL_BIG if $DEBUG
    end
 
    # testScene = LoadMenu_Scene.new
    # testScene.pbStartScene
    windows = Window_Segmented.new
 
    upperCmd = Window_CommandPokemon.new([])
    lowerCmd = Window_CommandPokemon.new([])
    upperCmd.visible = false
    lowerCmd.visible = false
    upperCmd.commands = commands
    lowerCmd.commands = commands
    lowerCmd.columns = 2
    
    windows.addSegment(upperCmd)
    windows.addSegment(lowerCmd)
 
    # loop do
      # Graphics.update
      # Input.update
      
      # #upperCmd.update
      # echoln "UPPERCMD: " + upperCmd.index.to_s
      
      # #lowerCmd.update
      # echoln "LOWERCMD: " + lowerCmd.index.to_s
      
      # windows.update
      # echoln "SEGMENTED: " + windows.index.to_s
    # end

    map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
    @scene.pbStartScene(commands, show_continue, @save_data[:player],
                        @save_data[:global_metadata],
                        @save_data[:frame_count] || 0, 
                        map_id, buttonFormat)
    @scene.pbSetParty(@save_data[:player]) if show_continue
    @scene.pbStartScene2
    loop do
      command = @scene.pbChoose(commands)
      pbPlayDecisionSE if command != cmd_quit
      case command
      when cmd_continue
        @scene.pbEndScene
        Game.load(@save_data)
        return
      when cmd_new_game
        @scene.pbEndScene
        Game.start_new
        return
      when cmd_mystery_gift
        pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
      when cmd_options
        pbFadeOutIn do
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen(true)
        end
      when cmd_language
        @scene.pbEndScene
        $PokemonSystem.language = pbChooseLanguage
        pbLoadMessages('Data/' + Settings::LANGUAGES[$PokemonSystem.language][1])
        if show_continue
          @save_data[:pokemon_system] = $PokemonSystem
          File.open(SaveData::FILE_PATH, 'wb') { |file| Marshal.dump(@save_data, file) }
        end
        $scene = pbCallTitle
        return
      when cmd_debug
        pbFadeOutIn { pbDebugMenu(false) }
      when cmd_quit
        pbPlayCloseMenuSE
        @scene.pbEndScene
        $scene = nil
        return
      else
        pbPlayBuzzerSE
      end
    end
  end
end

# Decouple these constants from the Scene and Screen.
module LoadMenu_Model
  BTN_CONTINUE      = 0
  BTN_NORMAL_BIG    = 1
  BTN_LEFT_UP       = 2
  BTN_RIGHT_UP      = 3
  BTN_NORMAL_SMALL  = 4
  BTN_LEFT_DOWN     = 5
  BTN_RIGHT_DOWN    = 6
  
  def self.isSmall?(button_constant)
    if(button_constant == BTN_CONTINUE || button_constant == BTN_NORMAL_BIG)
      return false
    else
      return true
    end
  end
  
end

class LoadMenu_Scene

  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    
    @commands = ["A", "B", "C", "D", "E", "F"]
    
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].viewport = @viewport
    @sprites["cmdwindow"].visible  = true
    @sprites["cmdwindow"].commands = @commands
    @sprites["cmdwindow"].columns = 2
  end
end