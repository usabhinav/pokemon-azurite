class PDBData
  
  attr_accessor :fields, :values

  attr_accessor :pokemon, :PersonalId, :OriginalTrainerID, :Name, :Number, :ObtainLevel, :Level, :Gender, :Experience
  attr_accessor :Typology, :Nature, :Ability, :HiddenAbility
  attr_accessor :EVHp, :EVAttack, :EVDefence, :EVSpeed, :EVSpecialAttack, :EVSpecialDefence
  attr_accessor :IVHp, :IVAttack, :IVDefence, :IVSpeed, :IVSpecialAttack, :IVSpecialDefence
  attr_accessor :Beauty, :Cool, :Cute, :Smart, :Tough, :Sheen
  attr_accessor :IsShiny, :IsAlbino, :IsShadow, :IsAlolan, :IsDelta, :IsLegendary, :Datastring, :Available
  attr_accessor :MoveOne, :MoveTwo, :MoveThree, :MoveFour
  
  #Initialization
  def initialize(pokemon)
    echo("\nStarting PDBData initialization")
    
    #pokemon = params.fetch(:pokemon,"") not working
    
    if(pokemon != nil)
      echo("\nPokemon not null, parsing")
      self.ParsePokemonData(pokemon)
    else
      echo("\nPokemon param null, setting default vals")
      self.SetDefaultData()
    end

 #   \''+@+'\',

    @fields='PersonalId,OriginalTrainerID,ObtainLevel,Name,Number,Level,Gender,Experience'\
    ',Typology,Nature,Ability,HiddenAbility,'\
    ',EVHp,EVAttack,EVDefence,EVSpeed,EVSpecialAttack,EVSpecialDefence'\
    ',IVHp,IVAttack,IVDefence,IVSpeed,IVSpecialAttack,IVSpecialDefence'\
    ',Beauty,Cool,Cute,Smart,Tough,Sheen,'\
    ',IsShiny,IsAlbino,IsShadow,IsAlolan,IsDelta,IsLegendary,HasPokerus,Datastring,Available'\
    ',MoveOne,MoveTwo,MoveThree,MoveFour'
    
    @values='\''+@PersonalId+'\',\''+@Name+'\', \''+@OriginalTrainerID'\',\''+@ObtainLevel+'\',\''+@Experience+'\','\
    ',\''+@Number.to_s+'\',\''+@Level.to_s+'\',\''+@Gender.to_s+'\',\''+@Typology.to_s+'\''\
    ',\''+@Nature+'\',\''+@Ability+'\', \''+@HiddenAbility+'\',\''+@EVHp.to_s+'\''\
    ',\''+@EVAttack.to_s+'\',\''+@EVDefence.to_s+'\',\''+@EVSpeed.to_s+'\',\''+@EVSpecialAttack.to_s+'\''\
    ',\''+@EVSpecialDefence.to_s+'\',\''+@IVHp.to_s+'\',\''+@IVAttack.to_s+'\',\''+@IVDefence.to_s+'\',\''+@IVSpeed.to_s+'\',\''+@IVSpecialAttack.to_s+'\',\''+@IVSpecialDefence.to_s+'\''\
    ',\''+@IsShiny+'\',\''+@IsAlbino+'\',\''+@IsShadow+'\',\''+@IsAlolan+'\',\''+@IsDelta+'\',\''+@IsLegendary+'\''\
    ', \''+@Beauty+'\', \''+@Cool+'\', \''+@Cute+'\', \''+@+Smart'\', \''+@Tough+'\', \''+@Sheen+'\''\
    ',\''+@Datastring.to_s+'\'\''+@HasPokerus+'\',\''+@Available+'\''\
    ',\''+@MoveOne+'\',\''+@MoveTwo+'\',\''+@MoveThree+'\',\''+@MoveFour+'\''\
    ',\'1\''
    
    echo("\nFinished PDBData initialization")
  end 
  
  def ParsePokemonData()
    #for real trade where 'want' has no datastring so cannot parse
    
  end
  
  def SetDefaultData()
    echo("\nStarting to set PDBData attributes...")
       @pokemon = nil
       @PersonalId = "0"
       @OriginalTrainerID = ''
       @ObtainLevel = ''
       @Name = ''
       @Number = ''
       @Level = ''
       @Gender=''
       @Typology =''
       @Nature = ''
       @Ability = ''
       @HiddenAbility = ''
       @EVHp = '0'
       @EVAttack = '0'
       @EVDefence = '0'
       @EVSpeed = '0'
       @EVSpecialAttack = '0'
       @EVSpecialDefense = '0'
       @IVHp = '0'
       @IVAttack = '0'
       @IVDefence = '0'
       @IVSpeed = '0'
       @IVSpecialAttack = '0'
       @IVSpecialDefence = '0'
       @Beauty = '0'
       @Cool = '0'
       @Cute = '0'
       @Smart = '0'
       @Tough = '0'
       @Sheen = '0'
       @MoveOne = ''
       @MoveTwo = ''
       @MoveThree = ''
       @MoveFour = ''
       @IsShiny = '0'
       @IsAlbino = '0'
       @IsShadow = '0'
       @IsAlolan = '0'
       @IsDelta = '0'
       @IsLegendary='0'
       @Datastring = '0'
       @Available = ''

       echo("\nFinished setting PDBData attributes")
  end
  
  
  def ParsePokemonData(pokemon)
    echo("\nStarting to set PDBData attributes...")
       @pokemon = pokemon
       @PersonalId = pokemon.personalID.to_s
       @Name = pokemon.name
       @Number = pokemon.species
       @Level = pokemon.level
       case pokemon.gender
         when 0
           @Gender="Male"
         when 1
           @Gender="Female"
        when 2
           @Gender="Genderless"
         end
       @Typology =  PBTypologies.getName(pokemon.typology)
       @Nature = PBNatures.getName(pokemon.nature)
       @Ability = PBAbilities.getName(pokemon.ability)
       @EVHp = pokemon.ev[0]
       @EVAttack = pokemon.ev[1]
       @EVDefence = pokemon.ev[2]
       @EVSpeed = pokemon.ev[3]
       @EVSpecialAttack = pokemon.ev[4]
       @EVSpecialDefense = pokemon.ev[5]
       @IVHp = pokemon.iv[0]
       @IVAttack = pokemon.iv[1]
       @IVDefence = pokemon.iv[2]
       @IVSpeed = pokemon.iv[3]
       @IVSpecialAttack = pokemon.iv[4]
       @IVSpecialDefence = pokemon.iv[5]
       @IsShiny = (pokemon.isShiny?)?"1":"0"
       @IsAlbino = (pokemon.isAlbino?)?"1":"0"
       @IsShadow = (pokemon.isShadow?)?"1":"0"
       @IsAlolan = (pokemon.isAlolan?)?"1":"0"
       @IsDelta = (pokemon.isDelta?)?"1":"0"
       @IsLegendary = "0"
       @Datastring = pokemon.to_s
       echo("\nFinished setting PDBData attributes")
  end
  
end