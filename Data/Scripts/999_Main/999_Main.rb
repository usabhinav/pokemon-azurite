$DEBUG = TRUE

#Console::setup_console

# Create .dat apparel files in case they don't exist. Without this the compiler is unable to write into them. 
for layer in $LAYER_NAMES
  File.open("Data/Apparel/" + layer + ".dat", "w") if !safeExists?("Data/Apparel/" + layer + ".dat")
end
File.open("Data/Apparel/Type.dat", "w") if !safeExists?("Data/Apparel/Type.dat")
File.open("Data/Apparel/Class.dat", "w") if !safeExists?("Data/Apparel/Cype.dat")

pbCompiler

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
    PluginManager.runPlugins
    Compiler.main
    Game.initialize
    Game.set_up_system
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    $scene.main until $scene.nil?
    Graphics.transition(20)
  rescue Hangup
    pbPrintException($!) if !$DEBUG
    pbEmergencySave
    raise
  end
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
