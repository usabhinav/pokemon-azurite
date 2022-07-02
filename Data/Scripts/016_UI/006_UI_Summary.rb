#===============================================================================
#
#===============================================================================
class MoveSelectionSprite < Sprite
  attr_reader :preselected
  attr_reader :index
  attr_writer :pokemon

  def initialize(viewport = nil, fifthmove = false)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/Pictures/Summary New/summarymovesel")
    @frame = 0
    @index = 0
    @fifthmove = fifthmove
    @preselected = false
    @updating = false
    refresh
  end

  def dispose
    @movesel.dispose
    super
  end

  def index=(value)
    @index = value
    refresh
  end

  def preselected=(value)
    @preselected = value
    refresh
  end

  def refresh
    w = @movesel.width
    h = @movesel.height / 2
    self.x = 240
    self.y = 92 + (self.index * 64)
    self.y -= 40 if @fifthmove
    self.y += 4 if @fifthmove && self.index == Pokemon::MAX_MOVES   # Add a gap
    self.bitmap = @movesel.bitmap
    if self.preselected
      self.src_rect.set(0, h, w, h)
    else
      self.src_rect.set(0, 0, w, h)
    end
  end

  def update
    @updating = true
    super
    @movesel = AnimatedBitmap.new("Graphics/Pictures/Summary New/summarymovesel" + (@pokemon&.fainted? ? "f" : ""))
    @movesel.update
    @updating = false
    refresh
  end
end

#===============================================================================
#
#===============================================================================
class RibbonSelectionSprite < MoveSelectionSprite
  def initialize(viewport = nil)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/Pictures/Summary New/summaryribbonsel")
    @frame = 0
    @index = 0
    @preselected = false
    @updating = false
    @spriteVisible = true
    refresh
  end

  def visible=(value)
    super
    @spriteVisible = value if !@updating
  end

  def refresh
    w = @movesel.width
    h = @movesel.height / 2
    self.x = 94 + ((self.index % 5) * 72)
    self.y = 132 + (((self.index) / 5).floor * 80)
    self.bitmap = @movesel.bitmap
  end

  def update
    @updating = true
    super
    @movesel = AnimatedBitmap.new("Graphics/Pictures/Summary New/summaryribbonsel")
    self.visible = @spriteVisible && @index >= 0 && @index < 10
    @movesel.update
    @updating = false
    refresh
  end
end

#===============================================================================
#
#===============================================================================
class PartyRotationSprite < Sprite
  attr_accessor :index
  attr_accessor :moving_up # If false, is moving down

  def initialize(viewport = nil, party = nil, start_index = nil)
    super(viewport)
    @party = party
    @index = start_index
    @moving_up = true
    @circle_points = generate_points_along_circle(0, 0, 46)
    @num_points_in_octant = @circle_points.length / 8
    @sprites = []
    @sprite_position_index_list = [] # Tracks position in circle for each sprite
    position_index = 0
    for i in 0...start_index
      position_index -= @num_points_in_octant
      position_index += @circle_points.length if position_index < 0
    end
    # Start with lower right corner of ball and goes clockwise (to lower left corner)
    for i in 0...@party.length
      icon_sprite = PokemonIconSprite.new(party[i], viewport)
      icon_sprite.setOffset(PictureOrigin::CENTER)
      icon_sprite.x = @circle_points[position_index][0]
      icon_sprite.y = @circle_points[position_index][1]
      icon_sprite.zoom_x = 0.5
      icon_sprite.zoom_y = 0.5
      icon_sprite.opacity = (i == @index) ? 255 : 100
      icon_sprite.update
      @sprites.push(icon_sprite)
      @sprite_position_index_list.push(position_index)
      position_index += @num_points_in_octant
      position_index -= @circle_points.length if position_index >= @circle_points.length
    end
    @updating = false
  end

  def visible=(value)
    @visible = value
    for sprite in @sprites
      sprite.visible = value
    end
  end

  def dispose
    for sprite in @sprites
      sprite.dispose
    end
    super
  end

  def update
    @updating = true
    super
    # Currently highlighted Pokemon is in lower right corner, so don't rotate
    if @sprite_position_index_list[@index] == 0
      @updating = false
      return
    end
    # Rotate all sprites a little
    for i in 0...@sprites.length
      if @moving_up
        @sprite_position_index_list[i] = decrement_index(@sprite_position_index_list[i], @circle_points.length - 1)
      else
        @sprite_position_index_list[i] = increment_index(@sprite_position_index_list[i], @circle_points.length - 1)
      end
      @sprites[i].x = @circle_points[@sprite_position_index_list[i]][0]
      @sprites[i].y = @circle_points[@sprite_position_index_list[i]][1]
      @sprites[i].opacity = (i == @index) ? 255 : 100
      @sprites[i].update
    end
    @updating = false
  end

  # Increments a counter with wrap-around
  def increment_index(index, maximum)
    new_index = index + 1
    new_index = 0 if new_index > maximum
    return new_index
  end

  # Decrements a counter with wrap-around
  def decrement_index(index, maximum)
    new_index = index - 1
    new_index = maximum if new_index < 0
    return new_index
  end

  # Generates set of points along outline of circle for sprites to move along
  def generate_points_along_circle(center_x, center_y, r)
    # Starts from the bottom-most point of the circle, goes counter-clockwise
    # Octant 0 starts from the bottom-most octant on the right, and octants increment counter-clockwise
    octants = Array.new(8) {|i| Array.new}
    x = center_x
    y = center_y + r
    while x < y
      y = (center_y + Math.sqrt(r * r - (x - center_x) * (x - center_x))).round
      dist_x = x - center_x
      dist_y = y - center_y
      octants[0].push([center_x + dist_x, center_y + dist_y])
      octants[1].push([center_x + dist_y, center_y + dist_x])
      octants[2].push([center_x + dist_y, center_y - dist_x])
      octants[3].push([center_x + dist_x, center_y - dist_y])
      octants[4].push([center_x - dist_x, center_y - dist_y])
      octants[5].push([center_x - dist_y, center_y - dist_x])
      octants[6].push([center_x - dist_y, center_y + dist_x])
      octants[7].push([center_x - dist_x, center_y + dist_y])
      x += 1
    end
    # Returns points starting from octant 0 and going clockwise
    points = octants[0].reverse + octants[7] + octants[6].reverse + octants[5] + octants[4].reverse + octants[3] + octants[2].reverse + octants[1]
    return points
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSummary_Scene
  MARK_WIDTH  = 16
  MARK_HEIGHT = 16

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(party, partyindex, inbattle = false, showpartyrotation = false)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @party      = party
    @partyindex = partyindex
    @pokemon    = @party[@partyindex]
    @inbattle   = inbattle
    @page = 1
    @withinsym  = true
    @typebitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Summary/markings")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["partyrotation"] = PartyRotationSprite.new(@viewport, @party, @partyindex)
    @sprites["partyrotation"].visible = showpartyrotation
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokemon"].x = 104
    @sprites["pokemon"].y = 206
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokeicon"].x       = 46
    @sprites["pokeicon"].y       = 92
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"] = ItemIconSprite.new(16, 368, @pokemon.item_id, @viewport)
    @sprites["itemicon"].blankzero = true
    @sprites["itemicon"].zoom_x = 0.5
    @sprites["itemicon"].zoom_y = 0.5
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible     = false
    @sprites["movepresel"].preselected = true
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible = false
    @sprites["ribbonpresel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonpresel"].visible     = false
    @sprites["ribbonpresel"].preselected = true
    @sprites["ribbonsel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonsel"].visible = false
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = 260
    @sprites["uparrow"].y = 110
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = 260
    @sprites["downarrow"].y = 260
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["markingbg"] = IconSprite.new(260, 88, @viewport)
    @sprites["markingbg"].setBitmap("Graphics/Pictures/Summary/overlay_marking")
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["markingoverlay"].visible = false
    pbSetSystemFont(@sprites["markingoverlay"].bitmap)
    @sprites["markingsel"] = IconSprite.new(0, 0, @viewport)
    @sprites["markingsel"].setBitmap("Graphics/Pictures/Summary/cursor_marking")
    @sprites["markingsel"].src_rect.height = @sprites["markingsel"].bitmap.height / 2
    @sprites["markingsel"].visible = false
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"], 2)
    @nationalDexList = [:NONE]
    GameData::Species.each_species { |s| @nationalDexList.push(s.species) }
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartForgetScene(party, partyindex, move_to_learn)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @party      = party
    @partyindex = partyindex
    @pokemon    = @party[@partyindex]
    @page = 5
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokeicon"].x       = 46
    @sprites["pokeicon"].y       = 92
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport, !move_to_learn.nil?)
    @sprites["movesel"].visible = false
    @sprites["movesel"].visible = true
    @sprites["movesel"].index   = 0
    new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
    drawSelectedMove(new_move, @pokemon.moves[0])
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @markingbitmap&.dispose
    @viewport.dispose
  end

  def pbDisplay(text)
    @sprites["messagebox"].text = text
    @sprites["messagebox"].visible = true
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["messagebox"].busy?
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE if @sprites["messagebox"].pausing?
          @sprites["messagebox"].resume
        end
      elsif Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        break
      end
    end
    @sprites["messagebox"].visible = false
  end

  def pbConfirm(text)
    ret = -1
    @sprites["messagebox"].text    = text
    @sprites["messagebox"].visible = true
    using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"), _INTL("No")])) {
      cmdwindow.z       = @viewport.z + 1
      cmdwindow.visible = false
      pbBottomRight(cmdwindow)
      cmdwindow.y -= @sprites["messagebox"].height
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible = true if !@sprites["messagebox"].busy?
        cmdwindow.update
        pbUpdate
        if !@sprites["messagebox"].busy?
          if Input.trigger?(Input::BACK)
            ret = false
            break
          elsif Input.trigger?(Input::USE) && @sprites["messagebox"].resume
            ret = (cmdwindow.index == 0)
            break
          end
        end
      end
    }
    @sprites["messagebox"].visible = false
    return ret
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

  def drawMarkings(bitmap, x, y)
    mark_variants = @markingbitmap.bitmap.height / MARK_HEIGHT
    markings = @pokemon.markings
    markrect = Rect.new(0, 0, MARK_WIDTH, MARK_HEIGHT)
    (@markingbitmap.bitmap.width / MARK_WIDTH).times do |i|
      markrect.x = i * MARK_WIDTH
      markrect.y = [(markings[i] || 0), mark_variants - 1].min * MARK_HEIGHT
      bitmap.blt(x + (i * MARK_WIDTH), y, @markingbitmap.bitmap, markrect)
    end
  end

  def drawPage(page)
    if @pokemon.egg?
      if page == 1
        drawPageOneEgg
      else
        drawPageTwoEgg
      end
      return
    end
    @sprites["itemicon"].item = @pokemon.item_id
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary New/summary#{page}" + (@pokemon.fainted? ? "f" : ""))
    imagepos = []
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
    imagepos.push([ballimage, 14, 60])
    # Show status/fainted/Pokérus infected icon
    status = -1
    if @pokemon.fainted?
      status = GameData::Status.count - 1
    elsif @pokemon.status == :POISON && @pokemon.statusCount > 0
      status = GameData::Status.count + 1
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).icon_position
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status.count
    end
    if status >= 0
      imagepos.push(["Graphics/Pictures/Summary New/summaryStatuses", 120, 96, 0, 20 * status, 55, 20])
    end
    # Show Pokérus cured icon
    if @pokemon.pokerusStage == 2
      imagepos.push([sprintf("Graphics/Pictures/pokerus"), 176, 98])
    end
    # Show shininess star
    if @pokemon.shiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"), 2, 134])
    end
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
    # Write various bits of text
    textpos = [
      [@pokemon.name, 46, 68, 0, base, shadow, 1],
      [@pokemon.level.to_s, 54, 98, 0, base, shadow, 1],
      [_INTL("Item"), 16, 324, 0, base, shadow, 1]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name, 40, 358, 0, base, shadow, 1])
    else
      textpos.push([_INTL("None"), 16, 358, 0, base, shadow, 1])
    end
    # Write the gender symbol
    if @pokemon.male?
      textpos.push([_INTL("♂"), 178, 68, 0, Color.new(24, 112, 216), shadow, 1])
    elsif @pokemon.female?
      textpos.push([_INTL("♀"), 178, 68, 0, Color.new(248, 56, 32), shadow, 1])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw the Pokémon's markings
    drawMarkings(overlay, 84, 292)
    # Draw page-specific information
    case page
    when 1 then drawPageOne
    when 2 then drawPageTwo
    when 3 then drawPageThree
    when 4 then drawPageFour
    when 5 then drawPageFive
    when 6 then drawPageSix
    end
  end

  def drawPageOne
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    dexNumBase   = (@pokemon.shiny?) ? Color.new(248, 56, 32) : Color.new(64, 64, 64)
    dexNumShadow = (@pokemon.shiny?) ? Color.new(224, 152, 144) : Color.new(176, 176, 176)
    # If a Shadow Pokémon, draw the heart gauge area and bar
    if @pokemon.shadowPokemon?
      shadowfract = @pokemon.heart_gauge.to_f / @pokemon.max_gauge_size
      imagepos = [
        ["Graphics/Pictures/Summary New/summaryShadow", 224, 240],
        ["Graphics/Pictures/Summary New/summaryShadowBar", 242, 280, 0, 0, (shadowfract * 248).floor, -1]
      ]
      pbDrawImagePositions(overlay, imagepos)
    end
    # Write various bits of text
    textpos = [
      [_INTL("Dex No."), 238, 86, 0, base, shadow, 1],
      [_INTL("Species"), 238, 118, 0, base, shadow, 1],
      [@pokemon.speciesName, 419, 118, 2, base, shadow, 1],
      [_INTL("Type"), 238, 150, 0, base, shadow, 1],
      [_INTL("OT"), 238, 182, 0, base, shadow, 1],
      [_INTL("ID No."), 238, 214, 0, base, shadow, 1]
    ]
    # Write the Regional/National Dex number
    dexnum = 0
    dexnumshift = false
    if $player.pokedex.unlocked?(-1)   # National Dex is unlocked
      dexnum = @nationalDexList.index(@pokemon.species_data.species) || 0
      dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(-1)
    else
      ($player.pokedex.dexes_count - 1).times do |i|
        next if !$player.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i, @pokemon.species)
        next if num <= 0
        dexnum = num
        dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    if dexnum <= 0
      textpos.push(["???", 419, 86, 2, base, shadow, 1])
    else
      dexnum -= 1 if dexnumshift
      textpos.push([sprintf("%03d", dexnum), 419, 86, 2, base, shadow, 1])
    end
    # Write Original Trainer's name and ID number
    if @pokemon.owner.name.empty?
      textpos.push([_INTL("RENTAL"), 419, 182, 2, base, shadow, 1])
      textpos.push(["?????", 419, 214, 2, base, shadow, 1])
    else
      ownerbase   = Color.new(64, 64, 64)
      ownershadow = Color.new(176, 176, 176)
      case @pokemon.owner.gender
      when 0
        ownerbase = Color.new(24, 112, 216)
        ownershadow = Color.new(136, 168, 208)
      when 1
        ownerbase = Color.new(248, 56, 32)
        ownershadow = Color.new(224, 152, 144)
      end
      textpos.push([@pokemon.owner.name, 419, 182, 2, base, shadow, 1])
      textpos.push([sprintf("%05d", @pokemon.owner.public_id), 419, 214, 2,
                    base, shadow, 1])
    end
    # Write Exp text OR heart gauge message (if a Shadow Pokémon)
    if @pokemon.shadowPokemon?
      textpos.push([_INTL("Heart Gauge"), 238, 246, 0, base, shadow])
      heartmessage = [_INTL("The door to its heart is open! Undo the final lock!"),
                      _INTL("The door to its heart is almost fully open."),
                      _INTL("The door to its heart is nearly open."),
                      _INTL("The door to its heart is opening wider."),
                      _INTL("The door to its heart is opening up."),
                      _INTL("The door to its heart is tightly shut.")][@pokemon.heartStage]
      memo = sprintf("<c3=404040,B0B0B0>%s\n", heartmessage)
      drawFormattedTextEx(overlay, 234, 308, 264, memo)
    else
      endexp = @pokemon.growth_rate.minimum_exp_for_level(@pokemon.level + 1)
      textpos.push([_INTL("KOs"), 234, 278, 0, base, shadow, 1])
      textpos.push([_INTL("Damage"), 234, 310, 0, base, shadow, 1])
      textpos.push([@pokemon.exp.to_s, 494, 344, 1, base, shadow, 1])
      textpos.push([(endexp - @pokemon.exp).to_s, 286, 362, 1, base, shadow, 1])
      # Draw KO count
      if !@pokemon.ko_count_max?
        textpos.push([_INTL(@pokemon.ko_count.to_s), 402, 278, 1, Color.new(153,255,255), shadow, 1])
      else
        pbDrawImagePositions(overlay,
                           [["Graphics/Pictures/Summary New/summaryMAXPositive", 360, 278, 0, 0]])
      end
      # Draw faint count
      if !@pokemon.faint_count_max?
        textpos.push([_INTL(@pokemon.faint_count.to_s), 500, 278, 1, Color.new(255,191,191), shadow, 1])
      else
        pbDrawImagePositions(overlay,
                           [["Graphics/Pictures/Summary New/summaryMAXNegative", 458, 278, 0, 0]])
      end
      # Draw damage dealt
      if !@pokemon.damage_dealt_max?
        textpos.push([_INTL(@pokemon.damage_dealt.to_s), 402, 310, 1, Color.new(153,255,255), shadow, 1])
      else
        pbDrawImagePositions(overlay,
                           [["Graphics/Pictures/Summary New/summaryMAXPositive", 360, 310, 0, 0]])
      end
      # Draw damage taken
      if !@pokemon.damage_taken_max?
        textpos.push([_INTL(@pokemon.damage_taken.to_s), 500, 310, 1, Color.new(255,191,191), shadow, 1])
      else
        pbDrawImagePositions(overlay,
                           [["Graphics/Pictures/Summary New/summaryMAXNegative", 458, 310, 0, 0]])
      end
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw Pokémon type(s)
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_rect = Rect.new(0, type_number * 27, 63, 27)
      type_x = (@pokemon.types.length == 1) ? 386 : 354 + (65 * i)
      overlay.blt(type_x, 146, @typebitmap.bitmap, type_rect)
    end
    # Draw Exp bar
    if @pokemon.level < GameData::GrowthRate.max_level
      w = @pokemon.exp_fraction * 132
      w = ((w / 2).round) * 2
      pbDrawImagePositions(overlay,
                           [["Graphics/Pictures/Summary New/summaryEXPBar", 360, 372, 0, 0, w, 6]])
    end
  end

  def drawPageOneEgg
    @sprites["itemicon"].item = @pokemon.item_id
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary New/summaryEgg")
    imagepos = []
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
    imagepos.push([ballimage, 14, 60])
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
    # Write various bits of text
    textpos = [
      [@pokemon.name, 46, 68, 0, base, shadow, 1],
      [_INTL("Item"), 16, 324, 0, base, shadow, 1]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name, 40, 358, 0, base, shadow, 1])
    else
      textpos.push([_INTL("None"), 16, 358, 0, base, shadow, 1])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    memo = "<outln2>"
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += _INTL("{1} {2}, {3}\n", date, month, year)
    end
    # Write map name egg was received on
    mapname = pbGetMapNameFromId(@pokemon.obtain_map)
    mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    if mapname && mapname != ""
      memo += _INTL("\nA mysterious Pokémon Egg received from <c3=FF9999>{1}</c3>.\n", mapname)
    else
      memo += _INTL("\nA mysterious Pokémon Egg.\n", mapname)
    end
    memo += "\n" # Empty line
    # Write Egg Watch blurb
    memo += _INTL("\"The Egg Watch\"\n")
    eggstate = _INTL("It looks like this Egg will take a long time to hatch.")
    eggstate = _INTL("What will hatch from this? It doesn't seem close to hatching.") if @pokemon.steps_to_hatch < 10_200
    eggstate = _INTL("It appears to move occasionally. It may be close to hatching.") if @pokemon.steps_to_hatch < 2550
    eggstate = _INTL("Sounds can be heard coming from inside! It will hatch soon!") if @pokemon.steps_to_hatch < 1275
    memo += sprintf("%s\n", eggstate)
    # Draw all text
    drawFormattedTextEx(overlay, 232, 86, 268, memo, base, shadow)
    # Draw the Pokémon's markings
    drawMarkings(overlay, 84, 292)
  end

  def drawPageTwo
    overlay = @sprites["overlay"].bitmap
    memo = "<outln2><fn=Power Green>"
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    # Write nature
    showNature = !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
    if showNature
      natureName = @pokemon.nature.name
      memo += _INTL("<c3=FF9999>{1}</c3> nature.\n", natureName)
    end
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += _INTL("{1} {2}, {3}\n", date, month, year)
    end
    # Write map name Pokémon was received on
    mapname = pbGetMapNameFromId(@pokemon.obtain_map)
    mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    mapname = _INTL("<c3=FF9999>Faraway place</c3>") if nil_or_empty?(mapname)
    memo += sprintf("\n<c3=FF9999>%s</c3>\n", mapname)
    # Write how Pokémon was obtained
    mettext = [_INTL("Met at Lv. {1}.", @pokemon.obtain_level),
               _INTL("Egg received."),
               _INTL("Traded at Lv. {1}.", @pokemon.obtain_level),
               "",
               _INTL("Had a fateful encounter at Lv. {1}.", @pokemon.obtain_level)][@pokemon.obtain_method]
    memo += sprintf("%s\n", mettext) if mettext && mettext != ""
    # If Pokémon was hatched, write when and where it hatched
    if @pokemon.obtain_method == 1
      if @pokemon.timeEggHatched
        date  = @pokemon.timeEggHatched.day
        month = pbGetMonthName(@pokemon.timeEggHatched.mon)
        year  = @pokemon.timeEggHatched.year
        memo += _INTL("{1} {2}, {3}\n", date, month, year)
      end
      mapname = pbGetMapNameFromId(@pokemon.hatched_map)
      mapname = _INTL("Faraway place") if nil_or_empty?(mapname)
      memo += sprintf("%s\n", mapname)
      memo += _INTL("Egg hatched.\n")
    else
      memo += "\n"   # Empty line
    end
    # Write characteristic
    if showNature
      best_stat = nil
      best_iv = 0
      stats_order = [:HP, :ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE]
      start_point = @pokemon.personalID % stats_order.length   # Tiebreaker
      stats_order.length.times do |i|
        stat = stats_order[(i + start_point) % stats_order.length]
        if !best_stat || @pokemon.iv[stat] > @pokemon.iv[best_stat]
          best_stat = stat
          best_iv = @pokemon.iv[best_stat]
        end
      end
      characteristics = {
        :HP              => [_INTL("Loves to eat."),
                             _INTL("Takes plenty of siestas."),
                             _INTL("Nods off a lot."),
                             _INTL("Scatters things often."),
                             _INTL("Likes to relax.")],
        :ATTACK          => [_INTL("Proud of its power."),
                             _INTL("Likes to thrash about."),
                             _INTL("A little quick tempered."),
                             _INTL("Likes to fight."),
                             _INTL("Quick tempered.")],
        :DEFENSE         => [_INTL("Sturdy body."),
                             _INTL("Capable of taking hits."),
                             _INTL("Highly persistent."),
                             _INTL("Good endurance."),
                             _INTL("Good perseverance.")],
        :SPECIAL_ATTACK  => [_INTL("Highly curious."),
                             _INTL("Mischievous."),
                             _INTL("Thoroughly cunning."),
                             _INTL("Often lost in thought."),
                             _INTL("Very finicky.")],
        :SPECIAL_DEFENSE => [_INTL("Strong willed."),
                             _INTL("Somewhat vain."),
                             _INTL("Strongly defiant."),
                             _INTL("Hates to lose."),
                             _INTL("Somewhat stubborn.")],
        :SPEED           => [_INTL("Likes to run."),
                             _INTL("Alert to sounds."),
                             _INTL("Impetuous and silly."),
                             _INTL("Somewhat of a clown."),
                             _INTL("Quick to flee.")]
      }
      memo += sprintf("%s\n", characteristics[best_stat][best_iv % 5])
    end
    # Write all text
    drawFormattedTextEx(overlay, 232, 86, 268, memo, base, shadow)
  end

  def drawPageTwoEgg
    @sprites["itemicon"].item = @pokemon.item_id
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary New/summaryEgg2")
    imagepos = []
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
    imagepos.push([ballimage, 14, 60])
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
    # Write various bits of text
    textpos = [
      [@pokemon.name, 46, 68, 0, base, shadow, 1],
      [_INTL("Item"), 16, 324, 0, base, shadow, 1]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name, 40, 358, 0, base, shadow, 1])
    else
      textpos.push([_INTL("None"), 16, 358, 0, base, shadow, 1])
    end
    # Show family tree
    # Father
    if @pokemon.family_tree&.father
      father = @pokemon.family_tree.father
      father_bitmap = Bitmap.new(GameData::Species.icon_filename_from_family_tree_node(father))
      w = father_bitmap.width
      h = father_bitmap.height
      overlay.blt(294 - (w / 4), 170 - (h / 2), father_bitmap, Rect.new(0, 0, w / 2, h))
      textpos.push([father.name, 342, 140, 0, base, shadow, 1])
      textpos.push([sprintf("%s", father.species), 342, 178, 0, base, shadow, 1])
      # Write the gender symbol
      if father.gender == 0
        textpos.push([_INTL("♂"), 472, 140, 0, Color.new(24, 112, 216), shadow, 1])
      elsif father.gender == 1
        textpos.push([_INTL("♀"), 472, 140, 0, Color.new(248, 56, 32), shadow, 1])
      end
    else
      father_bitmap = Bitmap.new("Graphics/Pokemon/Icons/000")
      w = father_bitmap.width
      h = father_bitmap.height
      overlay.blt(294 - (w / 4), 170 - (h / 2), father_bitmap, Rect.new(0, 0, w / 2, h))
      textpos.push(["???", 342, 140, 0, base, shadow, 1])
      textpos.push(["???", 342, 178, 0, base, shadow, 1])
    end
    # Mother
    if @pokemon.family_tree&.mother
      mother = @pokemon.family_tree.mother
      mother_bitmap = Bitmap.new(GameData::Species.icon_filename_from_family_tree_node(mother))
      w = mother_bitmap.width
      h = mother_bitmap.height
      overlay.blt(294 - (w / 4), 278 - (h / 2), mother_bitmap, Rect.new(0, 0, w / 2, h))
      textpos.push([mother.name, 342, 248, 0, base, shadow, 1])
      textpos.push([sprintf("%s", mother.species), 342, 286, 0, base, shadow, 1])
      # Write the gender symbol
      if mother.gender == 0
        textpos.push([_INTL("♂"), 472, 248, 0, Color.new(24, 112, 216), shadow, 1])
      elsif mother.gender == 1
        textpos.push([_INTL("♀"), 472, 248, 0, Color.new(248, 56, 32), shadow, 1])
      end
    else
      mother_bitmap = Bitmap.new("Graphics/Pokemon/Icons/000")
      w = mother_bitmap.width
      h = mother_bitmap.height
      overlay.blt(294 - (w / 4), 278 - (h / 2), mother_bitmap, Rect.new(0, 0, w / 2, h))
      textpos.push(["???", 342, 248, 0, base, shadow, 1])
      textpos.push(["???", 342, 286, 0, base, shadow, 1])
    end
    # Grandparents
    for i in 2..5
      grandparent_bitmap = nil
      if @pokemon.family_tree && @pokemon.family_tree.tree[i]
        grandparent_bitmap = Bitmap.new(GameData::Species.icon_filename_from_family_tree_node(@pokemon.family_tree.tree[i]))
      else
        grandparent_bitmap = Bitmap.new("Graphics/Pokemon/Icons/000")
      end
      x = [406, 450, 406, 450][i - 2]
      y = [90, 90, 318, 318][i - 2]
      overlay.stretch_blt(Rect.new(x, y, 40, 40), grandparent_bitmap, Rect.new(0, 0, grandparent_bitmap.width / 2, grandparent_bitmap.height))
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw the Pokémon's markings
    drawMarkings(overlay, 84, 292)
  end

  def drawPageThree
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    # Determine which stats are boosted and lowered by the Pokémon's nature
    statshadows = {}
    GameData::Stat.each_main { |s| statshadows[s.id] = shadow }
    if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        statshadows[change[0]] = Color.new(136, 96, 72) if change[1] > 0
        statshadows[change[0]] = Color.new(64, 120, 152) if change[1] < 0
      end
    end
    # Write various bits of text
    textpos = [
      [_INTL("HP"), 292, 82, 2, base, shadow, 1],
      [sprintf("%d/%d", @pokemon.hp, @pokemon.totalhp), 462, 82, 1, base, shadow, 1],
      [_INTL("Attack"), 248, 126, 0, base, shadow, 1],
      [sprintf("%d", @pokemon.attack), 456, 126, 1, base, shadow, 1],
      [_INTL("Defense"), 248, 158, 0, base, shadow, 1],
      [sprintf("%d", @pokemon.defense), 456, 158, 1, base, shadow, 1],
      [_INTL("Sp. Atk"), 248, 190, 0, base, shadow, 1],
      [sprintf("%d", @pokemon.spatk), 456, 190, 1, base, shadow, 1],
      [_INTL("Sp. Def"), 248, 222, 0, base, shadow, 1],
      [sprintf("%d", @pokemon.spdef), 456, 222, 1, base, shadow, 1],
      [_INTL("Speed"), 248, 254, 0, base, shadow, 1],
      [sprintf("%d", @pokemon.speed), 456, 254, 1, base, shadow, 1],
      [_INTL("Ability"), 224, 290, 0, base, shadow, 1]
    ]
    # Draw ability name and description
    ability = @pokemon.ability
    if ability
      textpos.push([ability.name, 362, 290, 0, base, shadow, 1])
      drawFormattedTextEx(overlay, 224, 322, 282, "<outln2>" + ability.description, base, shadow)
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw HP bar
    if @pokemon.hp > 0
      w = @pokemon.hp * 96 / @pokemon.totalhp.to_f
      w = 1 if w < 1
      w = ((w / 2).round) * 2
      hpzone = 0
      hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
      hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
      imagepos = [
        ["Graphics/Pictures/Summary/overlay_hp", 360, 110, 0, hpzone * 6, w, 6]
      ]
      pbDrawImagePositions(overlay, imagepos)
    end
  end

  def drawPageFour
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    # Write various bits of text
    textpos = [
      [_INTL("HP"), 248, 96, 0, base, shadow, 1],
      [_INTL("Attack"), 248, 126, 0, base, shadow, 1],
      [_INTL("Defense"), 248, 158, 0, base, shadow, 1],
      [_INTL("Sp. Atk"), 248, 190, 0, base, shadow, 1],
      [_INTL("Sp. Def"), 248, 222, 0, base, shadow, 1],
      [_INTL("Speed"), 248, 254, 0, base, shadow, 1],
      [_INTL("Typology"), 248, 314, 0, base, shadow, 1],
      [_INTL(@pokemon.typology.name), 360, 314, 0, base, shadow, 1]
    ]
    endexp = @pokemon.growth_rate.minimum_exp_for_level(@pokemon.level + 1)
    textpos.push([@pokemon.exp.to_s, 494, 344, 1, base, shadow, 1])
    textpos.push([(endexp - @pokemon.exp).to_s, 286, 362, 1, base, shadow, 1])
    # Typology icon
    imagepos = [[sprintf("Graphics/Pictures/Typologies/typology_%s", @pokemon.typology.id), 458, 312]]
    # Draw EVs and IVs
    if !@withinsym
      # EVs
      textpos.push([@pokemon.ev[:HP].to_s, 422, 96, 1, base, shadow, 1])
      textpos.push([@pokemon.ev[:ATTACK].to_s, 422, 126, 1, base, shadow, 1])
      textpos.push([@pokemon.ev[:DEFENSE].to_s, 422, 158, 1, base, shadow, 1])
      textpos.push([@pokemon.ev[:SPECIAL_ATTACK].to_s, 422, 190, 1, base, shadow, 1])
      textpos.push([@pokemon.ev[:SPECIAL_DEFENSE].to_s, 422, 222, 1, base, shadow, 1])
      textpos.push([@pokemon.ev[:SPEED].to_s, 422, 254, 1, base, shadow, 1])
      # IVs
      textpos.push([@pokemon.iv[:HP].to_s, 482, 96, 1, base, shadow, 1])
      textpos.push([@pokemon.iv[:ATTACK].to_s, 482, 126, 1, base, shadow, 1])
      textpos.push([@pokemon.iv[:DEFENSE].to_s, 482, 158, 1, base, shadow, 1])
      textpos.push([@pokemon.iv[:SPECIAL_ATTACK].to_s, 482, 190, 1, base, shadow, 1])
      textpos.push([@pokemon.iv[:SPECIAL_DEFENSE].to_s, 482, 222, 1, base, shadow, 1])
      textpos.push([@pokemon.iv[:SPEED].to_s, 482, 254, 1, base, shadow, 1])
    else
      # EVs
      imagepos.push([getEVImageName(@pokemon.ev[:HP]), 391, 90])
      imagepos.push([getEVImageName(@pokemon.ev[:ATTACK]), 391, 120])
      imagepos.push([getEVImageName(@pokemon.ev[:DEFENSE]), 391, 152])
      imagepos.push([getEVImageName(@pokemon.ev[:SPECIAL_ATTACK]), 391, 184])
      imagepos.push([getEVImageName(@pokemon.ev[:SPECIAL_DEFENSE]), 391, 216])
      imagepos.push([getEVImageName(@pokemon.ev[:SPEED]), 391, 248])
      # IVs
      imagepos.push([getIVImageName(@pokemon.iv[:HP]), 456, 90])
      imagepos.push([getIVImageName(@pokemon.iv[:ATTACK]), 456, 120])
      imagepos.push([getIVImageName(@pokemon.iv[:DEFENSE]), 456, 152])
      imagepos.push([getIVImageName(@pokemon.iv[:SPECIAL_ATTACK]), 456, 184])
      imagepos.push([getIVImageName(@pokemon.iv[:SPECIAL_DEFENSE]), 456, 216])
      imagepos.push([getIVImageName(@pokemon.iv[:SPEED]), 456, 248])
    end
    # Draw Exp bar
    if @pokemon.level < GameData::GrowthRate.max_level
      w = @pokemon.exp_fraction * 132
      w = ((w / 2).round) * 2
      imagepos.push(["Graphics/Pictures/Summary New/summaryEXPBar", 360, 372, 0, 0, w, 6])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
  end

  def getEVImageName(ev)
    name = "Graphics/Pictures/Summary New/summaryEV"
    if ev == 252
      return name + "252"
    elsif ev >= 250
      return name + "250"
    end
    return name + sprintf("%03d", 40 * (ev / 40).floor)
  end

  def getIVImageName(iv)
    name = "Graphics/Pictures/Summary New/summaryIV"
    if iv == 31
      return name + "31"
    end
    return name + sprintf("%02d", 5 * (iv / 5).floor)
  end

  def drawPageFive
    overlay = @sprites["overlay"].bitmap
    moveBase   = Color.new(248, 248, 248)
    moveShadow = Color.new(66, 66, 81)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248, 192, 0),    # 1/2 of total PP or less
                Color.new(248, 136, 32),   # 1/4 of total PP or less
                Color.new(248, 72, 72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144, 104, 0),   # 1/2 of total PP or less
                Color.new(144, 72, 24),   # 1/4 of total PP or less
                Color.new(136, 48, 48)]   # Zero PP
    @sprites["pokemon"].visible  = true
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"].visible = true
    textpos  = []
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 104
    Pokemon::MAX_MOVES.times do |i|
      move = @pokemon.moves[i]
      if move
        type_number = GameData::Type.get(move.display_type(@pokemon)).icon_position
        imagepos.push(["Graphics/Pictures/types", 248, yPos - 4, 0, type_number * 27, 63, 27])
        textpos.push([move.name, 316, yPos, 0, moveBase, moveShadow, 1])
        if move.total_pp > 0
          textpos.push([_INTL("PP"), 342, yPos + 32, 0, moveBase, moveShadow, 1])
          ppfraction = 0
          if move.pp == 0
            ppfraction = 3
          elsif move.pp * 4 <= move.total_pp
            ppfraction = 2
          elsif move.pp * 2 <= move.total_pp
            ppfraction = 1
          end
          textpos.push([sprintf("%d/%d", move.pp, move.total_pp), 460, yPos + 32, 1, ppBase[ppfraction], ppShadow[ppfraction], 1])
        end
      else
        textpos.push(["-", 316, yPos, 0, moveBase, moveShadow, 1])
        textpos.push(["--", 442, yPos + 32, 1, moveBase, moveShadow, 1])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
  end

  def drawPageFiveSelecting(move_to_learn)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    moveBase   = Color.new(64, 64, 64)
    moveShadow = Color.new(176, 176, 176)
    ppBase   = [base,                # More than 1/2 of total PP
                Color.new(248, 192, 0),    # 1/2 of total PP or less
                Color.new(248, 136, 32),   # 1/4 of total PP or less
                Color.new(248, 72, 72)]    # Zero PP
    ppShadow = [shadow,             # More than 1/2 of total PP
                Color.new(144, 104, 0),   # 1/2 of total PP or less
                Color.new(144, 72, 24),   # 1/4 of total PP or less
                Color.new(136, 48, 48)]   # Zero PP
    # Set background image
    if move_to_learn
      @sprites["background"].setBitmap("Graphics/Pictures/Summary New/summary5learn" + (@pokemon.fainted? ? "f" : ""))
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Summary New/summary5desc" + (@pokemon.fainted? ? "f" : ""))
    end
    # Write various bits of text
    textpos = [
      [_INTL("CATEGORY"), 20, 128, 0, base, shadow, 1],
      [_INTL("POWER"), 20, 160, 0, base, shadow, 1],
      [_INTL("ACCURACY"), 20, 192, 0, base, shadow, 1]
    ]
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 104
    yPos -= 40 if move_to_learn
    limit = (move_to_learn) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
    limit.times do |i|
      move = @pokemon.moves[i]
      if i == Pokemon::MAX_MOVES
        move = move_to_learn
        yPos += 4
      end
      if move
        type_number = GameData::Type.get(move.display_type(@pokemon)).icon_position
        imagepos.push(["Graphics/Pictures/types", 248, yPos - 4, 0, type_number * 27, 63, 27])
        textpos.push([move.name, 316, yPos, 0, base, shadow, 1])
        if move.total_pp > 0
          textpos.push([_INTL("PP"), 342, yPos + 32, 0, base, shadow, 1])
          ppfraction = 0
          if move.pp == 0
            ppfraction = 3
          elsif move.pp * 4 <= move.total_pp
            ppfraction = 2
          elsif move.pp * 2 <= move.total_pp
            ppfraction = 1
          end
          textpos.push([sprintf("%d/%d", move.pp, move.total_pp), 460, yPos + 32, 1, ppBase[ppfraction], ppShadow[ppfraction], 1])
        end
      else
        textpos.push(["-", 316, yPos, 0, base, shadow, 1])
        textpos.push(["--", 442, yPos + 32, 1, base, shadow, 1])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
    # Draw Pokémon's type icon(s)
    @pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_rect = Rect.new(0, type_number * 27, 63, 27)
      type_x = (@pokemon.types.length == 1) ? 130 : 96 + (69 * i)
      overlay.blt(type_x, 78, @typebitmap.bitmap, type_rect)
    end
  end

  def drawSelectedMove(move_to_learn, selected_move)
    # Draw all of page five, except selected move's details
    drawPageFiveSelecting(move_to_learn)
    # Set various values
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    @sprites["pokemon"].visible = false if @sprites["pokemon"]
    @sprites["pokeicon"].pokemon = @pokemon
    @sprites["pokeicon"].visible = true
    @sprites["itemicon"].visible = false if @sprites["itemicon"]
    textpos = []
    # Write power and accuracy values for selected move
    case selected_move.display_damage(@pokemon)
    when 0 then textpos.push(["---", 216, 160, 1, base, shadow, 1])   # Status move
    when 1 then textpos.push(["???", 216, 160, 1, base, shadow, 1])   # Variable power move
    else        textpos.push([selected_move.display_damage(@pokemon).to_s, 216, 160, 1, base, shadow, 1])
    end
    if selected_move.display_accuracy(@pokemon) == 0
      textpos.push(["---", 216, 192, 1, base, shadow, 1])
    else
      textpos.push(["#{selected_move.display_accuracy(@pokemon)}%", 216 + overlay.text_size("%").width, 192, 1, base, shadow, 1])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw selected move's damage category icon
    imagepos = [["Graphics/Pictures/category", 166, 124, 0, selected_move.display_category(@pokemon) * 28, 64, 28]]
    pbDrawImagePositions(overlay, imagepos)
    # Draw selected move's description
    normtext = getLineBrokenChunks(overlay, selected_move.description, 230, nil)
    textpos = []
    for text in normtext
      next if text[2] >= 5 * 32 # Max of 5 lines of text
      textpos.push([text[0], 4 + text[1], 224 + text[2], 0, base, shadow, 1])
    end
    pbDrawTextPositions(overlay, textpos)
  end

  def drawPageSix
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
    @sprites["itemicon"].visible = true if @sprites["itemicon"]
    # Write various bits of text
    textpos = [
      [_INTL("No. of Ribbons:"), 234, 350, 0, base, shadow, 1],
      [@pokemon.numRibbons.to_s, 450, 350, 1, base, shadow, 1]
    ]
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Show all ribbons
    imagepos = []
    coord = 0
    (@ribbonOffset * 5...(@ribbonOffset * 5) + 12).each do |i|
      break if !@pokemon.ribbons[i]
      ribbon_data = GameData::Ribbon.get(@pokemon.ribbons[i])
      ribn = ribbon_data.icon_position
      imagepos.push(["Graphics/Pictures/ribbons",
                     236 + (64 * (coord % 4)), 88 + (80 * (coord / 4).floor),
                     64 * (ribn % 8), 64 * (ribn / 8).floor, 64, 64])
      coord += 1
    end
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
  end

  def drawSelectedRibbon(ribbonid)
    @sprites["itemicon"].visible = false if @sprites["itemicon"]
    # Set various values
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary New/summary6desc" + (@pokemon.fainted? ? "f" : ""))
    # Get data for selected ribbon
    name = ribbonid ? GameData::Ribbon.get(ribbonid).name : ""
    rarity = ribbonid ? GameData::Ribbon.get(ribbonid).rarity : ""
    small_desc = ribbonid ? GameData::Ribbon.get(ribbonid).small_description : ""
    desc = ribbonid ? GameData::Ribbon.get(ribbonid).description : ""
    # Show all ribbons
    imagepos = []
    coord = 0
    (@ribbonOffset * 5...(@ribbonOffset * 5) + 10).each do |i|
      break if !@pokemon.ribbons[i]
      ribbon_data = GameData::Ribbon.get(@pokemon.ribbons[i])
      ribn = ribbon_data.icon_position
      imagepos.push(["Graphics/Pictures/ribbons",
                     100 + (72 * (coord % 5)), 136 + (80 * (coord / 5).floor),
                     64 * (ribn % 8), 64 * (ribn / 8).floor, 64, 64])
      coord += 1
    end
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
    # Draw name of selected ribbon
    textpos = [
      [name, 34, 68, 0, base, shadow, 1],
      [rarity, 52, 98, 0, base, shadow, 1],
      [small_desc, 8, 298, 0, base, shadow, 1]
    ]
    pbDrawTextPositions(overlay, textpos)
    # Draw selected ribbon's description
    drawFormattedTextEx(overlay, 18, 328, 448, "<outln2><fn=Power Green>" + desc, base, shadow)
  end

  def pbGoToPrevious
    newindex = @partyindex
    while newindex > 0
      newindex -= 1
      if @party[newindex] && (@page == 1 || (@page == 2 && @party[newindex].egg? == @party[@partyindex].egg?) || (@page > 2 && !@party[newindex].egg?))
        @partyindex = newindex
        break
      end
    end
  end

  def pbGoToNext
    newindex = @partyindex
    while newindex < @party.length - 1
      newindex += 1
      if @party[newindex] && (@page == 1 || (@page == 2 && @party[newindex].egg? == @party[@partyindex].egg?) || (@page > 2 && !@party[newindex].egg?))
        @partyindex = newindex
        break
      end
    end
  end

  def pbChangePokemon
    @pokemon = @party[@partyindex]
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["itemicon"].item = @pokemon.item_id
    pbSEStop
    @pokemon.play_cry
  end

  def pbMoveSelection
    @sprites["movesel"].visible = true
    @sprites["movesel"].index   = 0
    @sprites["movesel"].pokemon = @pokemon
    @sprites["movepresel"].pokemon = @pokemon
    selmove    = 0
    oldselmove = 0
    switching = false
    drawSelectedMove(nil, @pokemon.moves[selmove])
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["movepresel"].index == @sprites["movesel"].index
        @sprites["movepresel"].z = @sprites["movesel"].z + 1
      else
        @sprites["movepresel"].z = @sprites["movesel"].z
      end
      if Input.trigger?(Input::BACK)
        (switching) ? pbPlayCancelSE : pbPlayCloseMenuSE
        break if !switching
        @sprites["movepresel"].visible = false
        switching = false
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        if selmove == Pokemon::MAX_MOVES
          break if !switching
          @sprites["movepresel"].visible = false
          switching = false
        elsif !@pokemon.shadowPokemon?
          if switching
            tmpmove                    = @pokemon.moves[oldselmove]
            @pokemon.moves[oldselmove] = @pokemon.moves[selmove]
            @pokemon.moves[selmove]    = tmpmove
            @sprites["movepresel"].visible = false
            switching = false
            drawSelectedMove(nil, @pokemon.moves[selmove])
          else
            @sprites["movepresel"].index   = selmove
            @sprites["movepresel"].visible = true
            oldselmove = selmove
            switching = true
          end
        end
      elsif Input.trigger?(Input::UP)
        selmove -= 1
        if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
          selmove = @pokemon.numMoves - 1
        end
        selmove = 0 if selmove >= Pokemon::MAX_MOVES
        selmove = @pokemon.numMoves - 1 if selmove < 0
        @sprites["movesel"].index = selmove
        pbPlayCursorSE
        drawSelectedMove(nil, @pokemon.moves[selmove])
      elsif Input.trigger?(Input::DOWN)
        selmove += 1
        selmove = 0 if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
        selmove = 0 if selmove >= Pokemon::MAX_MOVES
        selmove = Pokemon::MAX_MOVES if selmove < 0
        @sprites["movesel"].index = selmove
        pbPlayCursorSE
        drawSelectedMove(nil, @pokemon.moves[selmove])
      end
    end
    @sprites["movesel"].visible = false
  end

  def pbRibbonSelection
    @sprites["ribbonsel"].visible = true
    @sprites["ribbonsel"].index   = 0
    selribbon    = @ribbonOffset * 5
    oldselribbon = selribbon
    switching = false
    numRibbons = @pokemon.ribbons.length
    numRows    = [((numRibbons + 4) / 5).floor, 2].max
    drawSelectedRibbon(@pokemon.ribbons[selribbon])
    loop do
      @sprites["uparrow"].visible   = (@ribbonOffset > 0)
      @sprites["downarrow"].visible = (@ribbonOffset < numRows - 2)
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["ribbonpresel"].index == @sprites["ribbonsel"].index
        @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z + 1
      else
        @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z
      end
      hasMovedCursor = false
      if Input.trigger?(Input::BACK)
        (switching) ? pbPlayCancelSE : pbPlayCloseMenuSE
        break if !switching
        @sprites["ribbonpresel"].visible = false
        switching = false
      elsif Input.trigger?(Input::USE)
        if switching
          pbPlayDecisionSE
          tmpribbon                      = @pokemon.ribbons[oldselribbon]
          @pokemon.ribbons[oldselribbon] = @pokemon.ribbons[selribbon]
          @pokemon.ribbons[selribbon]    = tmpribbon
          if @pokemon.ribbons[oldselribbon] || @pokemon.ribbons[selribbon]
            @pokemon.ribbons.compact!
            if selribbon >= numRibbons
              selribbon = numRibbons - 1
              hasMovedCursor = true
            end
          end
          @sprites["ribbonpresel"].visible = false
          switching = false
          drawSelectedRibbon(@pokemon.ribbons[selribbon])
        else
          if @pokemon.ribbons[selribbon]
            pbPlayDecisionSE
            @sprites["ribbonpresel"].index = selribbon - (@ribbonOffset * 5)
            oldselribbon = selribbon
            @sprites["ribbonpresel"].visible = true
            switching = true
          end
        end
      elsif Input.trigger?(Input::UP)
        selribbon -= 5
        selribbon += numRows * 5 if selribbon < 0
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        selribbon += 5
        selribbon -= numRows * 5 if selribbon >= numRows * 5
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::LEFT)
        selribbon -= 1
        selribbon += 5 if selribbon % 5 == 4
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::RIGHT)
        selribbon += 1
        selribbon -= 5 if selribbon % 5 == 0
        hasMovedCursor = true
        pbPlayCursorSE
      end
      next if !hasMovedCursor
      @ribbonOffset = (selribbon / 5).floor if selribbon < @ribbonOffset * 5
      @ribbonOffset = (selribbon / 5).floor - 1 if selribbon >= (@ribbonOffset + 2) * 5
      @ribbonOffset = 0 if @ribbonOffset < 0
      @ribbonOffset = numRows - 2 if @ribbonOffset > numRows - 2
      @sprites["ribbonsel"].index    = selribbon - (@ribbonOffset * 5)
      @sprites["ribbonpresel"].index = oldselribbon - (@ribbonOffset * 5)
      drawSelectedRibbon(@pokemon.ribbons[selribbon])
    end
    @sprites["ribbonsel"].visible = false
  end

  def pbMarking(pokemon)
    @sprites["markingbg"].visible      = true
    @sprites["markingoverlay"].visible = true
    @sprites["markingsel"].visible     = true
    base   = Color.new(248, 248, 248)
    shadow = Color.new(66, 66, 81)
    ret = pokemon.markings.clone
    markings = pokemon.markings.clone
    mark_variants = @markingbitmap.bitmap.height / MARK_HEIGHT
    index = 0
    redraw = true
    markrect = Rect.new(0, 0, MARK_WIDTH, MARK_HEIGHT)
    loop do
      # Redraw the markings and text
      if redraw
        @sprites["markingoverlay"].bitmap.clear
        (@markingbitmap.bitmap.width / MARK_WIDTH).times do |i|
          markrect.x = i * MARK_WIDTH
          markrect.y = [(markings[i] || 0), mark_variants - 1].min * MARK_HEIGHT
          @sprites["markingoverlay"].bitmap.blt(300 + (58 * (i % 3)), 154 + (50 * (i / 3)),
                                                @markingbitmap.bitmap, markrect)
        end
        textpos = [
          [_INTL("Mark {1}", pokemon.name), 366, 102, 2, base, shadow],
          [_INTL("OK"), 366, 254, 2, base, shadow],
          [_INTL("Cancel"), 366, 304, 2, base, shadow]
        ]
        pbDrawTextPositions(@sprites["markingoverlay"].bitmap, textpos)
        redraw = false
      end
      # Reposition the cursor
      @sprites["markingsel"].x = 284 + (58 * (index % 3))
      @sprites["markingsel"].y = 144 + (50 * (index / 3))
      case index
      when 6   # OK
        @sprites["markingsel"].x = 284
        @sprites["markingsel"].y = 244
        @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height / 2
      when 7   # Cancel
        @sprites["markingsel"].x = 284
        @sprites["markingsel"].y = 294
        @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height / 2
      else
        @sprites["markingsel"].src_rect.y = 0
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        case index
        when 6   # OK
          ret = markings
          break
        when 7   # Cancel
          break
        else
          markings[index] = ((markings[index] || 0) + 1) % mark_variants
          redraw = true
        end
      elsif Input.trigger?(Input::ACTION)
        if index < 6 && markings[index] > 0
          pbPlayDecisionSE
          markings[index] = 0
          redraw = true
        end
      elsif Input.trigger?(Input::UP)
        if index == 7
          index = 6
        elsif index == 6
          index = 4
        elsif index < 3
          index = 7
        else
          index -= 3
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        if index == 7
          index = 1
        elsif index == 6
          index = 7
        elsif index >= 3
          index = 6
        else
          index += 3
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::LEFT)
        if index < 6
          index -= 1
          index += 3 if index % 3 == 2
          pbPlayCursorSE
        end
      elsif Input.trigger?(Input::RIGHT)
        if index < 6
          index += 1
          index -= 3 if index % 3 == 0
          pbPlayCursorSE
        end
      end
    end
    @sprites["markingbg"].visible      = false
    @sprites["markingoverlay"].visible = false
    @sprites["markingsel"].visible     = false
    if pokemon.markings != ret
      pokemon.markings = ret
      return true
    end
    return false
  end

  def pbOptions
    dorefresh = false
    commands = []
    cmdGiveItem = -1
    cmdTakeItem = -1
    cmdPokedex  = -1
    cmdWithin   = -1
    cmdMark     = -1
    if !@pokemon.egg?
      commands[cmdGiveItem = commands.length] = _INTL("Give item")
      commands[cmdTakeItem = commands.length] = _INTL("Take item") if @pokemon.hasItem?
      commands[cmdPokedex = commands.length]  = _INTL("View Pokédex") if $player.has_pokedex
      if @page == 4
        commands[cmdWithin = commands.length] = @withinsym ? _INTL("Show Text") : _INTL("Show Symbols")
      end
    end
    commands[cmdMark = commands.length]       = _INTL("Mark")
    commands[commands.length]                 = _INTL("Cancel")
    command = pbShowCommands(commands)
    if cmdGiveItem >= 0 && command == cmdGiveItem
      item = nil
      pbFadeOutIn {
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $bag)
        item = screen.pbChooseItemScreen(proc { |itm| GameData::Item.get(itm).can_hold? })
      }
      if item
        dorefresh = pbGiveItemToPokemon(item, @pokemon, self, @partyindex)
      end
    elsif cmdTakeItem >= 0 && command == cmdTakeItem
      dorefresh = pbTakeItemFromPokemon(@pokemon, self)
    elsif cmdPokedex >= 0 && command == cmdPokedex
      $player.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn {
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbStartSceneSingle(@pokemon.species)
      }
      dorefresh = true
    elsif cmdWithin >= 0 && command == cmdWithin
      @withinsym = !@withinsym
      dorefresh = true
    elsif cmdMark >= 0 && command == cmdMark
      dorefresh = pbMarking(@pokemon)
    end
    return dorefresh
  end

  def pbChooseMoveToForget(move_to_learn)
    new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
    selmove = 0
    maxmove = (new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
    @sprites["movesel"].pokemon = @pokemon
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        selmove = Pokemon::MAX_MOVES
        pbPlayCloseMenuSE if new_move
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::UP)
        selmove -= 1
        selmove = maxmove if selmove < 0
        if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
          selmove = @pokemon.numMoves - 1
        end
        @sprites["movesel"].index = selmove
        selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
        drawSelectedMove(new_move, selected_move)
      elsif Input.trigger?(Input::DOWN)
        selmove += 1
        selmove = 0 if selmove > maxmove
        if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
          selmove = (new_move) ? maxmove : 0
        end
        @sprites["movesel"].index = selmove
        selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
        drawSelectedMove(new_move, selected_move)
      end
    end
    return (selmove == Pokemon::MAX_MOVES) ? -1 : selmove
  end

  def pbScene
    @pokemon.play_cry
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        @pokemon.play_cry
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @page == 5
          pbPlayDecisionSE
          pbMoveSelection
          dorefresh = true
        elsif @page == 6
          pbPlayDecisionSE
          pbRibbonSelection
          dorefresh = true
        elsif !@inbattle
          pbPlayDecisionSE
          dorefresh = pbOptions
        end
      elsif Input.trigger?(Input::UP) && @partyindex > 0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex != oldindex
          pbChangePokemon
          @ribbonOffset = 0
          @sprites["partyrotation"].index = @partyindex
          @sprites["partyrotation"].moving_up = false
          @sprites["partyrotation"].update
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && @partyindex < @party.length - 1
        oldindex = @partyindex
        pbGoToNext
        if @partyindex != oldindex
          pbChangePokemon
          @ribbonOffset = 0
          @sprites["partyrotation"].index = @partyindex
          @sprites["partyrotation"].moving_up = true
          @sprites["partyrotation"].update
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        @page = 1 if @page < 1
        if !@pokemon.egg?
          @page = 6 if @page > 6
        else
          @page = 2 if @page > 2
        end
        if @page != oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        @page = 1 if @page < 1
        if !@pokemon.egg?
          @page = 6 if @page > 6
        else
          @page = 2 if @page > 2
        end
        if @page != oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSummaryScreen
  def initialize(scene, inbattle = false, showpartyrotation = false)
    @scene = scene
    @inbattle = inbattle
    @showpartyrotation = showpartyrotation
  end

  def pbStartScreen(party, partyindex)
    @scene.pbStartScene(party, partyindex, @inbattle, @showpartyrotation)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbStartForgetScreen(party, partyindex, move_to_learn)
    ret = -1
    @scene.pbStartForgetScene(party, partyindex, move_to_learn)
    loop do
      ret = @scene.pbChooseMoveToForget(move_to_learn)
      break if ret < 0 || !move_to_learn
      break if $DEBUG || !party[partyindex].moves[ret].hidden_move?
      pbMessage(_INTL("HM moves can't be forgotten now.")) { @scene.pbUpdate }
    end
    @scene.pbEndScene
    return ret
  end

  def pbStartChooseMoveScreen(party, partyindex, message)
    ret = -1
    @scene.pbStartForgetScene(party, partyindex, nil)
    pbMessage(message) { @scene.pbUpdate }
    loop do
      ret = @scene.pbChooseMoveToForget(nil)
      break if ret >= 0
      pbMessage(_INTL("You must choose a move!")) { @scene.pbUpdate }
    end
    @scene.pbEndScene
    return ret
  end
end

#===============================================================================
#
#===============================================================================
def pbChooseMove(pokemon, variableNumber, nameVarNumber)
  return if !pokemon
  ret = -1
  pbFadeOutIn {
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene)
    ret = screen.pbStartForgetScreen([pokemon], 0, nil)
  }
  $game_variables[variableNumber] = ret
  if ret >= 0
    $game_variables[nameVarNumber] = pokemon.moves[ret].name
  else
    $game_variables[nameVarNumber] = ""
  end
  $game_map.need_refresh = true if $game_map
end
