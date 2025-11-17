# Holds relevant constants
module TeamBuilderScreenConstants
  TEXT_BASE_COLOR   = Color.new(0, 0, 0)
  TEXT_SHADOW_COLOR = Color.new(248, 248, 248)

  FOLDER_PATH = "Graphics/Pictures/Team Builder"

  SCREEN_LIST = [
    :SpeciesSelection,
    # :AttributeSelection,
    # :MoveSelection,
    # :AbilitySelection,
    # :ItemSelection,
    # :EVSelection,
    # :IVSelection,
    # :NatureSelection,
    # :TypologySelection,
  ]

  TRAINER_LIST = [
    :PlayerTrainer,
    :OpponentTrainer,
  ]

  def self.drawTextOnButton(text, bitmap)
    pbDrawTextPositions(bitmap, [
      [text, bitmap.width / 2, bitmap.height / 2, 2, TeamBuilderScreenConstants::TEXT_BASE_COLOR, TeamBuilderScreenConstants::TEXT_SHADOW_COLOR, nil, 2]
    ])
  end
end

class TeamBuilderButton
  attr_reader :name
  attr_reader :x, :y, :width, :height
  attr_reader :action_proc_map
  attr_reader :sprite
  attr_accessor :disabled_input_list
  attr_writer :highlighted

  def initialize(viewport, sprites, name, x, y, width, height, button_group = nil, button_group_index = nil)
    @name = name
    @x = x
    @y = y
    @width = width
    @height = height
    @button_group = button_group
    @button_group_index = button_group_index
    @action_proc_map = {}
    @input_configurations = {}
    @sprite = Sprite.new(viewport)
    @sprite.bitmap = Bitmap.new(width, height)
    redraw_bitmap
    @sprite.x = x
    @sprite.y = y
    @sprite.z = 2
    sprites["BUTTON_#{name}"] = @sprite
    @disabled_input_list = []
    @highlighted = false
  end

  def center_x
    return @x + @width / 2
  end

  def center_y
    return @y + @height / 2
  end

  def set_input(keyboard_input, next_button)
    @input_configurations[keyboard_input] = next_button
  end

  def get_button(*args)
    return self
  end

  def get_next_button_from_input(keyboard_input)
    return self if @disabled_input_list.include?(keyboard_input)
    if @input_configurations.has_key?(keyboard_input)
      return @input_configurations[keyboard_input]
    end
    return self
  end

  def perform_action(input)
    @action_proc_map[input]&.call(@button_group_index)
  end

  def redraw_bitmap
    @sprite.bitmap.clear
    # TODO: remove this later
    # Yellow if highlighted, otherwise white
    @sprite.bitmap.fill_rect(0, 0, width, height, @highlighted ? Color.new(255, 242, 0) : Color.new(255, 255, 255))
  end
end

class TeamBuilderButtonGroup
  attr_reader :name
  attr_reader :buttons
  attr_reader :current_index

  def initialize(viewport, sprites, name, num_cols, num_rows, x, y, width, height)
    @name = name
    @num_cols = num_cols
    @num_rows = num_rows
    @x = x
    @y = y
    @width = width
    @height = height
    @buttons = []
    @current_index = 0
    total_button_count = num_rows * num_cols
    for i in 0...total_button_count
      row_num = get_row_num_for_index(i)
      col_num = get_col_num_for_index(i)
      @buttons[i] = TeamBuilderButton.new(viewport, sprites, "#{name}#{i}", x + (col_num * width), y + (row_num * height), width, height, self, i)
    end
    for i in 0...total_button_count
      @buttons[i].set_input(:UP, @buttons[i - num_cols]) if !is_index_in_top_row(i)
      @buttons[i].set_input(:DOWN, @buttons[i + num_cols]) if !is_index_in_bottom_row(i)
      @buttons[i].set_input(:LEFT, @buttons[i - 1]) if !is_index_in_left_column(i)
      @buttons[i].set_input(:RIGHT, @buttons[i + 1]) if !is_index_in_right_column(i)
    end
  end

  def each_button_with_index
    @buttons.each_with_index { |b, i| yield b, i }
  end

  def get_total_button_count
    return @num_rows * @num_cols
  end

  def get_row_num_for_index(index)
    return index / @num_cols
  end

  def get_col_num_for_index(index)
    return index % @num_cols
  end

  def is_index_in_top_row(index)
    return index < @num_cols
  end

  def is_index_in_bottom_row(index)
    return index >= @num_cols * (@num_rows - 1)
  end

  def is_index_in_left_column(index)
    return index % @num_cols == 0
  end

  def is_index_in_right_column(index)
    return (index + 1) % @num_cols == 0
  end

  def set_input(source_index, keyboard_input, next_button)
    @buttons[source_index].set_input(keyboard_input, next_button)
  end

  def set_top_row_input(next_button)
    for i in 0...@buttons.length
      @buttons[i].set_input(:UP, next_button) if is_index_in_top_row(i)
    end
  end

  def set_bottom_row_input(next_button)
    for i in 0...@buttons.length
      @buttons[i].set_input(:DOWN, next_button) if is_index_in_bottom_row(i)
    end
  end

  def set_left_column_input(next_button)
    for i in 0...@buttons.length
      @buttons[i].set_input(:LEFT, next_button) if is_index_in_left_column(i)
    end
  end

  def set_right_column_input(next_button)
    for i in 0...@buttons.length
      @buttons[i].set_input(:RIGHT, next_button) if is_index_in_right_column(i)
    end
  end

  def get_button(index)
    return @buttons[index]
  end

  def get_next_button_from_input(keyboard_input)
    return @buttons[@current_index].get_next_button_from_input(keyboard_input)
  end

  def set_action_proc_for_input(input, proc)
    for i in 0...@buttons.length
      @buttons[i].action_proc_map[input] = proc
    end
  end
end

# Only supports single column, vertical scrolling.
class TeamBuilderScrollableButtonGroup < TeamBuilderButtonGroup
  def initialize(options_list, initial_value, viewport, sprites, name, num_cols, num_rows, x, y, width, height)
    raise "Unsupported column size #{num_cols}; must be 1" if num_cols != 1
    super(viewport, sprites, name, num_cols, num_rows, x, y, width, height)
    self.options_list = options_list
    if initial_value
      @top_button_index = [@options_list.find_index { |option| option[:value] == initial_value }, @options_list.length - get_total_button_count].min
      refresh_on_top_button_index_change
      update_on_cursor_move
    end
  end

  def options_list=(options_list)
    @top_button_index = 0
    @options_list = options_list
    refresh_on_top_button_index_change
    @buttons[0].action_proc_map[:UP] = Proc.new {
      unless @top_button_index == 0
        @top_button_index -= 1
        refresh_on_top_button_index_change
      end
    }
    @buttons[get_total_button_count - 1].action_proc_map[:DOWN] = Proc.new {
      unless @top_button_index >= (options_list.length - get_total_button_count)
        @top_button_index += 1
        refresh_on_top_button_index_change
      end
    }
    update_on_cursor_move
  end

  def refresh_on_top_button_index_change
    for i in 0...get_total_button_count
      @buttons[i].redraw_bitmap
      option = get_object_from_options_list(i)
      TeamBuilderScreenConstants.drawTextOnButton(option[:display_text], @buttons[i].sprite.bitmap) if option
    end
  end

  def update_on_cursor_move
    if get_total_button_count == 1
      @buttons[0].disabled_input_list = []
      return
    end
    @buttons[0].disabled_input_list = @top_button_index == 0 ? [] : [:UP]
    @buttons[get_total_button_count - 1].disabled_input_list = @top_button_index >= (@options_list.length - get_total_button_count) ? [] : [:DOWN]
  end

  def get_index_in_options_list(i)
    return @top_button_index + i
  end

  def get_object_from_options_list(i)
    return @options_list[get_index_in_options_list(i)]
  end

  def get_value_from_options_list(i)
    option = get_object_from_options_list(i)
    return option ? option[:value] : nil
  end
end

class TeamBuilderScreen_Base
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def endScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    return @clicked_button_type
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

  def pbScene
    loop do
      @end_scene = false
      Graphics.update
      Input.update
      pbUpdate
      inputUpdate
      break if @end_scene
      refreshCursor
    end
  end

  def inputUpdate
    if Input.trigger?(Input::B)
      @current_button.perform_action(:B)
      @clicked_button_type = :Previous
      @end_scene = true
      return
    elsif Input.trigger?(Input::USE)
      @current_button.perform_action(:USE)
    elsif Input.trigger?(Input::UP)
      @current_button.perform_action(:UP)
      @current_button = @current_button.get_next_button_from_input(:UP)
      updateOnCursorMove
      pbPlayCursorSE
    elsif Input.trigger?(Input::DOWN)
      @current_button.perform_action(:DOWN)
      @current_button = @current_button.get_next_button_from_input(:DOWN)
      updateOnCursorMove
      pbPlayCursorSE
    elsif Input.trigger?(Input::LEFT)
      @current_button.perform_action(:LEFT)
      @current_button = @current_button.get_next_button_from_input(:LEFT)
      updateOnCursorMove
      pbPlayCursorSE
    elsif Input.trigger?(Input::RIGHT)
      @current_button.perform_action(:RIGHT)
      @current_button = @current_button.get_next_button_from_input(:RIGHT)
      updateOnCursorMove
      pbPlayCursorSE
    end
    return false
  end

  def refreshBackground
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("#{TeamBuilderScreenConstants::FOLDER_PATH}/TeamBuilderScreenPlaceholder")
  end

  def refreshCursor
    @sprites["cursor"].x = @current_button.x - (@sprites["cursor"].width / 2)
    @sprites["cursor"].y = @current_button.y + (@current_button.height / 2) - (@sprites["cursor"].height / 2)
  end

  def get_next_button_for_selection
    next_button = TeamBuilderButton.new(@viewport, @sprites, "next", 472, 344, 40, 40)
    next_button.action_proc_map[:USE] = Proc.new { |input|
      @clicked_button_type = :Next
      @end_scene = true
    }
    TeamBuilderScreenConstants.drawTextOnButton("Next", next_button.sprite.bitmap)
    return next_button
  end

  def get_previous_button_for_selection
    previous_button = TeamBuilderButton.new(@viewport, @sprites, "previous", 432, 344, 40, 40)
    previous_button.action_proc_map[:USE] = Proc.new { |input|
      @clicked_button_type = :Previous
      @end_scene = true
    }
    TeamBuilderScreenConstants.drawTextOnButton("Prev.", previous_button.sprite.bitmap)
    return previous_button
  end

  def updateOnCursorMove
    @buttons.each_value do |button|
      button.update_on_cursor_move if button.respond_to?(:update_on_cursor_move)
    end
  end
end

class TeamBuilderScreen_SpeciesSelection < TeamBuilderScreen_Base
  def initialize(current_pokemon_object)
    @current_pokemon_object = current_pokemon_object
  end

  def pbStartScene
    # Set up background and core sprites
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["cursor"] = Sprite.new(@viewport)
    @sprites["cursor"].bitmap = Bitmap.new("Graphics/Pictures/mm cursors")
    @sprites["cursor"].src_rect = Rect.new(30, 0, 15, 15)
    @sprites["cursor"].z = 3
    @sprites["highlightCursor"] = Sprite.new(@viewport)
    @sprites["highlightCursor"].bitmap = Bitmap.new("Graphics/Pictures/boxpoint1")
    @sprites["highlightCursor"].z = 2
    @buttons = {}
    @search_text = ""
    @species_list = getNewSpeciesList(@search_text)
    @last_species = @species_list[0][:value]
    refreshBackground
    setupInitialButtonsAndSprites
    refreshCursor
    refreshHighlightCursor
    refreshGenderButtons
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def setupInitialButtonsAndSprites
    @buttons[:Next] = get_next_button_for_selection

    @buttons[:Previous] = get_previous_button_for_selection

    @buttons[:Search] = TeamBuilderButton.new(@viewport, @sprites, "search", 60, 24, 128, 64)
    TeamBuilderScreenConstants.drawTextOnButton("Search", @buttons[:Search].sprite.bitmap)
    @buttons[:Search].action_proc_map[:USE] = Proc.new {
      search_text = pbFreeText(nil, @search_text, false, 15, 100) { pbUpdate }
      new_species_list = getNewSpeciesList(search_text)
      if new_species_list.length == 0
        pbMessage(_INTL("No results found!"))
      else
        @search_text = search_text
        @buttons[:Search].redraw_bitmap
        TeamBuilderScreenConstants.drawTextOnButton(@search_text != "" ? @search_text : "Search", @buttons[:Search].sprite.bitmap)
        @species_list = new_species_list
        @buttons[:SpeciesListButtonGroup].options_list = @species_list
        refreshHighlightCursor
      end
    }

    @buttons[:SpeciesListButtonGroup] = TeamBuilderScrollableButtonGroup.new(@species_list, @current_pokemon_object[:SelectedSpecies], @viewport, @sprites, "specieslist", 1, 4, 60, 96, 128, 64)
    @buttons[:SpeciesListButtonGroup].set_action_proc_for_input(:USE, Proc.new { |i|
      if @buttons[:SpeciesListButtonGroup].get_object_from_options_list(i)
        @current_pokemon_object[:SelectedSpecies] = @buttons[:SpeciesListButtonGroup].get_value_from_options_list(i)
        refreshHighlightCursor
      end
    })

    @buttons[:GenderButtonGroup] = TeamBuilderButtonGroup.new(@viewport, @sprites, "gender", 3, 1, 202, 24, 16, 16)
    @buttons[:GenderButtonGroup].set_action_proc_for_input(:USE, Proc.new { |i|
      if isGenderValidForSpecies(i, @last_species)
        @current_pokemon_object[:Gender] = i
        refreshGenderButtons
        refreshPokemonBattleSprite
      else
        pbMessage(_INTL("This gender is not valid for this species!"))
      end
    })

    @buttons[:Next].set_input(:UP, @buttons[:Search])
    @buttons[:Next].set_input(:LEFT, @buttons[:Previous])

    @buttons[:Previous].set_input(:UP, @buttons[:Search])
    @buttons[:Previous].set_input(:LEFT, @buttons[:Search])
    @buttons[:Previous].set_input(:RIGHT, @buttons[:Next])

    @buttons[:Search].set_input(:DOWN, @buttons[:SpeciesListButtonGroup].get_button(0))
    @buttons[:Search].set_input(:RIGHT, @buttons[:GenderButtonGroup].get_button(0))

    @buttons[:SpeciesListButtonGroup].set_top_row_input(@buttons[:Search])
    @buttons[:SpeciesListButtonGroup].set_bottom_row_input(@buttons[:Previous])
    @buttons[:SpeciesListButtonGroup].set_right_column_input(@buttons[:Previous])

    @buttons[:GenderButtonGroup].set_left_column_input(@buttons[:Search])
    @buttons[:GenderButtonGroup].set_bottom_row_input(@buttons[:Previous])

    @current_button = @buttons[:Search]
    selected_species_list_index = 0
    # If there is already a selected species in the slot being edited, move cursor's initial position to that species
    if @current_pokemon_object[:SelectedSpecies]
      @buttons[:SpeciesListButtonGroup].each_button_with_index do |button, i|
        if @current_pokemon_object[:SelectedSpecies] == @buttons[:SpeciesListButtonGroup].get_value_from_options_list(i)
          @current_button = button
          selected_species_list_index = @buttons[:SpeciesListButtonGroup].get_index_in_options_list(i)
          @last_species = @buttons[:SpeciesListButtonGroup].get_value_from_options_list(i)
          break
        end
      end
    end

    poke = Pokemon.new(@species_list[selected_species_list_index][:value], 1)
    poke.gender = (@current_pokemon_object[:Gender] || 0)
    battle_sprite = PokemonSprite.new(@viewport)
    battle_sprite.setOffset(PictureOrigin::CENTER)
    battle_sprite.x = 384
    battle_sprite.y = 200
    battle_sprite.z = 2
    battle_sprite.setPokemonBitmap(poke)
    @sprites["pokemonBattler"] = battle_sprite
  end

  def getNewSpeciesList(search_text)
    species_list = []
    GameData::Species.each_species do |s|
      species_list.push({
        :display_text => s.name,
        :value => s.id,
      }) if s.name.downcase.include?(search_text.downcase)
    end
    return species_list
  end

  def isGenderValidForSpecies(new_gender, species)
    species_data = GameData::Species.get(species)
    if species_data.single_gendered?
      return new_gender == [:AlwaysMale, :AlwaysFemale, :Genderless].index(species_data.gender_ratio)
    else
      return new_gender != 2
    end
  end

  def getValidGenderForSpecies(species)
    # Simple brute-force logic to find any valid gender for the given species
    species_data = GameData::Species.get(species)
    if species_data.single_gendered?
      return [:AlwaysMale, :AlwaysFemale, :Genderless].index(species_data.gender_ratio)
    else
      return 0
    end
  end

  def updateOnCursorMove
    super
    refreshPokemonBattleSpriteOnCursorMove
    refreshHighlightCursor
  end

  def refreshPokemonBattleSpriteOnCursorMove
    if @current_button.name.start_with?("specieslist")
      selected_index = @current_button.name.gsub("specieslist", "").to_i
      if @buttons[:SpeciesListButtonGroup].get_object_from_options_list(selected_index)
        new_species = @buttons[:SpeciesListButtonGroup].get_value_from_options_list(selected_index)
        if @last_species != new_species
          @last_species = new_species
          if !isGenderValidForSpecies((@current_pokemon_object[:Gender] || 0), @last_species)
            new_gender = getValidGenderForSpecies(@last_species)
            @current_pokemon_object[:Gender] = new_gender
            refreshGenderButtons
          end
          refreshPokemonBattleSprite
        end
      end
    end
  end

  def refreshPokemonBattleSprite
    poke = Pokemon.new(@last_species, 1)
    poke.gender = (@current_pokemon_object[:Gender] || 0)
    @sprites["pokemonBattler"].setPokemonBitmap(poke)
  end

  def refreshHighlightCursor
    button_index = nil
    for i in 0...@buttons[:SpeciesListButtonGroup].buttons.length
      if @buttons[:SpeciesListButtonGroup].get_object_from_options_list(i) && @current_pokemon_object[:SelectedSpecies] == @buttons[:SpeciesListButtonGroup].get_value_from_options_list(i)
        button_index = i
        break
      end
    end
    if button_index.nil?
      @sprites["highlightCursor"].visible = false
    else
      species_button = @buttons[:SpeciesListButtonGroup].get_button(button_index)
      @sprites["highlightCursor"].x = species_button.x + species_button.width
      @sprites["highlightCursor"].y = species_button.y + species_button.height / 2 - @sprites["highlightCursor"].bitmap.height / 2
      @sprites["highlightCursor"].visible = true
    end
  end

  def refreshGenderButtons
    selected_gender = @current_pokemon_object[:Gender] || 0
    @buttons[:GenderButtonGroup].each_button_with_index do |button, i|
      button.highlighted = (selected_gender == i)
      button.redraw_bitmap
      TeamBuilderScreenConstants.drawTextOnButton(["M", "F", "-"][i], button.sprite.bitmap)
    end
  end
end

class TeamBuilderScreen < TeamBuilderScreen_Base
  def pbStartScene
    # Set up background and core sprites
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["cursor"] = Sprite.new(@viewport)
    @sprites["cursor"].bitmap = Bitmap.new("Graphics/Pictures/mm cursors")
    @sprites["cursor"].src_rect = Rect.new(30, 0, 15, 15)
    @sprites["cursor"].z = 3
    @buttons = {}
    # Initialize party objects for both trainers
    @selectedParties = {}
    for trainer in TeamBuilderScreenConstants::TRAINER_LIST
      @selectedParties[trainer] = Array.new(6) { {} }
    end
    # TODO: Remove these 3
    @selectedParties[:PlayerTrainer][0][:SelectedSpecies] = :BULBASAUR
    @selectedParties[:PlayerTrainer][1][:SelectedSpecies] = :SQUIRTLE
    @selectedParties[:PlayerTrainer][2][:SelectedSpecies] = :CHARMANDER
    @current_trainer = :PlayerTrainer
    refreshBackground
    setupInitialButtonsAndSprites
    refreshCursor
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def setupInitialButtonsAndSprites
    @buttons[:Next] = TeamBuilderButton.new(@viewport, @sprites, "next", 432, 0, 80, 30)
    TeamBuilderScreenConstants.drawTextOnButton("Next", @buttons[:Next].sprite.bitmap)

    @buttons[:SlotButtonGroup] = TeamBuilderButtonGroup.new(@viewport, @sprites, "slots", 2, 3, 60, 96, 64, 64)
    @buttons[:SlotButtonGroup].set_action_proc_for_input(:USE, Proc.new { |i|
      if @selectedParties[@current_trainer][i][:SelectedSpecies]
        commands = []
        cmdEdit    = -1
        cmdRemove  = -1
        commands[cmdEdit = commands.length]    = _INTL("Edit")
        commands[cmdRemove = commands.length]  = _INTL("Remove")
        commands[commands.length]              = _INTL("Cancel")
        command = pbShowCommands(commands) { pbUpdate }
        if command == cmdEdit
          @current_pokemon_index = i
          @previous_selected_pokemon_object = Marshal.load(Marshal.dump(@selectedParties[@current_trainer][i]))
          startFullSelectionScreen
          refreshPokemonAtIndex(i)
        elsif command == cmdRemove
          @selectedParties[@current_trainer][i] = {}
          refreshPokemonAtIndex(i)
        end
      else
        @current_pokemon_index = i
        @previous_selected_pokemon_object = Marshal.load(Marshal.dump(@selectedParties[@current_trainer][i]))
        startFullSelectionScreen
        refreshPokemonAtIndex(i)
      end
    })

    @buttons[:Next].set_input(:DOWN, @buttons[:SlotButtonGroup].get_button(1))
    @buttons[:Next].set_input(:LEFT, @buttons[:SlotButtonGroup].get_button(1))

    @buttons[:SlotButtonGroup].set_top_row_input(@buttons[:Next])
    @buttons[:SlotButtonGroup].set_right_column_input(@buttons[:Next])

    @current_button = @buttons[:SlotButtonGroup].get_button(0)

    selected_party = @selectedParties[@current_trainer]
    for i in 0...6
      refreshPokemonAtIndex(i)
    end

    refreshPokemonBattleSprite
  end

  def updateOnCursorMove
    super
    refreshPokemonBattleSprite
  end

  def refreshPokemonAtIndex(i)
    if @selectedParties[@current_trainer][i][:SelectedSpecies]
      poke = Pokemon.new(@selectedParties[@current_trainer][i][:SelectedSpecies], 1)
      poke.gender = @selectedParties[@current_trainer][i][:Gender] || 0
      if @sprites["pokemonIcon#{i}"].nil?
        icon_sprite = PokemonIconSprite.new(poke, @viewport)
        icon_sprite.setOffset(PictureOrigin::CENTER)
        icon_sprite.x = @buttons[:SlotButtonGroup].get_button(i).center_x
        icon_sprite.y = @buttons[:SlotButtonGroup].get_button(i).center_y
        icon_sprite.z = 2
        icon_sprite.active = true
        icon_sprite.update
        @sprites["pokemonIcon#{i}"] = icon_sprite

        battle_sprite = PokemonSprite.new(@viewport)
        battle_sprite.setOffset(PictureOrigin::CENTER)
        battle_sprite.x = 384
        battle_sprite.y = 192
        battle_sprite.z = 2
        battle_sprite.setPokemonBitmap(poke)
        battle_sprite.visible = false
        @sprites["pokemonBattle#{i}"] = battle_sprite
      else
        @sprites["pokemonIcon#{i}"].pokemon = poke
        @sprites["pokemonBattle#{i}"].setPokemonBitmap(poke)
      end
    elsif !@sprites["pokemonIcon#{i}"].nil?
      @sprites["pokemonIcon#{i}"].visible = false
      @sprites["pokemonIcon#{i}"].dispose
      @sprites["pokemonIcon#{i}"] = nil
      @sprites["pokemonBattle#{i}"].visible = false
      @sprites["pokemonBattle#{i}"].dispose
      @sprites["pokemonBattle#{i}"] = nil
    end
    refreshPokemonBattleSprite
  end

  def refreshPokemonBattleSprite
    selected_party = @selectedParties[@current_trainer]
    index_to_show = nil
    if @current_button.name.start_with?("slots")
      selected_index = @current_button.name.gsub("slots", "").to_i
      selected_species = selected_party[selected_index][:SelectedSpecies]
      if selected_species
        index_to_show = selected_index
      end
    end
    for i in 0...6
      next if !@sprites["pokemonBattle#{i}"]
      if index_to_show == i
        @sprites["pokemonBattle#{i}"].visible = true
      else
        @sprites["pokemonBattle#{i}"].visible = false
      end
    end
  end

  def startFullSelectionScreen
    screen_type = :SpeciesSelection
    loop do
      clicked_button_type = startSelectionScreen(screen_type, @selectedParties[@current_trainer][@current_pokemon_index])
      raise "Received nil clicked_button_type" if clicked_button_type.nil?
      screen_list_index = TeamBuilderScreenConstants::SCREEN_LIST.index(screen_type)
      if clicked_button_type == :Previous && screen_list_index == 0
        @selectedParties[@current_trainer][@current_pokemon_index] = @previous_selected_pokemon_object
        @previous_selected_pokemon_object = nil
        break
      elsif clicked_button_type == :Next && screen_list_index == TeamBuilderScreenConstants::SCREEN_LIST.length - 1
        break
      else
        screen_type = TeamBuilderScreenConstants::SCREEN_LIST[screen_list_index + (clicked_button_type == :Next ? 1 : -1)]
      end
    end
  end

  def startSelectionScreen(screen_type, current_pokemon_object)
    clicked_button_type = nil
    pbFadeOutIn {
      class_name_string = "TeamBuilderScreen_#{screen_type}"
      scene = Object.const_get(class_name_string).new(current_pokemon_object)
      scene.pbStartScene
      scene.pbScene
      clicked_button_type = scene.endScene
    }
    return clicked_button_type
  end
end

def pbStartTeamBuilderScreen
  pbFadeOutIn {
    scene = TeamBuilderScreen.new
    scene.pbStartScene
    scene.pbScene
    scene.endScene
  }
end
