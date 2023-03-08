# frozen_string_literal: true

class OnlinePlayer
  # NEW
  # TODO need to add to save game data, one uuid installed in registry (machineId)
  # TODO need to add to save game data, one uuid only for trainer (trainerId)
  # TODO this allows 1 machine with multiple online trainer profiles
  attr_accessor :online_machine_id
  attr_accessor :online_player_id

  # From Trainer
  attr_accessor :id
  attr_accessor :name
  attr_accessor :language

  # From Player
  attr_accessor :money
  attr_accessor :coins
  attr_accessor :soot
  attr_accessor :battle_points
  attr_accessor :has_pokedex
  attr_accessor :has_pokegear
  attr_accessor :has_running_shoes
  attr_accessor :has_box_link
  attr_accessor :has_exp_all
  attr_accessor :seen_storage_creator
  attr_accessor :outfit

  def initialize(player)
    # NEW
    #@online_Player_Id      = player.uuid
    #@online_Machine_Id     = GAMEDATA::OnlineMachineId //todo store in settings? Can this be edited in/out of game?

    # From Trainer
    @id                    = player.id
    @name                  = player.name
    @language              = player.language

    # From Player
    @money                 = player.money
    @coins                 = player.coins
    @soot                  = player.soot
    @battle_points         = player.battle_points
    @has_pokedex           = player.has_pokedex
    @has_pokegear          = player.has_pokegear
    @has_running_shoes     = player.has_running_shoes
    @has_box_link          = player.has_box_link
    @has_exp_all           = player.has_exp_all
    @seen_storage_creator  = player.seen_storage_creator
    @outfit                = player.outfit

    # TODO Add game version to online
  end

  def to_hash
    {"online_Player_ID"       => @online_Player_ID,
    "online_Machine_Id"       => @online_Machine_Id,
  "id"                        => @id,
  "name"                      => @name,
  "language"                  => @language,
  "money"                     => @money,
  "coins"                     => @coins,
  "soot"                      => @soot,
  "battle_points"             => @battle_points,
  "has_pokedex"               => @has_pokedex,
  "has_running_shoes"         => @has_running_shoes,
  "has_box_link"              => @has_box_link,
  "has_exp_all"               => @has_exp_all,
  "seen_storage_creator"      => @seen_storage_creator,
  "outfit"                    => @outfit}
  end
end
