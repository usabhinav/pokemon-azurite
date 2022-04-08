###############################################################################
# Azurite GTS, Main object for GTS, holds the online trainer id and stats. Can
#   Create trades, getcurrenttrades, getHistoryTrades, modify, and cancel
###############################################################################
class AzuriteGTS
  
  attr_accessor :OnlineTrainerId, :CurrentTrade
  attr_accessor :WhereClause,:OrderClause
  
  def initialize()
    ##Check if online or not, set bool
    echo("\nInitializing")
    @OnlineTrainerId = self.GetOnlineTrainerId()
    echo("\nSetup complete.\nOnline Trainer Id: "+@OnlineTrainerId.to_s+".\nMemory: "+self.to_s)
    echo("\nFinished AzuriteGTS initialization")
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
  
  #add params={} for search/sort
  def GetTradeHistory()
    
  end
  
  def CreateNewTrade()
    @CurrentTrade=AzuriteGTSTrade.new()
  end
  
  def ExecuteTrade()
    if(!@CurrentTrade.CheckPokemonExists())
        if(@CurrentTrade.SendTrade())
           echo("Trade inserted")
        else
           echo("Trade not inserted")
        end
        else
          echo("Trade not inserted")
        end
    else
      return nil
    end
end

  
