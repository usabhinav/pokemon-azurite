# frozen_string_literal: true

# Can be used in trades, trainer pokemon, and encounters
class OnlinePokemon
  attr_accessor :id #uuid
  attr_accessor :personalId
  attr_accessor :species
  attr_accessor :datastring # should be the marshal byte array rep the obj

  attr_accessor :gender
  attr_accessor :level
  attr_accessor :experience
  attr_accessor :happiness
  attr_accessor :nature

  attr_accessor :hp
  attr_accessor :attack
  attr_accessor :defense
  attr_accessor :speed
  attr_accessor :specialAttack
  attr_accessor :specialDefense

  attr_accessor :evHp
  attr_accessor :evAttack
  attr_accessor :evDefense
  attr_accessor :evSpeed
  attr_accessor :evSpAttack
  attr_accessor :evSpDefense

  attr_accessor :ivHp
  attr_accessor :ivAttack
  attr_accessor :ivDefense
  attr_accessor :ivSpeed
  attr_accessor :ivSpAttack
  attr_accessor :ivSpDefense

  attr_accessor :beauty
  attr_accessor :cool
  attr_accessor :cute
  attr_accessor :smart
  attr_accessor :tough
  attr_accessor :sheen

  attr_accessor :markingOne
  attr_accessor :markingTwo
  attr_accessor :markingThree
  attr_accessor :markingFour
  attr_accessor :markingFive
  attr_accessor :markingSix

  attr_accessor :pokerus
  attr_accessor :shinyVariant

  attr_accessor :ability
  attr_accessor :hiddenAbility

  #move info

  attr_accessor :heldItem

  attr_accessor :created #datetime of obj generated
  def initialize(pokemon)
    #@id #uuid
    @personalId = pokemon.personalID
    @species = pokemon.species
    #@datastring

    @gender = pokemon.gender
    @level = pokemon.level
    @experience = pokemon.exp
    @happiness = pokemon.happiness
    @nature = pokemon.nature

    @hp = pokemon.totalhp
    @attack  = pokemon.attack
    @defense = pokemon.defense
    @speed   = pokemon.speed
    @specialAttack = pokemon.spatk
    @specialDefense = pokemon.spdef

    #@evHp
    #@evAttack
    #@evDefense
    #@evSpeed
    #@evSpAttack
    #@evSpDefense

    #@ivHp
    #@ivAttack
    #@ivDefense
    #@ivSpeed
    #@ivSpAttack
    #@ivSpDefense

    @beauty = pokemon.beauty
    @cool = pokemon.cool
    @cute = pokemon.cute
    @smart = pokemon.smart
    @tough = pokemon.tough
    @sheen = pokemon.sheen

    #@markingOne
    #@markingTwo
    #@markingThree
    #@markingFour
    #@markingFive
    #@markingSix

    @pokerus = pokemon.pokerus
    @shinyVariant = pokemon.shiny_variant

    #@ability = pokemon.ability.name # internal name of ability
    #@hiddenAbility

    #@heldItem

    #@created
  end

end
