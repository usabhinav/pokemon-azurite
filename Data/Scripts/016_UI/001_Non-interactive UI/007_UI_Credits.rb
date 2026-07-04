#==============================================================================
# * Scene_Credits
#------------------------------------------------------------------------------
# Scrolls the credits you make below. Original Author unknown.
#
## Edited by MiDas Mike so it doesn't play over the Title, but runs by calling
# the following:
#    $scene = Scene_Credits.new
#
## New Edit 3/6/2007 11:14 PM by AvatarMonkeyKirby.
# Ok, what I've done is changed the part of the script that was supposed to make
# the credits automatically end so that way they actually end! Yes, they will
# actually end when the credits are finished! So, that will make the people you
# should give credit to now is: Unknown, MiDas Mike, and AvatarMonkeyKirby.
#                                             -sincerly yours,
#                                               Your Beloved
# Oh yea, and I also added a line of code that fades out the BGM so it fades
# sooner and smoother.
#
## New Edit 24/1/2012 by Maruno.
# Added the ability to split a line into two halves with <s>, with each half
# aligned towards the centre. Please also credit me if used.
#
## New Edit 22/2/2012 by Maruno.
# Credits now scroll properly when played with a zoom factor of 0.5. Music can
# now be defined. Credits can't be skipped during their first play.
#
## New Edit 25/3/2020 by Maruno.
# Scroll speed is now independent of frame rate. Now supports non-integer values
# for SCROLL_SPEED.
#
## New Edit 21/8/2020 by Marin.
# Now automatically inserts the credits from the plugins that have been
# registered through the PluginManager module.
#==============================================================================
class Scene_Credits
  # Backgrounds to show in credits. Found in Graphics/Titles/ folder
  BACKGROUNDS_LIST       = ["credits1", "credits2", "credits3", "credits4", "credits5"]
  BGM                    = "Credits"
  SCROLL_SPEED           = 40   # Pixels per second
  SECONDS_PER_BACKGROUND = 11
  TEXT_OUTLINE_COLOR     = Color.new(0, 0, 128, 255)
  TEXT_BASE_COLOR        = Color.new(255, 255, 255, 255)
  TEXT_SHADOW_COLOR      = Color.new(0, 0, 0, 100)

  # This next piece of code is the credits.
  # Start Editing
  CREDIT = <<_END_

Pokémon Azurite was created by these active team members:

SleepyJirachi (Project Lead)
NettoHikari (Programmer)
Baustein (Programmer)
JPA93 (Mapper, Tech Writer)
GioBasaran (Concept Artist)
Speed King (Sprite Artist)
Selena (Animator)
Apawn (Sprite Artist)
Dusky (Sprite Artist)
Arin Wolfe (Sprite Artist)

With major contributions from previous team members:

Suzerain (Programmer)
Baaabuuu (Programmer)
Eddie Hartman (Programmer)
Thundamoo (Programmer)
Dream (Programmer)
Ed (Programmer)
Acrylica (Programmer)
Zeak6464 (Programmer)
Shadow_Sear (Programmer, Creator of Sloof's cry sound)
Jbsundown (Programmer)
Mjwherry (Online Component Programmer)
SquirrelOfDeath (Online Component Programmer)
Doctor Planky (Online Component Programmer)

Aqua'DeStrhom (Sprite Artist)
Kort (Artist)
Heltuh / Ulti (Artist)
Celine (Concept Artist)
Kuroryushin (Concept Artist)
Tommi (Sprite Artist, Concept Artist)
StuffDraws (Artist)
Phantomicon (Concept Artist, Promo Artist)
Kyepha (Concept Artist, Final Artist)
Inkedsplat (Animator)
Sam the Starman (Sprite Artist, Tileset Artist)
Aniebodie (Sprite Artist, Animator)
Seb (Sprite Artist)
Dream (JustDreamo) (Final Artist)
Hanna (Concept Artist, Animator)
Creme (Sprite Artist, Animator)
Soulja (Concept Artist, Sprite Artist)
Cowctus (Artist, Project Co-Lead)
Wereweasel (Concept Artist)
Apriifox (Concept Artist, Digital Artist)
Mysterykarp (Sprite Artist)
Earl Danger (Sprite Artist)
Majinmind (Lead Artist)
Andre Rivera (Sprite Artist)
Grey-winged Blitz (Traditional Artist)
Unstableye (Concept Artist)
Breioom (Sprite Artist)
Nikki (Concept Artist)
Zchem (Programmer, Artist)
Pedro J.M. (Logo Designer)

Emdasche (Remixer)
Kamex (Remixer, Musician)
TheGuitahHeroe (Musician)
Futo (Musician)
RainbowTuba (Musician)
KelyxTheMage (Musician)
EternalSushi (Musician)
Draskon5665 (Musician)
Darius (Musician)

And additional third-party resources from the following:

Stat Up/Down Animation (graphics only)
KleinStudio

Transform Mosaic Animation
KleinStudio
NettoHikari (ported to EBDX on Essentials v20.1)

Lavender Town Ghosts For PE V17.2
Richard PT

Custom Egg sprites for all species up to gen 8
Reborn & Rejuvenation Developer Teams - The graphics themselves
Appletun's Apples - Updating the egg sprites to work for V19
LMicolash - The icon sprites

Animated Pokemon System [DBK Add-On] [v21.1] (graphics only)
Creator: Lucidious89
Based on the Generation 8 Pack by Golisopod User and EBDX by Luka S.J.
Battler Sprites:
Gen 1-5: Luka S.J.
Gen 6: All Contributors To Smogon X/Y Sprite Project
Gen 7: All Contributors To Smogon Sun/Moon Sprite Project
Gen 8: All Contributors To Smogon Sword/Shield Sprite Project
Gen 9: All Contributors To Smogon Scarlet/Violet Sprite Project
Contributors to the original "Sprites Animados" spanish plugin:
Tenshi of War<s>DPertierra
Skyflyer<s>Hellfire_raptor
Antiant<s>AshnixsLaw
AyanoCloud<s>Azrita
BR0DE0<s>Caruban
Creobnil<s>DanEx
Diegotoon20<s>dimbly
ekurepu<s>Ebaru
EricLostie<s>Falcon7
Federico97_ez<s>Fleimer_
Franark122k<s>Hellfire0raptor
HM100<s>HyperactiveFlummi
iametrine<s>Involuntary-Twitch
ItsYugen<s>jinta
justnyxnow<s>KingOfThe-X-Roads
kiriaura<s>Legitimate Username
localghost<s>lucasomi
MallowOut<s>mangalos810
MCH4R1Z4RD<s>N-Kin
NoelleMBrooks<s>Noobiess
Nolo33<s>OldSoulja
OmegalingYT<s>PKMarioG
PomPomKing<s>Poki Papillon
PumpkinPastel<s>RetroNC
RadicalCharizard<s>seleccion
SelenaArmorclaw<s>SkidMarc25
Snivy101<s>Sopita_Yorita
SoulWardenInfinity<s>TheAetherPlayer
TheCynicalPoet<s>Typhlito
uppababy
Other Contributors:
Lucidious89<s>Regis
Rod<s>kayzering
Icon Sprites:
Gen 1-6:
Alaguesia
harveydentmd
Gen 7:
Marin
MapleBranchWing
Contributors to the DS Styled Gen 7+ Repository
Gen 8:
Larry Turbo
Leparagon
Gen 1-8 (Shiny):
StarrWolf
Pokemon Shattered Light Team
PLA Icons:
LuigiTKO
Gen 9:
ezerart
JordanosArt
Resource Compilation:
Golisopod User
UberDunsparce
Caruban
Footprint Sprites:
Gen 6:
Bhagya Jyoti
Gen 7-8:
WolfPP
Gen 9 & PLA:
Caruban
Resource Compilation:
komeiji514

Marin's Enhanced Jukebox (OggDecoder code only)
Marin

Stopwatch sound effect (used in the Time Break move's animation)
JoJo's Bizarre Adventure

Misc. third-party scripts:

Zeak6464<s>Tapu Fini
SpartaLazor<s>leparagon
BlackOutG5<s>Rune
M3rein<s>Rigbycwts
Rot8er_ConeX<s>James Davy
Luka S.J.<s>Marin

Misc. third-party sprites:

Magiscarf<s>gavzxhayley
Marcosik1992<s>thepokemonchronicles
pixelmister<s>seraimizu
wesleyfg<s>nosblaidenaidd
manuxd789<s>rayd12smitty
kyle dove<s>sabfrompc
phyromatical<s>xdinky
mr duke<s>chaoticcherrycake
moontik<s>hekelgrande
zetavares852<s>flurmimon
thunderdove<s>brendan77
warpras<s>peekychew
lapampa fr<s>alucus
scarex3wer<s>ultimospriter
alphacerz<s>mysticalmew24
calzipher<s>war8
devevollina<s>midnitez-remix
babydialga<s>zeo254
kaliser<s>space emotion
malice936<s>erma96
blackdragonredroses<s>harveythecreator
jinuxs<s>novus
the english kiwi<s>caliprojects.com
princelegendario<s>epicday
dewitty<s>kagenosensei
lightbulb15<s>gallanty
manuxd789<s>shawn frost
matwert<s>zekrowah
27alexmad27<s>Amethyst
Jan<s>Zumi
Bazaro<s>Koyo
Smeargletail<s>Alex
Noscium<s>Lepagon
N-kin<s>fishbowlsoul90
princess-phoenix<s>DatLopunnyTho
Conyjams<s>kaji atsu 
The cynical poet<s>LuigiPlayer
Pikafan2000<s>Lord-Myre
piphybuilder88<s>ThePurplest
carchagui<s>KingTapir
PkmnAlexandrite<s>Flurmimon
Phyromatical<s>Gogoat1
RedEx<s>SailorVicious
Falgaia of the Smogon S/M sprite project

Misc. third-party sound effects:

Rhyden
Random Talking Bush

A-Exeggutor Fix/Multiple Dex Forms scripts
Marcello

{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE}

"Pokémon Essentials" was created by:
Flameguru
Poccil (Peter O.)
Maruno

With contributions from:
AvatarMonkeyKirby<s>Marin
Boushy<s>MiDas Mike
Brother1440<s>Near Fantastica
FL.<s>PinkMan
Genzai Kawakami<s>Popper
Golisopod User<s>Rataime
help-14<s>Savordez
IceGod64<s>SoundSpawn
Jacob O. Wobbrock<s>the__end
KitsuneKouta<s>Venom12
Lisa Anthony<s>Wachunga
Luka S.J.<s>
and everyone else who helped out

"mkxp-z" by:
Roza
Based on "mkxp" by Ancurio et al.

"RPG Maker XP" by:
Enterbrain

Pokémon is owned by:
The Pokémon Company
Nintendo
Affiliated with Game Freak



This is a non-profit fan-made game.
No copyright infringements intended.
Please support the official games!

_END_
# Stop Editing

  def main
    #-------------------------------
    # Animated Background Setup
    #-------------------------------
    @counter = 0.0   # Counts time elapsed since the background image changed
    @bg_index = 0
    @bitmap_height = Graphics.height   # For a single credits text bitmap
    @trim = Graphics.height / 10
    # Number of game frames per background frame
    @realOY = -(Graphics.height - @trim)
    #-------------------------------
    # Credits text Setup
    #-------------------------------
    plugin_credits = ""
    PluginManager.plugins.each do |plugin|
      pcred = PluginManager.credits(plugin)
      plugin_credits << "\"#{plugin}\" v.#{PluginManager.version(plugin)} by:\n"
      if pcred.size >= 5
        plugin_credits << (pcred[0] + "\n")
        i = 1
        until i >= pcred.size
          plugin_credits << (pcred[i] + "<s>" + (pcred[i + 1] || "") + "\n")
          i += 2
        end
      else
        pcred.each { |name| plugin_credits << (name + "\n") }
      end
      plugin_credits << "\n"
    end
    CREDIT.gsub!(/\{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE\}/, plugin_credits)
    credit_lines = CREDIT.split(/\n/)
    #-------------------------------
    # Make background and text sprites
    #-------------------------------
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    text_viewport = Viewport.new(0, @trim, Graphics.width, Graphics.height - (@trim * 2))
    text_viewport.z = 99999
    @background_sprite = IconSprite.new(0, 0, viewport)
    @background_sprite.setBitmap("Graphics/Titles/" + BACKGROUNDS_LIST[0])
    @credit_sprites = []
    @total_height = credit_lines.size * 32
    lines_per_bitmap = @bitmap_height / 32
    num_bitmaps = (credit_lines.size.to_f / lines_per_bitmap).ceil
    num_bitmaps.times do |i|
      credit_bitmap = Bitmap.new(Graphics.width, @bitmap_height + 16)
      pbSetSystemFont(credit_bitmap)
      lines_per_bitmap.times do |j|
        line = credit_lines[(i * lines_per_bitmap) + j]
        next if !line
        line = line.split("<s>")
        xpos = 0
        align = 1   # Centre align
        linewidth = Graphics.width
        line.length.times do |k|
          if line.length > 1
            xpos = (k == 0) ? 0 : 20 + (Graphics.width / 2)
            align = (k == 0) ? 2 : 0   # Right align : left align
            linewidth = (Graphics.width / 2) - 20
          end
          credit_bitmap.font.color = TEXT_SHADOW_COLOR
          credit_bitmap.draw_text(xpos, (j * 32) + 12, linewidth, 32, line[k], align)
          credit_bitmap.font.color = TEXT_OUTLINE_COLOR
          credit_bitmap.draw_text(xpos + 2, (j * 32) + 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos,     (j * 32) + 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, (j * 32) + 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos + 2, (j * 32) + 4, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, (j * 32) + 4, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos + 2, (j * 32) + 6, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos,     (j * 32) + 6, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, (j * 32) + 6, linewidth, 32, line[k], align)
          credit_bitmap.font.color = TEXT_BASE_COLOR
          credit_bitmap.draw_text(xpos, (j * 32) + 4, linewidth, 32, line[k], align)
        end
      end
      credit_sprite = Sprite.new(text_viewport)
      credit_sprite.bitmap = credit_bitmap
      credit_sprite.z      = 9998
      credit_sprite.oy     = @realOY - (@bitmap_height * i)
      @credit_sprites[i] = credit_sprite
    end
    #-------------------------------
    # Setup
    #-------------------------------
    # Stops all audio but background music
    previousBGM = $game_system.getPlayingBGM
    pbMEStop
    pbBGSStop
    pbSEStop
    pbBGMFade(2.0)
    pbBGMPlay(BGM)
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    pbBGMFade(2.0)
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    Graphics.freeze
    viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
    Graphics.transition(8, "fadetoblack")
    $game_temp.background_bitmap.dispose
    @background_sprite.dispose
    @credit_sprites.each { |s| s&.dispose }
    text_viewport.dispose
    viewport.dispose
    $PokemonGlobal.creditsPlayed = true
    pbBGMPlay(previousBGM)
  end

  # Check if the credits should be cancelled
  def cancel?
    if Input.trigger?(Input::USE) && $PokemonGlobal.creditsPlayed
      $scene = Scene_Map.new
      pbBGMFade(1.0)
      return true
    end
    return false
  end

  # Checks if credits bitmap has reached its ending point
  def last?
    if @realOY > @total_height + @trim
      $scene = ($game_map) ? Scene_Map.new : nil
      pbBGMFade(2.0)
      return true
    end
    return false
  end

  def update
    delta = Graphics.delta_s
    @counter += delta
    # Go to next slide
    if @counter >= SECONDS_PER_BACKGROUND
      @counter -= SECONDS_PER_BACKGROUND
      @bg_index += 1
      @bg_index = 0 if @bg_index >= BACKGROUNDS_LIST.length
      @background_sprite.setBitmap("Graphics/Titles/" + BACKGROUNDS_LIST[@bg_index])
    end
    return if cancel?
    return if last?
    @realOY += SCROLL_SPEED * delta
    @credit_sprites.each_with_index { |s, i| s.oy = @realOY - (@bitmap_height * i) }
  end
end

def pbStartCredits
  pbFadeOutIn {
    # Fade to game map to avoid any random issues related to game map not being initialized or something
    old_scene = $scene
    # Start credits
    $scene = Scene_Credits.new
    $scene.main
    # Fade back to this screen
    $scene = old_scene
  }
end

def pbStartCreditsFromTitleScreen
  pbFadeOutIn {
    # Fade to game map to avoid any random issues related to game map not being initialized or something
    old_scene = $scene
    # Just using :CUSTOM_BATTLE_MODE as the catch-all for whenever we need to briefly go into the game map
    $game_temp.game_mode_type = :CUSTOM_BATTLE_MODE
    Game.start_new
    # Start credits
    $scene = Scene_Credits.new
    $scene.main
    SaveData.mark_values_as_unloaded
    # Fade back to this screen
    $scene = old_scene
  }
end
