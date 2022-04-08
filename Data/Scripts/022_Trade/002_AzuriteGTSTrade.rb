###############################################################################
# Azurite GTS, Main object for GTS, holds the online trainer id and stats. Can
#   Create trades, getcurrenttrades, getHistoryTrades, modify, and cancel
###############################################################################
class AzuriteGTSTrade
  
  attr_accessor :OnlineTrainerId
  attr_accessor :HadPokemon, :WantPokemon, :SentPokemon, :ReceivedPokemon
  attr_accessor :Status
  
  
  def initialize(params={})
    echo("\n\nInitializing AzuriteGTSTrade")
    @OnlineTrainerId=self.GetOnlineTrainerId()
    echo("\nOnline trainer id set to: "+@OnlineTrainerId)
    echo("\nFinished AzuriteGTSTrade initialization")
  end
  
  def SetHadPokemon(pokemon)
      @HadPokemon=PDBData.new(pokemon)
  end
    
  def SetWantPokemon(params={})
    @WantPokemon=PDBData.new(nil)
    #pass params to pdbdata to parse
  end
  
  def SetSentPokemon(pokemon)
    @SentPokemon=PDBData.new(pokemon)
  end
  
  def SetReceivedPokemon(pokemon)
    @ReceivedPokemon = PDBData.new(pokemon)
  end
    
  def CheckPokemonExists()
    echo("\nChecking if pokemon exists in trade")
    r = execute("GTS","CheckPokemonExists", {
    "PersonalId" => @HadPokemon.PersonalId})
    if(r=="False")
      echo("\nPokemon doesn't exists")
      return false
    else
      echo("\nPokemon already exist")
      return true
    end
  end
   
  def GetOnlineTrainerId()
    echo("\nGetting Online Trainer Id.")
    r = execute("GTS", "GetOnlineTrainerId",{
    "trainerId" => $Trainer.id,
    "trainerName" => $Trainer.name,
    "trainerPublicId" => $Trainer.publicID,
    "trainerPrivateId" => $Trainer.secretID
    })
    return r
  end
  
   def SendTrade()
     echo("\nSending Pokemon to GTS")
     r = execute("GTS","PutPokemon",{
     "fields"=>@HadPokemon.fields,"values"=>@HadPokemon.values})
     #r is set to the row that the pokemon (has) was inserted
     r2 = execute("GTS","PutPokemon",{
     "fields"=>@WantPokemon.fields,"values"=>@WantPokemon.values})
     #r2 is set to the row id that the pokemon (want) was inserted
     r3 = execute("GTS","Link",{
     "OnlineTrainerId"=>@OnlineTrainerId,"HadId"=>r,"WantId"=>r2})
     if(r=="False")
       return false
     else
       echo("\nTrade sent")
       return true
     end     
   end

end
