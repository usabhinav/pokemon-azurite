# frozen_string_literal: true

# Can be used in trades, trainer pokemon, and encounters
class OnlinePlayerPokemon < OnlinePokemon

  attr_accessor :currentHp
  attr_accessor :standWatchHp
  attr_accessor :status
  attr_accessor :statusCount

  attr_accessor :forcedForm
  attr_accessor :forcedFormSet
  attr_accessor :fusedPokemon

  attr_accessor :trainerId
  attr_accessor :originalTrainerId
  attr_accessor :received

  attr_accessor :obtainLevel
  attr_accessor :obtainMap
  attr_accessor :obtainText
  attr_accessor :obtainMethod

  attr_accessor :pokeball
  attr_accessor :nickname
  attr_accessor :readyToEvolve

  attr_accessor :cannotStore
  attr_accessor :cannotRelease
  attr_accessor :cannotTrade

  attr_accessor :totalDamageDealt
  attr_accessor :totalDamageTaken
  attr_accessor :totalKoCount
  attr_accessor :totalFaintCount

  attr_accessor :eggSteps
  attr_accessor :hatchedMap
  attr_accessor :hatchedDate

  def initialize(playerPokemon)
    super(playerPokemon)
    @currentHp = playerPokemon.currentHp
    @status = playerPokemon.status
    @statusCount = playerPokemon.statusCount
    @standWatchHp = playerPokemon.standwatchhp
    @forcedForm = playerPokemon.forced_form
    @forcedFormSet = playerPokemon.time_form_set
    #@fusedPokemon
    @updated
    #@trainerId
    #@originalTrainerId
    @obtainLevel = playerPokemon.obtain_level
    @obtainMap = playerPokemon.obtain_map
    @obtainText = playerPokemon.obtain_text
    @obtainMethod = playerPokemon.obtain_method
    @pokeball = playerPokemon.poke_ball
    @nickname = playerPokemon.name
    @readyToEvolve = playerPokemon.ready_to_evolve
    @cannotStore = playerPokemon.cannot_store
    @cannotRelease = playerPokemon.cannot_release
    @cannotTrade = playerPokemon.cannot_trade
    @totalDamageDealt = playerPokemon.damage_dealt
    @totalDamageTaken = playerPokemon.damage_taken
    @totalKoCount = playerPokemon.ko_count
    @totalFaintCount = playerPokemon.faint_count
    @received = playerPokemon.timeReceived
    @eggSteps = playerPokemon.steps_to_hatch #todo change db
    @hatchedMap= playerPokemon.hatchec_map
    @hatchedDate = playerPokemon.timeEggHatched
  end
end
