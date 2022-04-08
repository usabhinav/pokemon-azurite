module PBTypologies
  PLAIN      = 0
  MUSCLE     = 1
  FEATHER    = 2
  ACID       = 3
  DIRT       = 4
  PEBBLE     = 5
  INSECT     = 6
  SPIRIT     = 7
  IRON       = 8
  CINDER     = 9
  DROPLET    = 10
  TWIG       = 11
  SPARK      = 12
  BRAIN      = 13
  FLAKE      = 14
  SCALE      = 15
  VOID       = 16
  DUST       = 17
  MAGIC      = 18
  WAVE       = 19
  SHINE      = 20
  STAR       = 21
  GEMSTONE   = 22

  def PBTypologies.maxValue; 22; end
  def PBTypologies.getCount; 23; end

  def PBTypologies.getName(id)
    names=[
       _INTL("Basic"),
       _INTL("Power"),
       _INTL("Wind"),
       _INTL("Toxic"),
       _INTL("Earth"),
       _INTL("Stone"),
       _INTL("Insect"),
       _INTL("Haunted"),
       _INTL("Metal"),
       _INTL("Cinder"),
       _INTL("Hydro"),
       _INTL("Sprout"),
       _INTL("Lightning"),
       _INTL("Wisdom"),
       _INTL("Chill"),
       _INTL("Scale"),
       _INTL("Sinister"),
       _INTL("Pixie"),
       _INTL("Illusion"),
       _INTL("Noise"),
       _INTL("Shine"),
       _INTL("Galaxy"),
       _INTL("Prism")
    ]
    return names[id]
  end
end