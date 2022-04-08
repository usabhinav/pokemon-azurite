###############################################################################
# WTS main object, stores the online trainer id and stats, should be able to
#   Create and execute a global trade and also get a history of trades
###############################################################################
class AzuriteWTS
  
  attr_accessor :IsOnline,:OnlineTrainerId
  attr_accessor :WhereClause,:OrderClause
  
  
  def initialize()
    ##Check if online or not, set bool
    echo("\nInitializing")
    @OnlineTrainerId = self.GetOnlineTrainerId()
  
    @WhereClause = "WHERE 1=1"
    @OrderClause = ""
    
    echo("\nSetup complete.\nOnline Trainer Id: "+@OnlineTrainerId+".\nMemory: "+self.to_s)
    echo("\nFinished AzuriteWTS initialization")
  end
  
  def GetOnlineTrainerId()
    echo("\nGetting Online Trainer Id.")
    r = execute("WTS", "GetOnlineTrainerId",{
    "trainerId" => $Trainer.id,
    "trainerName" => $Trainer.name,
    "trainerPublicId" => $Trainer.publicID,
    "trainerPrivateId" => $Trainer.secretID
    })
    return r
  end
  
  #params?
  def PopulateDatabase(count)
    i=0
    echo("\nStarting database population")
    while i < count
      species = 1+rand(PBSpecies.maxValue)
      while(species > 802 && species < 1001)
        species = 1+rand(PBSpecies.maxValue)
      end
      level = 1+rand(100)
      pbAddPokemonSilent(species,level)
      n = AzuriteWTSTrade.new()
      n.SetSendingPokemon($Trainer.party[$Trainer.party.length-1])
      n.SendPokemon()
      pbRemovePokemonAt($Trainer.party.length-1)
      i+=1
    end
    echo("\nPopulated the database with "+count.to_s+" Pokemon")
  end
  
  #add params={} for search/sort
  def GetTradeHistory(params={})
    #the params specify where clause and order clause
  end
  
  def ExecuteTrade(pokemon)
    t=AzuriteWTSTrade.new()
    t.SetSentPokemon(pokemon)
    if(!t.CheckPokemonExists())
      if(t.SendPokemon())
        if(t.GetPokemon())
          return t.ReceivedPokemon
        end
      end
    end
    return nil
  end
  
  def AddToPool(pokemon)
    t=AzuriteWTSTrade.new()
    t.SetSentPokemon(pokemon)
     if(!t.CheckPokemonExists())
      t.SendPokemon()
    end
  end
  
end

