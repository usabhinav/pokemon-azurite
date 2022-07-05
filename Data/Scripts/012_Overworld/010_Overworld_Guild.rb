# Explorer's Guild

class Guild
  attr_accessor :id
  attr_accessor :guildMaster
  attr_accessor :guildKeeper
  attr_accessor :guildMembers
  attr_accessor :berryPatches
  attr_accessor :gummis
  attr_accessor :dungeonInProgress
  attr_accessor :dungeonSteps
  attr_accessor :dungeonCompleted # Queued dungeon to give rewards once completed
  attr_accessor :guildBackground
  attr_accessor :guildRug
  attr_accessor :completedDungeons
  
  def initialize
    @id = 0
    @guildMaster = nil
    @guildKeeper = nil
    @guildMembers = []
    @berryPatches = Array.new(6)
    @gummis = 0
    @dungeonInProgress = nil
    @dungeonSteps = -1
    @dungeonCompleted = nil
    @guildBackground = 0 # TODO: Change later
    @guildRug = 0 # TODO: Change later
    @completedDungeons = []
  end
  
  def name
    ranknames = ["Simple", "Natural", "Vibrant", "Maple", "Champion"]
    return ranknames[@id]
  end
  
  def rankup
    return if @id == 4 # Champion
    @id += 1
  end
  
  def canStartDungeon?(dungeon_id)
    if @guildMaster.nil?
      pbMessage(_INTL("You need a Guild Master to explore a dungeon!"))
      return false
    end
    if @guildMembers.length < 3
      pbMessage(_INTL("You need at least 3 guild members to explore a dungeon!"))
      return false
    end
    dungeon = GameData::Dungeon.get(dungeon_id)
    return dungeon.unlocked?(self) && dungeon.can_start?(self)
  end
  
  def startDungeon(dungeon_id)
    @dungeonInProgress = dungeon_id
    @dungeonSteps = 0
    pbMessage(_INTL("Your guild has entered {1}!", getCurrentDungeon.name))
  end
  
  def inDungeon?
    return !@dungeonInProgress.nil?
  end
  
  def getCurrentDungeon
    return inDungeon? ? GameData::Dungeon.get(@dungeonInProgress) : nil
  end
  
  def completedDungeon?(dungeon_id)
    return @completedDungeons.include?(dungeon_id)
  end
  
  def updateSteps
    if inDungeon?
      @dungeonSteps += 1
      if @dungeonSteps >= getCurrentDungeon.steps
        @dungeonCompleted = @dungeonInProgress
        @dungeonInProgress = nil
        @dungeonSteps = -1
        pbMessage(_INTL("Your guild has returned from the dungeon!"))
      end
    end
  end
  
  def giveDungeonRewards(scene, trainer)
    dungeon = GameData::Dungeon.get(@dungeonCompleted)
    pbMessage(_INTL("{1} complete!", dungeon.name))
    # TODO: Give exp gains
    thispoke = @guildMaster
    # TODO: "dungeon.steps" should account for speedup items and stuff
    if @guildMaster.exp < @guildMaster.growth_rate.maximum_exp
      masterexpgain = @guildMaster.level * convertStepsToMinutes(dungeon.steps) / 2
      masterexpgain *= 1 + ((@guildMembers.length - 3).to_f / 5)
      masterexpgain *= 1 + (trainer.badge_count.to_f / 10)
      masterexpgain = masterexpgain.floor
      pbChangeExp(@guildMaster, @guildMaster.exp + masterexpgain, scene)
    end
    for poke in @guildMembers
      chance = (poke.affection_level * 5) + 5

      echoln "chance = #{chance}, hearts = #{poke.affection_level}"

      if poke.level < GameData::GrowthRate.max_level && rand(100) < chance
        pbChangeLevel(poke, poke.level + 1, scene)
      end
    end
    DungeonRewards.new(@dungeonCompleted, self).giveRewards
    @completedDungeons.push(@dungeonCompleted)
    @dungeonCompleted = nil
  end
  
  def convertStepsToMinutes(steps)
    return steps # TODO: Need actual conversion
  end
end

# Update guild
EventHandlers.add(:on_step_taken, :update_guild,
  proc { |event|
    $PokemonGlobal.guild.updateSteps
  }
)