begin
  module PBEffects
    #===========================================================================
    # These effects apply to a battler
    #===========================================================================
    AquaRing            = 0
    Attract             = 1
    BanefulBunker       = 2
    BeakBlast           = 3
    Bide                = 4
    BideDamage          = 5
    BideTarget          = 6
    BurnUp              = 7
    Charge              = 8
    ChoiceBand          = 9
    Confusion           = 10
    Counter             = 11
    CounterTarget       = 12
    Curse               = 13
    Dancer              = 14
    DefenseCurl         = 15
    DestinyBond         = 16
    DestinyBondPrevious = 17
    DestinyBondTarget   = 18
    Disable             = 19
    DisableMove         = 20
    Electrify           = 21
    Embargo             = 22
    Encore              = 23
    EncoreMove          = 24
    Endure              = 25
    FirstPledge         = 26
    FlashFire           = 27
    Flinch              = 28
    FocusEnergy         = 29
    FocusPunch          = 30
    FollowMe            = 31
    Foresight           = 32
    FuryCutter          = 33
    GastroAcid          = 34
    GemConsumed         = 35
    Grudge              = 36
	  GreatShield		    	= 37
    HealBlock           = 38
    HelpingHand         = 39
    HyperBeam           = 40
    Illusion            = 41
    Imprison            = 42
    Ingrain             = 43
    Instruct            = 44
    Instructed          = 45
    KingsShield         = 46
    LaserFocus          = 47
    LeechSeed           = 48
    LockOn              = 49
    LockOnPos           = 50
    MagicBounce         = 51
    MagicCoat           = 52
    MagnetRise          = 53
    MeanLook            = 54
    MeFirst             = 55
    Metronome           = 56
    MicleBerry          = 57
    Minimize            = 58
    MiracleEye          = 59
    MirrorCoat          = 60
    MirrorCoatTarget    = 61
    MoveNext            = 62
    MudSport            = 63
    Nightmare           = 64
    Outrage             = 65
    ParentalBond        = 66
    PerishSong          = 67
    PerishSongUser      = 68
    PickupItem          = 69
    PickupUse           = 70
    Pinch               = 71   # Battle Palace only
    Powder              = 72
    PowerTrick          = 73
    Prankster           = 74
    PriorityAbility     = 75
    PriorityItem        = 76
    Protect             = 77
    ProtectRate         = 78
    Pursuit             = 79
    Quash               = 80
    Rage                = 81
    RagePowder          = 82   # Used along with FollowMe
    Rollout             = 83
    Roost               = 84
    ShellTrap           = 85
    SkyDrop             = 86
    SlowStart           = 87
    SmackDown           = 88
    Snatch              = 89
    SpikyShield         = 90
    Spotlight           = 91
    Stockpile           = 92
    StockpileDef        = 93
    StockpileSpDef      = 94
    Substitute          = 95
    Taunt               = 96
    Telekinesis         = 97
    ThroatChop          = 98
    Torment             = 99
    Toxic               = 100
    Transform           = 101
    TransformSpecies    = 102
    Trapping            = 103   # Trapping move
    TrappingMove        = 104
    TrappingUser        = 105
    Truant              = 106
    TwoTurnAttack       = 107
    Type3               = 108
    Unburden            = 109
    Uproar              = 110
    WaterSport          = 111
    WeightChange        = 112
    Yawn                = 113
    ShedBody            = 114
    ReverbDamage        = 115
    BlastUsers          = 116
    CrystalAdaptation   = 117
    TypeModsI           = 118
    HungryItems         = 119
    VictoryRush         = 120
    Stare               = 121
    DynamicPower        = 122
    Incomprehensible    = 123
    SelfInflictedConfusion = 124
    SpikesArmor         = 125
    ToxicSpikesArmor    = 126
    StealthRockArmor    = 127
    VoltSpikesArmor     = 128
    CounterParry        = 129
    Overcharged         = 130
    RevengeBelt         = 131
    SubtractionTypes    = 132

    #===========================================================================
    # These effects apply to a battler position
    #===========================================================================
    FutureSightCounter        = 0
    FutureSightMove           = 1
    FutureSightUserIndex      = 2
    FutureSightUserPartyIndex = 3
    HealingWish               = 4
    LunarDance                = 5
    Wish                      = 6
    WishAmount                = 7
    WishMaker                 = 8

    #===========================================================================
    # These effects apply to a side
    #===========================================================================
    AuroraVeil         = 0
    CraftyShield       = 1
    EchoedVoiceCounter = 2
    EchoedVoiceUsed    = 3
    LastRoundFainted   = 4
    LightScreen        = 5
    LuckyChant         = 6
    MatBlock           = 7
    Mist               = 8
    QuickGuard         = 9
    Rainbow            = 10
    Reflect            = 11
    Round              = 12
    Safeguard          = 13
    SeaOfFire          = 14
    Spikes             = 15
    StealthRock        = 16
    StickyWeb          = 17
    Swamp              = 18
    Tailwind           = 19
    ToxicSpikes        = 20
    WideGuard          = 21
    VoltSpikes         = 22

    #===========================================================================
    # These effects apply to the battle (i.e. both sides)
    #===========================================================================
    AmuletCoin      = 0
    FairyLock       = 1
    FusionBolt      = 2
    FusionFlare     = 3
    Gravity         = 4
    HappyHour       = 5
    IonDeluge       = 6
    MagicRoom       = 7
    MudSportField   = 8
    PayDay          = 9
    TrickRoom       = 10
    WaterSportField = 11
    WonderRoom      = 12
    Darkened        = 13
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
