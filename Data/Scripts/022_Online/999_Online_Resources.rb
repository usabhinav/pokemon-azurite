# frozen_string_literal: true

class OnlineResources

  # Constants class for endpoint pathing, replicated based on c# resources class
  URL = SCHEME + "://" + HOST + ":" + PORT.to_s
  SCHEME = "https"
  HOST = "localhost"
  PORT = 8091

  class Asset
    ENDPOINT = "/Asset"
  end

  class Discord
    ENDPOINT = "/Discord"
  end

  class Game
    ENDPOINT = "/Game"
    TRAINER = "/Trainers"
    TRAINER_POKEMON = "/TrainerPokemon"
    TRAINER_ENCOUNTERS = "/TrainerEncounters"
  end

  class Info
    ENDPOINT = "/Info"
    PING = BASE + "/Ping"
  end

  class Web
    ENDPOINT = "/Web"
  end
end
