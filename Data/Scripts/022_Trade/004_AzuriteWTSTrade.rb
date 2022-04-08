###############################################################################
# WTS Trade project, handles the trade between the database and the trainer
#   OnlineTrainderId: The trainer ID that will be used for the database
#   SentPokemon: The pokemon that will be sent/inserted into the wonder trade
#   ReceivedPokemon: The pokemon that is returned nd taken from the wonder trade
###############################################################################
class AzuriteWTSTrade
  
  attr_accessor :OnlineTrainerId
  attr_accessor :SentPokemon, :ReceivedPokemon
  
  def initialize()
    echo("\n\nInitializing AzuriteWTSTrade")
    @OnlineTrainerId=self.GetOnlineTrainerId()
    echo("\nOnline trainer id set to: "+@OnlineTrainerId)
    echo("\nFinished AzuriteWTSTrade initialization")
  end
  
  def GetOnlineTrainerId()
    echo("\nGetting Online Trainer Id.")
    r = execute("WTS","GetOnlineTrainerId", {
    "trainerId" => $Trainer.id,
    "trainerName" => $Trainer.name,
    "trainerPublicId" => $Trainer.publicID,
    "trainerPrivateId" => $Trainer.secretID
    })
    if(r=="False")
      return "0"
    end
    return r
  end
  
  def SetSentPokemon(pokemon)
    @SentPokemon=PDBData.new(pokemon)
  end
  
  def SetReceivedPokemon(pokemon)
    @ReceivedPokemon=PDBData.new(pokemon)
  end
  
  def CheckPokemonExists()
    echo("\nChecking if pokemon exists in trade")
    r = execute("WTS","CheckPokemonExists", {"PersonalId" => @SentPokemon.PersonalId})
    if(r=="False")
      return false
    else
      echo("\nPokemon exists.")
      return true
    end
  end
  
  def SendPokemon()
    echo("\nSending/Inserting "+@SentPokemon.Name)
    r = execute("WTS","PutPokemon", {"fields" => @SentPokemon.fields,
        "values" => @SentPokemon.values})
    if(r=="False")
      return false
    else
      echo("\nPokemon inserted")
      return true
    end
  end
  
  def GetPokemon()
    echo("\nReceiving Pokemon")
    r = execute("WTS","GetPokemon", {"OnlineTrainerId" => @OnlineTrainerId,
          "PokemonSentId" => @SentPokemon.PersonalId})
    if(r=="False")
      return false
    else
      self.SetReceivedPokemon(r.to_pokemon)
      echo("\nReceived Pokemon "+@ReceivedPokemon.Name)
      return true
    end
  end
end
