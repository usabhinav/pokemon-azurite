class DungeonRewards
  def initialize(dungeon_id, guild)
    @dungeon = GameData::Dungeon.get(dungeon_id)
    @guild = guild
  end

  def giveRewards
    if @dungeon.is_initial
      giveInitialRewards
    else
      giveMysteryRewards
    end
  end

  def giveInitialRewards
    reward_list = @dungeon.reward_list
    giveGummis
    foundMessage(@guild.guildMaster, reward_list[0], reward_list[1])
    foundMessage(@guild.guildMembers[0], reward_list[2], reward_list[3])
    # Special case for Hidden Land
    if reward_list[4] == "GEMS"
      pbMessage(_INTL("{1} found a stack of gems!", @guild.guildMembers[1].name))
      gemlist = [] # TODO: Fill with list of type gems
      # TODO: Give 3 of the rest of type gems (fairy, mystic, sound, light, cosmic, crystal)
      for sym in gemlist
        $bag.add(sym, reward_list[5])
      end
    else
      foundMessage(@guild.guildMembers[1], reward_list[4], reward_list[5])
    end
    foundMessage(@guild.guildMembers[2], reward_list[6], reward_list[7])
    # TODO: Members 4+ rewards
  end

  def giveMysteryRewards
    # TODO: Give rewards
    giveMasterReward
    for poke in @guild.guildMembers
      giveMemberReward(poke)
    end
  end

  def giveGummis
    # TODO: Gummi Reward
    gummicount = @dungeon.gummi_reward
    totalhp = [150, @guild.guildMaster.totalhp].min
    gummicount *= 1 + (0.01 * totalhp)
    for i in 0...gummicount
      
    end
  end

  def foundMessage(pokemon, item, amount)
    return if item.nil?
    if amount == 1
      pbMessage(_INTL("{1} found a {2}!", pokemon.name, GameData::Item.get(item).name))
    else
      pbMessage(_INTL("{1} found {2}x {3}!", pokemon.name, amount, GameData::Item.get(item).name))
    end
    $bag.add(item, amount)
  end

  def giveMasterReward
    echoln "==========================================================="
    echoln "Guild Master:"
    tierchances = [[60, 30, 10], [50, 35, 15], [40, 40, 20], [30, 50, 20], [30, 40, 30], [25, 25, 50]]
    chancelist = tierchances[@guild.guildMaster.affection_level]
    echoln "hearts: #{@guild.guildMaster.affection_level}"
    echoln "chancelist: #{chancelist}"
    chance = rand(100)
    if chance < chancelist[0] # Tier 1
      tier = 0
    elsif chance < chancelist[0] + chancelist[1] # Tier 2
      tier = 1
    else # Tier 3
      tier = 2
    end
    echoln "tier: #{tier}"
    tierpool = @dungeon.master_reward_pool[tier]
    randindex = rand(tierpool.length / 3) * 3
    randamount = rand(tierpool[randindex + 1]..tierpool[randindex + 2])
    foundMessage(@guild.guildMaster, tierpool[randindex], randamount)
  end
  
  def giveMemberReward(poke)
    echoln "==========================================================="
    echoln "Guild Member #{poke.name}:"
    # Refer to Explorer's Guild doc to understand how this works
    scale = 15 - (([150,poke.spatk].min) / 10) + (([150,poke.attack].min) / 10)
    echoln "attack: #{poke.attack}"
    echoln "spatk: #{poke.spatk}"
    echoln "scale: #{scale}"
    chance = rand(30)
    if chance < scale
      echoln "useful"
      pool = @dungeon.useful_reward_pool
      tierchances = [[50, 35, 15], [40, 40, 20], [30, 50, 20], [15, 35, 50]]
      chancelist = tierchances[([150, poke.defense].min) / 50]
      echoln "defense: #{poke.defense}"
      echoln "chancelist: #{chancelist}"
    else
      echoln "valuable"
      pool = @dungeon.valuable_reward_pool
      tierchances = [[75, 20, 5], [50, 35, 15], [40, 40, 20], [30, 30, 40]]
      chancelist = tierchances[([150, poke.spdef].min) / 50]
      echoln "spdef: #{poke.spdef}"
      echoln "chancelist: #{chancelist}"
    end
    chance = rand(100)
    if chance < chancelist[0] # Tier 1
      tier = 0
    elsif chance < chancelist[0] + chancelist[1] # Tier 2
      tier = 1
    else # Tier 3
      tier = 2
    end
    echoln "tier: #{tier}"
    tierpool = pool[tier]
    randindex = rand(tierpool.length / 3) * 3
    level = [50, poke.level].min
    min = tierpool[randindex + 1]
    max = tierpool[randindex + 2]
    echoln "min: #{min}, max: #{max}"
    amount = ((level.to_f / 50) * (max - min)).to_i + min
    foundMessage(poke, tierpool[randindex], amount)
  end
end