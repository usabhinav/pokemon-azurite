
#Heartbeat function triggered only by map refresh for now.
def heartbeat(mapID)
  puts "Sending Heartbeat on map reset"
  hb1(mapID)
end

=begin
First heartbeat function implemented, feel free to replace
with a more meaningful name once it's time to have
different heartbeats with varying amounts of detail.
=end
def hb1(mapID)
  #Only do a heartbeat if the trainer is initialized. Otherwise throws an error.
  if not $Trainer
    return
  end
    postdata =  {
      "TrainerInfo" => $Trainer.serializeTrainerInfo,
      "MapID" => $mapID.to_s
    }
    postdata = HTTPLite::JSON.stringify(postdata)
    puts "Heartbeat contents: " + postdata
  response = HTTPLite.post_body("http://localhost:8080", postdata, 'application/json')
rescue Exception => e
  puts e + "(see 001_Serializer.rb for details)"
=begin
  The exception was raised because the post request of the heartbeat failed."
  This might be where the user gets a notification that they are not able to connect to the server?"
  Currently the address of the post request is localhost:8080, as I used a local echo server for testing."
=end
end

=begin
Serialization extension for Player class from 004_Player.rb
What I've got here seemed to work when I tested it.
=end

class Player
  def serializeTrainerInfo
    {"trainerName" => self.name,
    "trainerId" => self.id.to_s,
    "trainerPublicId" => self.public_ID.to_s,
    "trainerPrivateId" => self.secret_ID.to_s,
    "sex" => self.gender,
    "language" => self.language,
    "money" => self.money
  }
  end
end
=begin
JSON extension for Pokebattle_Pokemon. Based on Initialize function from
001_Pokebattle_Pokemon.rb
This extension might be out of date if Pokemon data we'd be sending
as part of a player's party are stored as a different class.
This function is not used currently, and is included as a template
for what the final one may look like.

class PokeBattle_Pokemon
  def to_json(*args)
    {JSON.create_id => self.class.name,
      "species" => @species,
      "form" => @form,
      "level" => @level,
      "gender" => self.gender(), #I couldn't find a variable that stores Gender, so I'm serializing it with this function
      "name" => @name,
      "personalID" => @personalID,
      "hp" => @hp,
      "stats" => [@totalhp, @attack, @defense, @spatk, @spdef, @speed],
      "iv" => @iv,
      "ivMaxed" => @ivMaxed,
      "ev" => @ev,
      "moves" => @moves, #Dependent on PBMove serialization
      "status" => @status,
      "statusCount" => @statusCount,
      "item" => @item,
      "mail" => @mail, #Dependent on PBMail serialization?
      "fused" => @fused, #I think this one is a Pokemon object, e.g. Black Kyurem has Zekrom "fused" into it.
      "ribbons" => @ribbons, #Array of Ribbons, check if this needs serialization too
      "ballused" => @ballused,
      "eggsteps" => @eggsteps,
      "trainerID" => @trainerID,
      "ot" => @ot,
      "otgender" => @otgender,
      "language" => @language, #Is it possible for null language? Initialize function only sets "language" if "player"
      "obtainmap" => @obtainMap,
      "obtainText" => @obtainText,
      "obtainLevel" => @obtainLevel,
      "obtainMode" => @obtainMode,
      "hatchedMap" => @hatchedMap,
      "timeReceived" => @timeReceived,
      "timeEggHatched" => @timeEggHatched,
      "happiness" => @happiness,
      "exp" => @exp,
      "contestStats" => [@cool, @beauty, @cute, @smart, @tough, @sheen]
    }.to_json(*args)
  end
end

=end
