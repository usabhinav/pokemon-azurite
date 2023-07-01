 #===============================================================================
class PokemonPokedexInfo_Scene
  def pbStartScene(dexlist, index, region)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @dexlist = dexlist
    @index   = index
    @region  = region
    @page = 1
    @show_battled_count = false
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @sprites = {}
    # CHANGED: Defines the Scrolling Background, as well as the overlay on top of it    
    @sprites["background"] = ScrollingSprite.new(@viewport)
    @sprites["background"].speed = 1
    @sprites["infoverlay"] = IconSprite.new(0,0,@viewport)
    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::CENTER)
    # CHANGED: Changes the position of the Pokémon in the Entry Page
    @sprites["infosprite"].x = 98
    @sprites["infosprite"].y = 112
    @mapdata = pbLoadTownMapData
    mappos = $game_map.metadata&.town_map_position
    if @region < 0                                 # Use player's current region
      @region = (mappos) ? mappos[0] : 0                      # Region 0 default
    end
    @sprites["areamap"] = IconSprite.new(0, 0, @viewport)
    @sprites["areamap"].setBitmap("Graphics/Pictures/#{@mapdata[@region][1]}")
    @sprites["areamap"].x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
    # CHANGED: Y offset
    @sprites["areamap"].y += (Graphics.height + 16 - @sprites["areamap"].bitmap.height) / 2
    Settings::REGION_MAP_EXTRAS.each do |hidden|
      next if hidden[0] != @region || hidden[1] <= 0 || !$game_switches[hidden[1]]
      pbDrawImagePositions(
        @sprites["areamap"].bitmap,
        [["Graphics/Pictures/#{hidden[4]}",
          hidden[2] * PokemonRegionMap_Scene::SQUARE_WIDTH,
          hidden[3] * PokemonRegionMap_Scene::SQUARE_HEIGHT]]
      )
    end
    @sprites["areahighlight"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["areaoverlay"] = IconSprite.new(0, 0, @viewport)
    @sprites["areaoverlay"].setBitmap("Graphics/Pictures/Pokedex/overlay_area")
    @sprites["formfront"] = PokemonSprite.new(@viewport)
    @sprites["formfront"].setOffset(PictureOrigin::CENTER)
    # CHANGED: Changes the X and Y position of the front sprite of the Pokémon in the Forms Page
    @sprites["formfront"].x = 382
    @sprites["formfront"].y = 240
    @sprites["formback"] = PokemonSprite.new(@viewport)
    @sprites["formback"].setOffset(PictureOrigin::CENTER)
    # CHANGED: Changes the X position of the back sprite of the Pokémon in the Forms Page
    @sprites["formback"].x = 124   # y is set below as it depends on metrics
    @sprites["formicon"] = PokemonSpeciesIconSprite.new(nil, @viewport)
    @sprites["formicon"].setOffset(PictureOrigin::CENTER)
    # CHANGED: Changes the X and Y position of the icon sprite of the Pokémon in the Forms Page
    @sprites["formicon"].x = 64
    @sprites["formicon"].y = 112
    # CHANGED: Changes the Y position of the Up Arrow sprite of the Pokémon in the Forms Page
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    @sprites["uparrow"].x = 242
    @sprites["uparrow"].y = 40
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    # CHANGED: Changes the Y position of the Down Arrow sprite of the Pokémon in the Forms Page
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = 242
    @sprites["downarrow"].y = 128
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFontBW(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    @available = pbGetAvailableForms
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartSceneBrief(species)  # For standalone access, shows first page only
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    dexnum = 0
    dexnumshift = false
    if $player.pokedex.unlocked?(-1)   # National Dex is unlocked
      species_data = GameData::Species.try_get(species)
      if species_data
        nationalDexList = [:NONE]
        GameData::Species.each_species { |s| nationalDexList.push(s.species) }
        dexnum = nationalDexList.index(species_data.species) || 0
        dexnumshift = true if dexnum > 0 && Settings::DEXES_WITH_OFFSETS.include?(-1)
      end
    else
      ($player.pokedex.dexes_count - 1).times do |i|   # Regional Dexes
        next if !$player.pokedex.unlocked?(i)
        num = pbGetRegionalNumber(i, species)
        next if num <= 0
        dexnum = num
        dexnumshift = true if Settings::DEXES_WITH_OFFSETS.include?(i)
        break
      end
    end
    @dexlist = [[species, "", 0, 0, dexnum, dexnumshift]]
    @index   = 0
    @page = 1
    @brief = true
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @sprites = {}
    # CHANGED: Defines the Scrolling Background of the Entry Scene when capturing a Wild Pokémon, as well as the overlay on top of it
    # and the capture bar
    @sprites["background"] = ScrollingSprite.new(@viewport)
    @sprites["background"].speed = 1
    @sprites["infoverlay"] = IconSprite.new(0,0,@viewport)
    @sprites["capturebar"] = IconSprite.new(0,0,@viewport)

    @sprites["infosprite"] = PokemonSprite.new(@viewport)
    @sprites["infosprite"].setOffset(PictureOrigin::CENTER)
    # CHANGED: Changes the X position of the front sprite of the Pokémon in the Entry Scene when capturing a Wild Pokémon
    @sprites["infosprite"].x = 98
    @sprites["infosprite"].y = 136
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFontBW(@sprites["overlay"].bitmap)
    pbUpdateDummyPokemon
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  alias bw_style_pbUpdateDummyPokemon pbUpdateDummyPokemon unless method_defined?(:bw_style_pbUpdateDummyPokemon)
  def pbUpdateDummyPokemon
    bw_style_pbUpdateDummyPokemon
    metrics_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
    if @sprites["formback"]
      # CHANGED: This one was a bit hard to find, but it changes the Y position of the backsprite of the Pokémon in the Forms Page
      @sprites["formback"].y = 226
      @sprites["formback"].y += metrics_data.back_sprite[1] * 2
    end
  end

  def drawPageInfo
    # Sets the Scrolling Background of the Entry Page, as well as the overlay on top of it
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_info"))
    @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/info_overlay"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(82, 82, 90)
    shadow = Color.new(165, 165, 173)
    imagepos = []
    if @brief
      # Sets the Scrolling Background of the Entry Scene when capturing a wild Pokémon, as well as the overlay on top of it
      @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_capture"))
      @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/capture_overlay"))
      @sprites["capturebar"].setBitmap(_INTL("Graphics/Pictures/Pokedex/overlay_info"))
    end
    species_data = GameData::Species.get_species_form(@species, @form)
    # Write various bits of text
    indexText = "???"
    if @dexlist[@index][4] > 0
      indexNumber = @dexlist[@index][4]
      indexNumber -= 1 if @dexlist[@index][5]
      indexText = sprintf("%03d", indexNumber)
    end
    # This bit of the code woudn't have been possible without the help of NettoHikari.
    # He helped me to set the Sprites and Texts differently, depending on if the 
    # Pokédex Entry Scene is playing, when the payer is capturing a Wild Pokémon, 
    # or if the player is seeing the "normal" Dex Entry page on the Pokédex.
    #
    # Basically, this next lines changes the position of various text 
    # (height, weight, the Name's Species, etc), depending on if the 
    # Pokédex Entry Scene is playing, when the player is capturing a Wild Pokémon, 
    # or if the player is seeing the "normal" Dex Entry page on the Pokédex.
    if @brief
      textpos = [
        [_INTL("Pokémon Registration Complete"), 82, -2, 0, Color.new(255, 255, 255), Color.new(165, 165, 173)],
        [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
            272, 54, 0, Color.new(82, 82, 90), Color.new(165, 165, 173)],
        [_INTL("Height"), 288, 170, 0, base, shadow],
        [_INTL("Weight"), 288, 200, 0, base, shadow]
      ]
    else
      textpos = [
        [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
            272, 16, 0, Color.new(82, 82, 90), Color.new(165, 165, 173)],
        [_INTL("Height"), 288, 132, 0, base, shadow],
        [_INTL("Weight"), 288, 162, 0, base, shadow]
      ]
    end
    if $player.owned?(@species)
      # Write the category. Changed
      if @brief
        textpos.push([_INTL("{1} Pokémon", species_data.category), 376, 90, 2, base, shadow])
      else
        textpos.push([_INTL("{1} Pokémon", species_data.category), 376, 52, 2, base, shadow])
      end
      # Write the height and weight. Changed
      height = species_data.height
      weight = species_data.weight
      if System.user_language[3..4] == "US"   # If the user is in the United States
        inches = (height / 0.254).round
        pounds = (weight / 0.45359).round
        if @brief
          textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 490, 170, 1, base, shadow])
          textpos.push([_ISPRINTF("{1:4.1f} lbs.", pounds / 10.0), 490, 200, 1, base, shadow])
        else
          textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 490, 132, 1, base, shadow])
          textpos.push([_ISPRINTF("{1:4.1f} lbs.", pounds / 10.0), 490, 162, 1, base, shadow])
        end
      else
	  	  if @brief
          textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 490, 170, 1, base, shadow])
          textpos.push([_ISPRINTF("{1:.1f} kg", weight / 10.0), 490, 200, 1, base, shadow])
			  else
		      textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 490, 132, 1, base, shadow])
          textpos.push([_ISPRINTF("{1:.1f} kg", weight / 10.0), 490, 162, 1, base, shadow])
			  end
      end
      # Draw the Pokédex entry text. Changed
	    base   = Color.new(255,255,255)
      shadow = Color.new(165,165,173)
      drawTextEx(overlay, 38, @brief ? 250 : 212, Graphics.width - (40 * 2), 4,   # overlay, x, y, width, num lines
                species_data.pokedex_entry, base, shadow)
      # Draw the footprint. Changed
      footprintfile = GameData::Species.footprint_filename(@species, @form)
      if footprintfile
        footprint = RPG::Cache.load_bitmap("",footprintfile)
        overlay.blt(224, @brief ? 150 : 112, footprint, footprint.rect)
        footprint.dispose
      end
      # Show the owned icon. Changed
      imagepos.push(["Graphics/Pictures/Pokedex/icon_own", 210, @brief ? 57 : 19])
      # Draw the type icon(s). Changed
      species_data.types.each_with_index do |type, i|
        type_number = GameData::Type.get(type).icon_position
        type_rect = Rect.new(0, type_number * 32, 96, 32)
        overlay.blt(286 + (80 * i), @brief ? 132 : 94, @typebitmap.bitmap, type_rect)
      end
    else
      # This bit of the code below is simply the Entry Page when you have seen the Pokémon, but didn't capture it yet.
      # Write the category. Changed
      textpos.push([_INTL("????? Pokémon"), 274, 50, 0, base, shadow])
      # Write the height and weight. Changed
      if System.user_language[3..4] == "US"   # If the user is in the United States
        textpos.push([_INTL("???'??\""), 490, 136, 1, base, shadow])
        textpos.push([_INTL("????.? lbs."), 488, 170, 1, base, shadow])
      else
        textpos.push([_INTL("????.? m"), 488, 132, 1, base, shadow])
        textpos.push([_INTL("????.? kg"), 488, 162, 1, base, shadow])
      end
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
  end

  def drawPageArea
    # CHANGED: Sets the Scrolling Background of the Area Page, as well as the overlay on top of it
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_area"))
    @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/map_overlay"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    @sprites["areahighlight"].bitmap.clear
    # Get all points to be shown as places where @species can be encountered
    points = pbGetEncounterPoints
    # Draw coloured squares on each point of the Town Map with a nest
    pointcolor   = Color.new(0, 248, 248)
    pointcolorhl = Color.new(192, 248, 248)
    town_map_width = 1 + PokemonRegionMap_Scene::RIGHT - PokemonRegionMap_Scene::LEFT
    sqwidth = PokemonRegionMap_Scene::SQUARE_WIDTH
    sqheight = PokemonRegionMap_Scene::SQUARE_HEIGHT
    points.length.times do |j|
      next if !points[j]
      x = (j % town_map_width) * sqwidth
      x += (Graphics.width - @sprites["areamap"].bitmap.width) / 2
      y = (j / town_map_width) * sqheight
      # CHANGED: Y offset
      y += (Graphics.height + 16 - @sprites["areamap"].bitmap.height) / 2
      @sprites["areahighlight"].bitmap.fill_rect(x, y, sqwidth, sqheight, pointcolor)
      if j - town_map_width < 0 || !points[j - town_map_width]
        @sprites["areahighlight"].bitmap.fill_rect(x, y - 2, sqwidth, 2, pointcolorhl)
      end
      if j + town_map_width >= points.length || !points[j + town_map_width]
        @sprites["areahighlight"].bitmap.fill_rect(x, y + sqheight, sqwidth, 2, pointcolorhl)
      end
      if j % town_map_width == 0 || !points[j - 1]
        @sprites["areahighlight"].bitmap.fill_rect(x - 2, y, 2, sqheight, pointcolorhl)
      end
      if (j + 1) % town_map_width == 0 || !points[j + 1]
        @sprites["areahighlight"].bitmap.fill_rect(x + sqwidth, y, 2, sqheight, pointcolorhl)
      end
    end
    # Set the text
    # Changes the color of the text, to the one used in BW
    base   = Color.new(255,255,255)
    shadow = Color.new(165,165,173)
    textpos = []
    if points.length == 0
      pbDrawImagePositions(
        overlay,
        [[sprintf("Graphics/Pictures/Pokedex/overlay_areanone"), 108, 148]] # CHANGED: Y value
      )
      textpos.push([_INTL("Area unknown"), Graphics.width / 2, 146, 2, base, shadow]) # CHANGED: Y value
    end
    # CHANGED: Minor changes to the color of the text, to mimic the one used in BW
    textpos.push([pbGetMessage(MessageTypes::RegionNames, @region), 58, 0, 0, Color.new(255,255,255), Color.new(115,115,115)])
    # CHANGED: Minor changes to the color of the text, to mimic the one used in BW
    textpos.push([_INTL("{1}'s area", GameData::Species.get(@species).name),
                  Graphics.width / 1.4, 0, 2, Color.new(255,255,255), Color.new(115,115,115)])
    pbDrawTextPositions(overlay, textpos)
  end

  def drawPageForms
    # CHANGED: Sets the Scrolling Background of the Forms Page, as well as the overlay on top of it
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/forms_overlay"))
    overlay = @sprites["overlay"].bitmap
    # CHANGED: Changes the color of the text, to the one used in BW
    base   = Color.new(255,255,255)
    shadow = Color.new(165,165,173)
    # Write species and form name
    formname = ""
    for i in @available
      if i[1]==@gender && i[2]==@form
        formname = i[0]; break
      end
    end
    # CHANGED: Change text attributes
    textpos = [
	    [_INTL("Forms"),58,0,0,Color.new(255,255,255),Color.new(115,115,115)],
      [GameData::Species.get(@species).name,Graphics.width/2,Graphics.height-316,2,base,shadow],
      [formname,Graphics.width/2,Graphics.height-280,2,base,shadow],
    ]
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
  end
end
