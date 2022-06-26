module CSVCONST
  
  # Constants that dictate the order of data inside the recrods written to .dat
  # files (not fully corresponding to the records inside .txt files, as the
  # constant is intentionally left out of the .dat file)
  APPARELID    = 0
  APPARELCONST = 1
  APPARELNAME  = 2
  APPARELPRICE = 3
  APPARELCOLORS = 4
  APPARELDESC  = 5
  APPARELTYPE  = 6
  APPARELCLASS = 7
  APPARELSWIMSUIT = 8
  APPARELCONFLICTS = 9
  APPARELVARIANTS = 10
  
  DRYOUTFIT = 0
  WETOUTFIT = 1
  
end

$APPAREL_DELIMITER = ";"

def pbGetApparelName(layer, apparelId)
  echo "Inspect: " + $ApparelData.inspect + "\n"
  return $ApparelData[layer][apparelId][CSVCONST::APPARELNAME]
end

def pbGetApparelDesc(layer, apparelId)
  return $ApparelData[layer][apparelId][CSVCONST::APPARELDESC]
end

def pbGetApparelConflicts(layer, apparelId)
  conflicts = $ApparelData[layer][apparelId][CSVCONST::APPARELCONFLICTS]
  if conflicts != nil
    return conflicts.split($APPAREL_DELIMITER)
  else
    return []
  end
end

def pbGetApparelColors(layer, apparelId)
  #echo $ApparelData.inspect
  colors = $ApparelData[layer][apparelId][CSVCONST::APPARELCOLORS]
  if colors != nil && colors != ""
    return colors.split($APPAREL_DELIMITER)
  else
    return ["Default"]
  end
end

def pbCanSwimWithApparel?(layer, apparelId)
  return $ApparelData[layer][apparelId][CSVCONST::APPARELSWIMSUIT]
end

def pbCanPlayerSwim?
  
  #echo "Leg occupation: " + $Trainer.outfitstate.occupiedBy(CSVCONST::WETOUTFIT, "Legs")
  #echo "Torso occupation: " + $Trainer.outfitstate.occupiedBy(CSVCONST::WETOUTFIT, "Legs")

  
  # Check if the leg layer is occupied
  if $Trainer.outfitstate.occupiedBy(CSVCONST::WETOUTFIT, "Legs") != ""
    
    # Only legs have to be occupied for male trainers
    if $Trainer.outfitstate.gender == "Male"
      return true
    else
      
      # If trainer is not male, check if torso layer is also occupied
      if $Trainer.outfitstate.occupiedBy(CSVCONST::WETOUTFIT, "Torso") != ""
        return true
      else
        return false
      end
    end
  end
end

def pbGetApparelVariants(layer, apparelId)
  if apparelId = 0
    return []
  end
  
  variants = $ApparelData[layer][apparelId][CSVCONST::APPARELVARIANTS]
  if variants != nil
    return variants.split($APPAREL_DELIMITER)
  else
    return []
  end
  
end