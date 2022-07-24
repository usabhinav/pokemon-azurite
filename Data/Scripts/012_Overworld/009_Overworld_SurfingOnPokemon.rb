# Todo: Add every Pokemon that can learn surf into this list and maybe more
$SURFABLE_POKEMON_SPECIES = [
  321 # Wailord
]

def pbCanPlayerSurf?
  if $DEBUG
    return true
  else
    return false
  end
end

# Returns the first surfable Pokemon in the trainer's party, or nil if none was found
def pbGetSurfablePkmn
  
  for pkmn in $player.party
    next if pkmn.egg?
    if $SURFABLE_POKEMON_SPECIES.include?(pkmn.species)
      return pkmn
    end
  end
  
  if $DEBUG 
    return Pokemon.new(:WAILORD, 1)
  else
    # No Surfable Pokmeon found in party
    return nil
  end
  

  
end