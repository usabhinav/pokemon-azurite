module PBHabitats
  None         = 0
  Fields       = 1
  Forest       = 2
  Beach        = 3
  Sea          = 4
  Cave         = 5
  Mountain     = 6
  Underground  = 7
  Urban        = 8
  Rare         = 9
  Cosmos       = 10
  Jungle       = 11
  Desert       = 12
  Skies        = 13
  Underwater   = 14
  Tundra       = 15
  Graveyard    = 16
  Volcano      = 17

  def self.maxValue; 17; end
  def self.getCount; 18; end

  def self.getName(id)
    id = getID(PBHabitats,id)
    names = [
       _INTL("Unknown"),
       _INTL("Fields"),
       _INTL("Forest"),
       _INTL("Beach"),
       _INTL("Sea"),
       _INTL("Cave"),
       _INTL("Mountain"),
       _INTL("Underground"),
       _INTL("Urban"),
       _INTL("Rare"),
       _INTL("Cosmos"),
       _INTL("Jungle"),
       _INTL("Desert"),
       _INTL("Skies"),
       _INTL("Underwater"),
       _INTL("Tundra"),
       _INTL("Graveyard"),
       _INTL("Volcano"),
    ]
    return names[id]
  end
end