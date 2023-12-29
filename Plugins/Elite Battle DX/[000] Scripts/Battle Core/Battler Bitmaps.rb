#===============================================================================
#  Loads an animated BitmapWrapper for Pokemon
#===============================================================================
def pbLoadPokemonBitmap(pokemon, back = false, scale = EliteBattle::FRONT_SPRITE_SCALE, speed = 2)
  return pbLoadPokemonBitmapSpecies(pokemon, pokemon.species, back, scale, speed)
end
#===============================================================================
#  Loads an animated BitmapWrapper for Pokemon species
#===============================================================================
def pbLoadPokemonBitmapSpecies(pokemon, species, back = false, scale = EliteBattle::FRONT_SPRITE_SCALE, speed = 2)
  ret = nil
  pokemon = pokemon.pokemon if pokemon.respond_to?(:pokemon)
  species = pokemon.species if species.nil? && pokemon.respond_to?(:species)
  # sauce
  species = :BIDOOF if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
  # return question marks if no species provided
  return BitmapEBDX.new("Graphics/EBDX/Battlers/000", scale) if species.nil?
  # applies scale
  scale = back ? EliteBattle::BACK_SPRITE_SCALE : EliteBattle::FRONT_SPRITE_SCALE
  # gets additional scale (if applicable)
  species_data = EliteBattle.get_data(species, :Species, nil, (pokemon.form rescue 0))
  s = !species_data.nil? ? species_data[back ? :BACKSCALE : :SCALE] : nil
  scale = s if !s.nil? && s.is_a?(Numeric)
  # get more metrics
  s = !species_data.nil? ? species_data[:SPRITESPEED] : nil
  speed = s if !s.nil? && s.is_a?(Numeric)
  if pokemon.egg?
    bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/%s", species) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/000")
    end
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    shiny_variant = pokemon.shiny_variant
    shiny_variant = Pokemon::SHINY if (!pokemon.superVariant.nil? && pokemon.superShiny? && pokemon.superVariant)
    params = [species, back, pokemon.female?, shiny_variant, (pokemon.form rescue 0), (pokemon.shadowPokemon? rescue false), (pokemon.dynamax rescue false), (pokemon.dynamax && pokemon.gfactor rescue false)]
    bitmapFileName = pbCheckPokemonBitmapFiles(params)
  end
  if bitmapFileName.nil?
    bitmapFileName = "Graphics/EBDX/Battlers/000"
    EliteBattle.log.warn(missingPokeSpriteError(pokemon, back))
  end
  animatedBitmap = BitmapEBDX.new(bitmapFileName, scale, speed) if bitmapFileName
  ret = animatedBitmap if bitmapFileName
  # Full compatibility with the alterBitmap methods is maintained
  # but unless the alterBitmap method gets rewritten and sprite animations get
  # hardcoded in the system, the bitmap alterations will not function properly
  # as they will not account for the sprite animation itself

  # alterBitmap methods for static sprites will work just fine
  alterBitmap = (MultipleForms.getFunction(species, "alterBitmap") rescue nil) if !pokemon.egg? && animatedBitmap && animatedBitmap.totalFrames == 1 # remove this totalFrames clause to allow for dynamic sprites too
  if bitmapFileName && alterBitmap
    animatedBitmap.prepare_strip
    for i in 0...animatedBitmap.totalFrames
      alterBitmap.call(pokemon, animatedBitmap.alter_bitmap(i))
    end
    animatedBitmap.compile_strip
    ret = animatedBitmap
  end
  # adjusts for custom animation loops
  data = !species_data.nil? ? species_data[:FRAMEANIMATION] : nil
  unless data.nil?
    ret.compile_loop(data)
  end
  # applies super shiny hue
  ret.hue_change(pokemon.superHue) if pokemon.superHue && !ret.changedHue?
  # refreshes bitmap
  ret.deanimate if ret.respond_to?(:deanimate)
  return ret
end
#===============================================================================
#  Gets battler sprite file name for Pokemon (extracted from pbLoadPokemonBitmapSpecies)
#===============================================================================
def pbPokemonBitmapFileName(pokemon, species, back)
  pokemon = pokemon.pokemon if pokemon.respond_to?(:pokemon)
  species = pokemon.species if species.nil? && pokemon.respond_to?(:species)
  # sauce
  species = :BIDOOF if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
  if pokemon.egg?
    bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/%s", species) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/000")
    end
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    shiny_variant = pokemon.shiny_variant
    shiny_variant = Pokemon::SHINY if (!pokemon.superVariant.nil? && pokemon.superShiny? && pokemon.superVariant)
    params = [species, back, pokemon.female?, shiny_variant, (pokemon.form rescue 0), (pokemon.shadowPokemon? rescue false), (pokemon.dynamax rescue false), (pokemon.dynamax && pokemon.gfactor rescue false)]
    bitmapFileName = pbCheckPokemonBitmapFiles(params)
  end
  if bitmapFileName.nil?
    bitmapFileName = "Graphics/EBDX/Battlers/000"
    EliteBattle.log.warn(missingPokeSpriteError(pokemon, back))
  end
  return bitmapFileName
end
#===============================================================================
#  Pokemon icon aditions
#===============================================================================
def pbPokemonIconFile(pokemon)
  bitmapFileName = nil
  species = pokemon.species
  # sauce
  species = :BIDOOF if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
  bitmapFileName = pbCheckPokemonIconFiles([species, (pokemon.female?),
     pokemon.shiny_variant,(pokemon.form rescue 0),(pokemon.shadowPokemon? rescue false)],
     pokemon.egg?)
  return bitmapFileName
end
#===============================================================================
#  Loads animated BitmapWrapper for species
#===============================================================================
def pbLoadSpeciesBitmap(species, female=false, form=0, shiny_variant=Pokemon::REGULAR, shadow=false, back=false, egg=false, scale=EliteBattle::FRONT_SPRITE_SCALE)
  ret = nil
  species = :BIDOOF if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
  # return question marks if no species provided
  return BitmapEBDX.new("Graphics/EBDX/Battlers/000", scale) if species.nil?
  # applies scale
  scale = back ? EliteBattle::BACK_SPRITE_SCALE : EliteBattle::FRONT_SPRITE_SCALE
  # gets additional scale (if applicable)
  s = EliteBattle.get_data(species, :Species, (back ? :BACKSCALE : :SCALE), (form rescue 0))
  scale = s if !s.nil? && s.is_a?(Numeric)
  # check sprite
  if egg
    bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/%s", species) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/000")
    end
    bitmapFileName = pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = pbCheckPokemonBitmapFiles([species, back, female, shiny_variant, form, shadow, false, false])
  end
  if bitmapFileName
    ret = BitmapEBDX.new(bitmapFileName, scale)
  end
  # adjusts for custom animation loops
  data = EliteBattle.get_data(species, :Species, :FRAMEANIMATION, form)
  unless data.nil?
    ret.compile_loop(data)
  end
  # refreshes bitmap
  ret.deanimate if ret.respond_to?(:deanimate)
  return ret
end
#===============================================================================
#  Returns error message upon missing sprites
#===============================================================================
def missingPokeSpriteError(pokemon, back)
  error_b = back ? "Back" : "Front"
  error_b += "Shiny" if pokemon.shiny?
  error_b += "Albino" if pokemon.albino?
  error_b += "Glossy" if pokemon.glossy?
  error_b += "/Female/" if pokemon.female?
  error_b += " shadow" if pokemon.shadowPokemon?
  error_b += " form #{pokemon.form} " if pokemon.form > 0
  return "Looks like you're missing the #{error_b} sprite for #{GameData::Species.get(pokemon.species).real_name}!"
end
#===============================================================================
#  New methods of handing Pokemon sprite name references
#===============================================================================
def pbCheckPokemonBitmapFiles(params)
  species = params[0]; back = params[1]; factors = []
  factors.push([5, params[5], false]) if params[5] && params[5] != false # shadow
  factors.push([2, params[2], false]) if params[2] && params[2] != false # gender
  factors.push([3, params[3], Pokemon::REGULAR]) if params[3] && params[3] != Pokemon::REGULAR # shiny
  factors.push([6, params[6], false]) if params[6] && params[6] != false # dynamaxed
  factors.push([7, params[7], false]) if params[7] && params[7] != false # gigantimaxed
  factors.push([4, params[4].to_s, ""]) if params[4] && params[4].to_s != "" && params[4].to_s != "0" # form
  tshadow = false; tgender = false; tshiny_variant = nil; tform = ""
  for i in 0...(2**factors.length)
    for j in 0...factors.length
      case factors[j][0]
      when 2   # gender
        tgender = ((i/(2**j))%2 == 0) ? factors[j][1] : factors[j][2]
      when 3   # shiny
        tshiny_variant = ((i/(2**j))%2 == 0) ? factors[j][1] : factors[j][2]
      when 4   # form
        tform = ((i/(2**j))%2 == 0) ? factors[j][1] : factors[j][2]
      when 5   # shadow
        tshadow = ((i/(2**j))%2 == 0) ? factors[j][1] : factors[j][2]
      when 6   # dynamaxed
        tdyna = ((i/(2**j))%2 == 0) ? factors[j][1] : factors[j][2]
      when 7   # gigantimaxed
        tgigant = ((i/(2**j))%2 == 0) ? factors[j][1] : factors[j][2]
      end
    end
    folder = "Graphics/EBDX/Battlers/"
    if tshiny_variant && tshiny_variant != Pokemon::REGULAR && back
      if tshiny_variant == Pokemon::SHINY
        folder += "BackShiny"
      elsif tshiny_variant == Pokemon::ALBINO
        folder += "BackAlbino"
      elsif tshiny_variant == Pokemon::GLOSSY
        folder += "BackGlossy"
      end
    elsif tshiny_variant && tshiny_variant != Pokemon::REGULAR
      if tshiny_variant == Pokemon::SHINY
        folder += "FrontShiny"
      elsif tshiny_variant == Pokemon::ALBINO
        folder += "FrontAlbino"
      elsif tshiny_variant == Pokemon::GLOSSY
        folder += "FrontGlossy"
      end
    elsif back
      folder += "Back"
    else
      folder += "Front"
    end
    dirs = []; dirs.push("/Gigantamax") if tgigant; dirs.push("/Dynamax") if tdyna && !tgigant; dirs.push("/Female") if tgender; dirs.push("")
    for dir in dirs
      bitmapFileName = sprintf("#{folder}#{dir}/%s%s%s", species, (tform != "" ? "_" + tform : ""), tshadow ? "_shadow" : "") rescue nil
      ret = pbResolveBitmap(bitmapFileName)
      return ret if ret
    end
  end
  return nil
end
#===============================================================================
#  Returns full path for sprite
#===============================================================================
def pbPokemonBitmapFile(species, shiny_variant, back=false)
  folder = "Graphics/EBDX/Battlers/"
  if shiny_variant && shiny_variant != Pokemon::REGULAR && back
    if shiny_variant == Pokemon::SHINY
      folder += "BackShiny/"
    elsif shiny_variant == Pokemon::ALBINO
      folder += "BackAlbino/"
    elsif shiny_variant == Pokemon::GLOSSY
      folder += "BackGlossy/"
    end
  elsif shiny_variant && shiny_variant != Pokemon::REGULAR
    if shiny_variant == Pokemon::SHINY
      folder += "FrontShiny/"
    elsif shiny_variant == Pokemon::ALBINO
      folder += "FrontAlbino/"
    elsif shiny_variant == Pokemon::GLOSSY
      folder += "FrontGlossy/"
    end
  elsif back
    folder += "Back/"
  else
    folder += "Front/"
  end
  name = sprintf("#{folder}%s", species) rescue nil
  return pbResolveBitmap(name)
end
#===============================================================================
#  Game data overrides
#===============================================================================
module GameData
  #-----------------------------------------------------------------------------
  #  Species class (bitmaps)
  #-----------------------------------------------------------------------------
  class Species
    #---------------------------------------------------------------------------
    #  get bitmap from species
    #---------------------------------------------------------------------------
    def self.sprite_bitmap(species, form = 0, gender = 0, shiny_variant = Pokemon::REGULAR, shadow = false, back = false, egg = false)
      return pbLoadSpeciesBitmap(species, (gender == 1), form, shiny_variant, shadow, back, egg)
    end
    #---------------------------------------------------------------------------
    #  get bitmap from Pokemon
    #---------------------------------------------------------------------------
    def self.sprite_bitmap_from_pokemon(pokemon, back = false, species = nil)
      return pbLoadPokemonBitmapSpecies(pokemon, species, back)
    end
    #---------------------------------------------------------------------------
    #  get icon from species
    #---------------------------------------------------------------------------
    def self.icon_bitmap(species, form = 0, gender = 0, shiny_variant = Pokemon::REGULAR, shadow = false)
      species = :BIDOOF if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
      filename = self.icon_filename(species, form, gender, shiny_variant, shadow)
      return (filename) ? AnimatedBitmap.new(filename).deanimate : nil
    end
    #---------------------------------------------------------------------------
    #  get icon from Pokemon
    #---------------------------------------------------------------------------
    def self.icon_bitmap_from_pokemon(pkmn)
      species = (GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?) ? :BIDOOF : pkmn.species
      return self.icon_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny_variant, pkmn.shadowPokemon?, pkmn.egg?)
    end
    #---------------------------------------------------------------------------
  end
  #-----------------------------------------------------------------------------
end
