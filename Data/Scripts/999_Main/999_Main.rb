$DEBUG = true



# Create .dat apparel files in case they don't exist. Without this the compiler is unable to write into them. 
for layer in $LAYER_NAMES
  File.open("Data/Apparel/" + layer + ".dat", "w") if !safeExists?("Data/Apparel/" + layer + ".dat")
end
File.open("Data/Apparel/Type.dat", "w") if !safeExists?("Data/Apparel/Type.dat")
File.open("Data/Apparel/Class.dat", "w") if !safeExists?("Data/Apparel/Cype.dat")

# pbCompiler

class Scene_DebugIntro
  def main
    Graphics.transition(0)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
    Graphics.freeze
  end
end

def pbCallTitle
  return Scene_DebugIntro.new if $DEBUG
  return Scene_Intro.new
end

def mainFunction
  if $DEBUG
    pbCriticalCode { mainFunctionDebug }
  else
    mainFunctionDebug
  end
  return 1
end

def mainFunctionDebug
  begin
    MessageTypes.loadMessageFile("Data/messages.dat") if safeExists?("Data/messages.dat")
    PluginManager.runPlugins
    Compiler.main
    Game.initialize
    Game.set_up_system
    Graphics.update
    Graphics.freeze
    
    outfit = OutfitState.new(1, "Walking")
    echoln outfit.instance_variables.to_s
    
    Console::setup_console
    Compiler::compile_apparel

    $scene = pbCallTitle
    $scene.main until $scene.nil?
    Graphics.transition(20)
    
  rescue Hangup
    pbPrintException($!) if !$DEBUG
    pbEmergencySave
    raise
  end
end

# Conclusion: .itself doesnt exist in this ruby version.
def pointerExperiment
  outfit1 = OutfitState.new(1, "Walking")
  outfit2 = OutfitState.new(1, "Walking")
  
  outfit1.gender = "Male"
  outfit2.gender = "Female"
  
  outfit1_pointer = outfit1
  
  
  outfit1_pointer.itself = pbDeepCopy(outfit2)
  
  echoln "OUTFIT1: " + outfit1.gender
  
end

def testywesty

  ashash = {:id => :YEET,
         :id_number => 1,
         :name => "Yeet",
         :type_id => 0,
         :class_id => 0
        }

  as = GameData::ApparelSocks.new( 
        {:id => :YEET,
         :id_number => 1,
         :name => "Yeet",
         :type_id => 0,
         :class_id => 0
        })
  al = GameData::ApparelLegs.new( 
        {:id => :YAYEET,
         :id_number => 1,
         :name => "Yayeet",
         :type_id => 0,
         :class_id => 0
        })
   
  
  # echoln Object.const_get("GameData::ApparelSocks")
  #GameData::ApparelSocks.register(ashash)
  # GameData::ApparelSocks.send(:register,ashash)
  # echoln GameData::ApparelLegs::DATA.to_s
  # echoln GameData::ApparelSocks::DATA.to_s
  # echoln :Bep.to_s
  # echoln :bep.to_s
  # echoln GameData::ApparelLegs.superclass.to_s
  
  MessageTypes.setMessagesAsHash(MessageTypes::ApparelColors, ["Socks3", "Cocks"])
  echoln pbGetMessageFromHash(MessageTypes::ApparelColors, "Socks3")
  
  
  
end

loop do
  retval = mainFunction
  if retval == 0   # failed
    loop do
      Graphics.update
    end
  elsif retval == 1   # ended successfully
    break
  end
end
