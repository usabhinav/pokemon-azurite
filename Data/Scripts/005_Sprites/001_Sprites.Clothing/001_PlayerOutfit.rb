

# The core location of the outfit files
$APPAREL_DIR  = "Graphics/Characters/Apparel/"

# Current Animation Sheets: Walking, Running, Bicycle, Surfing, Diving
$LAYER_NAMES = ["Base", "Socks", "Legs", "Shoes", "Torso", "LowerFace", 
"UpperFace", "Hair", "Hat", "Eyes"]

# Defines which layers will definitely be changed when entering water, but does
# not change layers if the part defined as wearable in water
$SWIMSUIT_LAYERS = ["Legs", "Torso"]

# Defines a seperate set of layers for the mugshot
$LAYER_NAMES_MUGSHOT = ["Base", "Torso", "Hair", "Hat", "Eyes"]

#$LAYER_NAMES_POKEMON = ["PkmnBack", "PkmnFront"]

#===============================================================================
# A data structure that represents an arbitrary outfit layer and contains what
# bitmap file and which color is selected for it.
# - Baustein
#===============================================================================
class OutfitLayerState
    
  attr_accessor :selected_part
  attr_accessor :color
  attr_accessor :occupied_by
  
  def initialize
    @selected_part = 0
    @color         = "Default"
    @occupied_by   = ""
  end

end

#===============================================================================
# A data structure that contains all the information needed to describe the 
# state of a player outfit. Does not contain any graphical information, but does
# however contain functions to translate the current state into bitmaps.
# - Baustein
#===============================================================================
class OutfitState
  
  attr_reader   :dry_layer_states # The regular outfit
  attr_reader   :wet_layer_states # The swimming outfit
  attr_reader   :active_layer_states # Whichever outfit is active at the moment.
  attr_accessor :gender
  attr_accessor :surfing_species  # A string with the species you surf on + an s or a at the end for shiny/albino 
  
  def initialize(trainertype, animation)
    @dry_layer_states = Hash.new
    @wet_layer_states = Hash.new
    @gender = pbGetTrainerTypeGenderString(trainertype)
    @animation        = animation
    @changed          = true
    @surfing_species  = nil
    
    # Points to either regular or swim layer states
    @active_layer_states = @dry_layer_states
    
    for layer_name in $LAYER_NAMES
      @dry_layer_states[layer_name] = OutfitLayerState.new
    end
    
    for layer_name in $LAYER_NAMES
      @wet_layer_states[layer_name] = OutfitLayerState.new
    end
    
    # Base files are stored directly in the Base folder
    @dry_layer_states["Base"].color = nil
    @wet_layer_states["Base"].color = nil

  end
  
  def animation=(value)
    
    # Update which Pokemon is being surfed on
    if value == "Surfing"
      pkmn = pbGetSurfablePkmn
      
      @surfing_species = pkmn.species.to_s
      
      if pkmn.isShiny?
        @surfing_species += "s"
      elsif pkmn.isAlbino?
        @surfing_species += "a"
      end
      
    else
      @surfing_species = nil
    end
    
    # Toggle the active layer state if needed
    if value == "Swimming"
      @active_layer_states = @wet_layer_states
    else
      @active_layer_states = @dry_layer_states
    end
    
    @animation = value
      
  end
  
  def animation
    return @animation
  end
  
  # Sets the apparel for a layer state of the regular outfit
  def setDryLayerState(layer_name, apparel_id, color=nil)
    setLayerState(GameData::Apparel::DRYOUTFIT, layer_name, apparel_id, color)
  end
  
  # Sets the apparel for a layer state of the swimsuit
  def setWetLayerState(layer_name, apparel_id, color=nil)
    setLayerState(GameData::Apparel::WETOUTFIT, layer_name, apparel_id, color)
  end
  
  def getLayerState(outfitstate_constant, layer_name)
    if outfitstate_constant == GameData::Apparel::DRYOUTFIT
      layer_states = @dry_layer_states
    else
      layer_states = @wet_layer_states
    end
    
    return layer_states[layer_name]
  end
  
  def setLayerState(outfitstate_constant, layer_name, apparel_id, color=nil)
    
    if outfitstate_constant == APPCONST_OUTFITMODE::DRYSUIT
      layer_states = @dry_layer_states
    else
      layer_states = @wet_layer_states
    end
    
    layer_states[layer_name].selected_part = apparel_id
    
    # Mark a layer as unoccupied if a layer is left partless and as occupied otherwise
    if apparel_id == 0
      layer_states[layer_name].occupied_by = ""
    else
      #echo "Setting occupied layer as " + layer_name + "\n"
      layer_states[layer_name].occupied_by = layer_name
    end
        
    # De-select the apparel for every layer that interferes with the newly
    # selected part.
    if pbHasApparelConflicts?(layer_name)
      layer_conflicts = pbGetApparelConflicts(layer_name, apparel_id)
      for conflict in layer_conflicts
        layer_states[conflict].selected_part = 0
        layer_states[conflict].occupied_by = layer_name
          #echo "Setting occupied conflict layer as " + layer_name + "\n"
      end
    end
    
    if color!=nil
      # Apply the color to the layer state before it gets refreshed graphically
      if outfitstate_constant == GameData::Apparel::DRYOUTFIT
        setDryLayerColor(layer_name, color)
      else
        setWetLayerColor(layer_name, color)
      end
    end
  end
  
  # To keep any references and avoid future headaches, purposefully do not
  # use pbDeepCopy but instead copy everything over by hand. Trust me, this
  # is for the best.
  def setLayerStates(outfit_mode, new_layer_states)
    
    if(outfit_mode == APPCONST_OUTFITMODE::DRYSUIT)
      layer_states = @dry_layer_states
    else
      layer_states = @wet_layer_states
    end
    
    new_layer_states.each do |layer, new_state|
      layer_states[layer].selected_part = new_state.selected_part
      layer_states[layer].color = new_state.color
      layer_states[layer].occupied_by = new_state.occupied_by
    end
    
  end
    
  def getLayerStates(outfit_mode)
    if(outfit_mode == APPCONST_OUTFITMODE::DRYSUIT)
      return @dry_layer_states
    else
      return @wet_layer_states
    end
  end

  # Swaps the active layer state
  def toggleActiveLayerStates
    if @active_layer_states == @dry_layer_states
      @active_layer_states = @wet_layer_states
      echoln "WE WET AND RECKLESS NOW"
    else
      @active_layer_states = @dry_layer_states
      echoln "WE DRY NOW"
    end
  end
  
  # Sets the color for a layer state of the regular outfit
  def setDryLayerColor(layer_name, color)
    @dry_layer_states[layer_name].color = color
  end
    
  # Sets the color for a layer state of the swimsuit
  def setWetLayerColor(layer_name, color)
    @wet_layer_states[layer_name].color = color
  end
  
  # Finds out which layer the given layer is occupied by
  def occupiedBy(outfitstate_constant, layer_name)
    if outfitstate_constant == GameData::Apparel::DRYOUTFIT
      return @dry_layer_states[layer_name].occupied_by
    else
      return @wet_layer_states[layer_name].occupied_by
    end
  end
  
  # Translate the current state into an existing overworld bitmap
  def applyToOverworldBitmap(bitmap)
    bitmap.clear
    folder = $APPAREL_DIR + @animation
        
    # Determine which layers to apply
    layers_to_apply = []
    # Leave some layers out when swimming
    if @animation == "Swimming"
      # Push in layers from $LAYER_NAMES in the right order
      for layer_name in $LAYER_NAMES
        next if layer_name != "Base" &&
          layer_name != "LowerFace" &&
          layer_name != "UpperFace" &&
          layer_name != "Hair" &&
          layer_name != "Hat" &&
          layer_name != "Eyes"
        
        layers_to_apply.push(layer_name)
      end
      applyLayersToBitmap(bitmap, folder, layer_to_apply)
    # Add the Bike layer for biking
    elsif @animation == "Biking"
      # Copy $LAYER_NAMES
      layers_to_apply.push("Bike") # First add the bike, then the rest
      layers_to_apply = Marshal.load(Marshal.dump($LAYER_NAMES))
      
    # Add the Rod layer for fishing
    elsif @animation == "Fishing"
      # Copy $LAYER_NAMES
      layers_to_apply = Marshal.load(Marshal.dump($LAYER_NAMES))
      layers_to_apply.push("Rod") # Add the rod last
    # Don't add/remove any layers
    else
      layers_to_apply = $LAYER_NAMES
    end
    
    # Apply layers
    applyLayersToBitmap(bitmap, folder, layers_to_apply)
    
  end
  
  # Translate the current state into an existing trainer id bitmap
  def applyToIdBitmap(bitmap)
    bitmap.clear
    #folder = $APPAREL_DIR + @trainertype_name + "/" + "TrainerID"
    folder = $APPAREL_DIR + "TrainerID"
    applyLayersToBitmap(bitmap, folder, $LAYER_NAMES)
  end
  
  # Translate the current state into an existing mugshot bitmap
  def applyToMugshotBitmap(bitmap)
    bitmap.clear
    #folder = $APPAREL_DIR + @trainertype_name + "/" + "Mugshot"
    folder = $APPAREL_DIR + "Mugshot"
    applyLayersToBitmap(bitmap, folder, $LAYER_NAMES_MUGSHOT)
  end
  
  def createBlankBitmap(folder)
    # Fetch the Base bitmap for the current animation to get the dimensions
    base_bmp = BitmapCache.load_bitmap(folder + "/Base/Base1.png")
    # Return a newly created blank bitmap
    return BitmapWrapper.new(base_bmp.width, base_bmp.height)
  end
  
  def applyLayersToBitmap(outfit_bitmap, folder, layer_names)

    # If surfing, first apply the back layer for the pokemon
    if @animation == "Surfing"
      layer_bitmap_path = folder + "/PkmnBack/" + @surfing_species + ".png"
            
      #layer_bitmap_path = folder + "/Base/Base1.png"
      
      if !safeExists?(layer_bitmap_path)
        layer_bitmap_path = folder + "/Surfing/PkmnBack/default.png" 
      end
      
      applyLayerToBitmap(layer_bitmap_path, outfit_bitmap)
    end
    
    for layer_name in layer_names
      
      
      # Skip a layer if nothing is selected for it
      #echo layer_name + "\n"
      next if @active_layer_states[layer_name].selected_part == 0
      
      layer_folder = folder + "/" + layer_name
      
	  # Deprecated. TODO: Add expression type instead. No more gender distinctions.
      # Make a gender distinction for eyes
      #if layer_name == "Eyes"
      #  layer_folder += "/" + @gender
      #end
      
      # Add the color to the path as a folder if we have one
      if @active_layer_states[layer_name].color != nil
        layer_folder += "/" + @active_layer_states[layer_name].color
      end
      
      layer_bitmap_path = layer_folder + "/"  + layer_name + @active_layer_states[layer_name].selected_part.to_s
      
      # Check for this layer's apparel's variants and see if they need to be applied
      variants = pbGetApparelVariants(layer_name, @active_layer_states[layer_name].selected_part)
      if variants.length > 0
        for variant in variants
          # data[0] is always the layer name, data[1] the apparel ID
          data = variant.split("-")
          # If any selected apparel corresponds to the variant data, add that
          # data to the bitmap path
          if(@active_layer_states[data[0]].selected_part == data[1].to_i)
            layer_bitmap_path += "_" + data[0] + data[1] + ".png"
          end
        end
      # If there are no variants, no additions need to be made to the path
      else
        layer_bitmap_path += ".png"
      end
      
      #layer_bitmap = BitmapCache.load_bitmap(bitmap_path)
      #bitmap.blt(0,0, layer_bitmap, Rect.new(0,0,bitmap.width,bitmap.height))
      applyLayerToBitmap(layer_bitmap_path, outfit_bitmap)
    end
    
    # If surfing, lastly apply the front layer for the pokemon
    if @animation == "Surfing"
      layer_bitmap_path = folder + "/PkmnFront/" + @surfing_species + ".png"
      begin
        #layer_bitmap = BitmapCache.load_bitmap(bitmap_path)
        #bitmap.blt(0,0, layer_bitmap, Rect.new(0,0,bitmap.width,bitmap.height))
        applyLayerToBitmap(layer_bitmap_path, outfit_bitmap)
      end
    end
    #BitmapCache.debug
  end
  
  def applyLayerToBitmap(layer_bitmap_path, bitmap)
    
    #echo layer_bitmap_path + " " + bitmap.inspect + "\n\n"
    
    begin
      layer_bitmap = BitmapWrapper.new(layer_bitmap_path)
      #layer_bitmap = BitmapCache.load_bitmap(layer_bitmap_path)
        #width = [bitmap.width, layer_bitmap.width].max
        #height = [bitmap.height, layer_bitmap.height].max
        #bitmap.width = width
        #bitmap.height = height
        bitmap.blt(0,0, layer_bitmap, Rect.new(0,0,bitmap.width, bitmap.height))
    rescue
      echo "Error: Couldnt apply layer to bitmap: " + layer_bitmap_path + "\n"
    end
  end
  
end

#===============================================================================
# Wraps around an instance of OutfitState to notify other objects of changes 
# made to it. A neat side effect is that we can change the reference of the
# internal outfit state without having to change the wrapper's reference.
# - Baustein
#===============================================================================
class ObservableOutfitState

  include Observable
  
  #attr_accessor :outfitstate
  
  alias old_initialize initialize
  
  def initialize(outfitstate)
    old_initialize
    @outfitstate = outfitstate
  end
  
  def dry_layer_states
    return @outfitstate.dry_layer_states
  end
  
  def active_layer_states
    return @outfitstate.active_layer_states
  end
  
  def wet_layer_states
    return @outfitstate.wet_layer_states
  end
  
  def gender=(value)
    @outfitstate.gender = value
    notify
  end
  
  def gender
    return @outfitstate.gender
  end
  
  def occupiedBy(outfitstate_constant, layer_name)
    @outfitstate.occupiedBy(outfitstate_constant, layer_name)
  end
  
  def setSpriteCharacter(sprite_character)
    @sprite_character = sprite_character
  end
  
  def setDryLayerState(layer_name, apparel_id, color=nil)
    @outfitstate.setDryLayerState(layer_name, apparel_id, color)
    #DEBUG
=begin
    if $Trainer
      if $Trainer.outfitstate
        echo "Layer " + layer_name + " "
          
        occupied_by = $Trainer.outfitstate.occupiedBy(CSVCONST::DRYOUTFIT, layer_name)
          
        if occupied_by == ""
          echo "nil\n"
        else
          echo occupied_by + "\n"
        end
      end
    end
=end
    notify
  end
  
  def setWetLayerState(layer_name, apparel_id, color=nil)
    @outfitstate.setWetLayerState(layer_name, apparel_id, color)
    notify
  end
  
  def setDryLayerColor(layer_name, color)
    @outfitstate.setDryLayerColor(layer_name, color)
    notify
  end
  
  def setWetLayerColor(layer_name, color)
    @outfitstate.setWetLayerColor(layer_name, color)
    notify
  end
  
  def setLayerState(outfit_mode, layer, number_id, color=nil)
    @outfitstate.setLayerState(outfit_mode, layer, number_id, color)
    notify
  end
  
  def getLayerState(outfit_mode, layer)
    return @outfitstate.getLayerState(outfit_mode, layer)
  end
  
  def setLayerStates(outfit_mode, new_layer_states)
    @outfitstate.setLayerStates(outfit_mode, new_layer_states)
    notify
  end
  
  def getLayerStates(outfit_mode)
    return @outfitstate.getLayerStates(outfit_mode)
  end
  
  def animation
    return @outfitstate.animation
  end
  
  def animation=(value)

=begin
    if @sprite_character != nil
      @sprite_character.displayCharbitmapReference
    end
=end
    
    if value != @outfitstate.animation
      @outfitstate.animation = value
      notify(AnimationChangeEvent.new(value))
    end
    
=begin
    if @sprite_character != nil
      @sprite_character.displayCharbitmapReference
    end
=end
    
  end
  
  def applyToOverworldBitmap(bitmap)
    return @outfitstate.applyToOverworldBitmap(bitmap)
  end
  
  def applyToIdBitmap(bitmap)
    return @outfitstate.applyToIdBitmap(bitmap)
  end
  
  def applyToMugshotBitmap(bitmap)
    return @outfitstate.applyToMugshotBitmap(bitmap)
  end
  
  def getOutfitStateLayerPart(outfit_mode, layer)
    return @outfitstate.getOutfitStateLayerPart(outfit_mode, layer)
  end
  
  def setOutfitStateLayerPart(outfit_mode, layer, number_id, color=nil)
    @outfitstate.setOutfitStateLayerPart(outfit_mode, layer, number_id, color)
  end
  
  def toggleActiveLayerStates
    @outfitstate.toggleActiveLayerStates
  end

  # Saving and loading the outfit still works normally, but any information  
  # about observers will be lost (which makes sense as the observers don't exist anymore).
  def marshal_dump
    [@outfitstate]
  end
  def marshal_load array
    initialize(array[0])
  end
end


class Sprite_Player_Updater
  
  attr_accessor :outfitstate
  attr_accessor :sprite_character
  
  def initialize(outfitstate, sprite_character)
    @outfitstate  = outfitstate
    @sprite_character = sprite_character
    update(self)
  end
  
  def update(observer, event=nil)
    if event.is_a? AnimationChangeEvent
      @sprite_character.charbitmap.dispose
      @sprite_character.charbitmap.setBitmapFile("Graphics/Characters/Apparel/" + event.animation_name + "/Base/Base1.png")
      #echo "Animation Change Event: "
      @sprite_character.displayCharbitmapReference
    #else
      #echo "Not an Animation Change Event:\n"
    end
    @outfitstate.applyToOverworldBitmap(@sprite_character.charbitmap.bitmap)
  end
  
end


class AnimationChangeEvent
  
  attr_reader :animation_name
  
  def initialize(anim_name)
    @animation_name = anim_name
  end
  
end



class Sprite_Character
  
  attr_accessor :charbitmap
  
  alias old_initialize initialize
  def initialize(viewport, character = nil)
    old_initialize(viewport, character)

    if $Trainer
      if character == $game_player
        #@player_outfit_sprite_updater = Sprite_Player_Clother.new($Trainer.outfitstate, self)
        #$Trainer.outfitstate.attach(@player_outfit_sprite_updater)
        
        #@player_outfit_sprite_updater = Sprite_Player_Clother.new($Trainer.outfitstate, @charbitmap.bitmap)
        #$Trainer.outfitstate.attach(@player_outfit_sprite_updater)
        
=begin
        @player_outfit_sprite_updater = Sprite_Player_Updater.new($Trainer.outfitstate, self)
        $Trainer.outfitstate.attach(@player_outfit_sprite_updater)
        $Trainer.outfitstate.setSpriteCharacter(self)
=end
        
        # The proc way of doing this

        updateproc = Proc.new{|event|
          if event.is_a? AnimationChangeEvent
            @charbitmap.dispose
            @charbitmap.setBitmapFile("Graphics/Characters/Apparel/" + event.animation_name + "/Base/Base1.png")
            #@charbitmap = AnimatedBitmap.new("Graphics/Characters/Apparel/" + event.animation_name + "/Base/Base1.png")
            #echo "Animation Change Event: " + event.animation_name + "\n"
            #echo @charbitmap.bitmap.width.to_s + ", " + @charbitmap.bitmap.height.to_s
            #displayCharbitmapReference
            @cw = @charbitmap.width / 4
            @ch = @charbitmap.height / 4
          end
          #$Trainer.outfitstate..applyToOverworldBitmap(@sprite_character.charbitmap.bitmap)
          $Trainer.outfitstate.applyToOverworldBitmap(@charbitmap.bitmap)
        }
        @player_outfit_sprite_updater = Updater.new(updateproc)
        $Trainer.outfitstate.attach(@player_outfit_sprite_updater)
        $Trainer.outfitstate.setSpriteCharacter(self)

      end
    end
  end
  
  def updateOutfit
    $Trainer.outfitstate.applyToOverworldBitmap(self.charbitmap.bitmap)
  end
  
  alias old_dispose dispose
  def dispose
    old_dispose
    $Trainer.outfitstate.detach(@player_outfit_sprite_updater)
  end
  
end


def pbsetWetLayerState(layer_name, apparel_id, color="Default")
  if $DEBUG
    $ApparelBag.pbStoreApparel(layer_name, apparel_id, color)
  end
	
  if $ApparelBag.pbHasApparel?(layer_name, apparel_id, color)
    $Trainer.outfitstate.setWetLayerState(layer_name, apparel_id, color)
  else
    #echo "Doesnt have apparel\n" 
  end
end

def pbsetDryLayerState(layer_name, apparel_id, color="Default")
  if $DEBUG
    $ApparelBag.pbStoreApparel(layer_name, apparel_id, color)
  end

  if $ApparelBag.pbHasApparel?(layer_name, apparel_id, color)
    $Trainer.outfitstate.setDryLayerState(layer_name, apparel_id, color)
  else
    #echo "Doesnt have apparel\n"
  end
end


# UNUSED
# Converts a file name into a part name
# For example: "Pink_Pants.png" => "Pink Pants"
def convertFileName(file_name)
  # Find the index of the file extension
  last_index = file_name.index(".png")
  if !last_index
    last_index = file_name.index(".PNG")
  end
  
  # Copy the file name but leave out it's file extension
  part_name = file_name[0, last_index]

    # Replace all underscores with blank space
  loop do
    underscore_index = part_name.index("_")
    break if underscore_index == nil
    part_name[underscore_index] = " "
  end
    
  return part_name
end