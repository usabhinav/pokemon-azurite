class CrystallizationRecorder
  attr_reader :selectedopt
  attr_reader :currentscreen
  attr_reader :pokemon
  
  def selectedopt=(value)
    @selectedopt=value
  end
  
  def currentscreen=(value)
    @currentscreen=value
  end
  
  def pokemon=(value)
    @selectedopt=value
  end
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def endScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
  def pbScene
    pokemonCodes = [
      [121, "123401111111"]
    ]
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @currentscreen==0
        if Input.trigger?(Input::DOWN) && @selectedopt==0
        elsif Input.trigger?(Input::DOWN) && @selectedopt==4
          @selectedopt=1
        elsif Input.trigger?(Input::DOWN)
          @selectedopt+=1
        end
        if Input.trigger?(Input::UP) && @selectedopt==0
        elsif Input.trigger?(Input::UP) && @selectedopt==1
          @selectedopt=4
        elsif Input.trigger?(Input::UP)
          @selectedopt-=1
        end
        if Input.trigger?(Input::LEFT) && (@selectedopt != 0)
          @selectedopt=0
        end
        if Input.trigger?(Input::RIGHT) && (@selectedopt == 0)
          @selectedopt=1
        end
        if Input.trigger?(Input::B)
          break
        end
        if Input.trigger?(Input::C)
          if @selectedopt==0
            echo("The Most Recent Pokemon thing is selected")
          elsif @selectedopt==1
            echo("The Crystal Pokemon option is selected")
          elsif @selectedopt==2
            echo("The Search option was selected")
          elsif @selectedopt==3
            @currentscreen=1
            @sequence=""
            @sprites["background"]=IconSprite.new(0,0,@viewport)
            @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
            @sprites["pokemon"].visible=false
            @sprites["b1"]=IconSprite.new(250,120,@viewport)
            @sprites["b2"]=IconSprite.new(250,180,@viewport)
            @sprites["b3"]=IconSprite.new(250,240,@viewport)
            @sprites["b4"]=IconSprite.new(250,300,@viewport)
            @sprites["b5"]=IconSprite.new(20,20,@viewport)
            @sprites["logo"]=IconSprite.new(250, 30, @viewport)
            @sprites["c1"]=IconSprite.new(20,200,@viewport)
            @sprites["c2"]=IconSprite.new(60,200,@viewport)
            @sprites["c3"]=IconSprite.new(100,200,@viewport)
            @sprites["c4"]=IconSprite.new(140,200,@viewport)
            @sprites["c5"]=IconSprite.new(180,200,@viewport)
            @sprites["c6"]=IconSprite.new(220,200,@viewport)
            @sprites["c7"]=IconSprite.new(260,200,@viewport)
            @sprites["c8"]=IconSprite.new(300,200,@viewport)
            @sprites["c9"]=IconSprite.new(340,200,@viewport)
            @sprites["c10"]=IconSprite.new(380,200,@viewport)
            @sprites["c11"]=IconSprite.new(420,200,@viewport)
            @sprites["c12"]=IconSprite.new(460,200,@viewport)
            echo("The Add Recording Option was selected")
          elsif @selectedopt==4
            break
          end
        end
      elsif @currentscreen==1
        if @sequence.length==12
          for i in pokemonCodes
            if (i[1]==@sequence) && !$Trainer.seenCrystallization?(i[0])
              $Trainer.crystallizations.push(i[0])
              echo("New Pokemon now usable")
            elsif (i[1]==@sequence) && $Trainer.seenCrystallization?(i[0])
              echo("Pokemon already usable")
            else
              echo("Incorrect code")
            end
          end
          @sequence=""
        end
        if Input.trigger?(Input::DOWN)
          echo("2")
          @sequence+="2"
        end
        if Input.trigger?(Input::UP)
          echo("1")
          @sequence+="1"
        end
        if Input.trigger?(Input::LEFT) 
          echo("3")
          @sequence+="3"
        end
        if Input.trigger?(Input::RIGHT) 
          echo("4")
          @sequence+="4"
        end
        if Input.trigger?(Input::C)
          echo("0")
          @sequence+="0"
        end
        if Input.trigger?(Input::B)
          @currentscreen=0
          @sequence=""
          @sprites["background"]=IconSprite.new(0,0,@viewport)
          @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
          @sprites["pokemon"].visible=true
          @sprites["b1"]=IconSprite.new(250,120,@viewport)
          @sprites["b2"]=IconSprite.new(250,180,@viewport)
          @sprites["b3"]=IconSprite.new(250,240,@viewport)
          @sprites["b4"]=IconSprite.new(250,300,@viewport)
          @sprites["b5"]=IconSprite.new(20,20,@viewport)
          @sprites["logo"]=IconSprite.new(250, 30, @viewport)
          @sprites["c1"]=IconSprite.new(20,200,@viewport)
          @sprites["c2"]=IconSprite.new(60,200,@viewport)
          @sprites["c3"]=IconSprite.new(100,200,@viewport)
          @sprites["c4"]=IconSprite.new(140,200,@viewport)
          @sprites["c5"]=IconSprite.new(180,200,@viewport)
          @sprites["c6"]=IconSprite.new(220,200,@viewport)
          @sprites["c7"]=IconSprite.new(260,200,@viewport)
          @sprites["c8"]=IconSprite.new(300,200,@viewport)
          @sprites["c9"]=IconSprite.new(340,200,@viewport)
          @sprites["c10"]=IconSprite.new(380,200,@viewport)
          @sprites["c11"]=IconSprite.new(420,200,@viewport)
          @sprites["c12"]=IconSprite.new(460,200,@viewport)
        end
      end
      if @currentscreen==0
        drawMainMenu(pokemon)
      elsif @currentscreen==1
        drawAddCrystal
      end
    end
    endScene
    Input.update
    Graphics.update
    return true
  end

  def pbStartScene(party,partyindex)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @party=party
    @partyindex=partyindex
    @pokemon=@party[@partyindex]
    @selectedopt=0
    @currentscreen=0
    @sprites={}
    @sequence=""
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["pokemon"]=IconSprite.new(60,130,@viewport)
    @sprites["pokemon"].z=30
    @sprites["b1"]=IconSprite.new(250,120,@viewport)
    @sprites["b2"]=IconSprite.new(250,180,@viewport)
    @sprites["b3"]=IconSprite.new(250,240,@viewport)
    @sprites["b4"]=IconSprite.new(250,300,@viewport)
    @sprites["b5"]=IconSprite.new(20,20,@viewport)
    @sprites["logo"]=IconSprite.new(250, 30, @viewport)
    @sprites["c1"]=IconSprite.new(20,200,@viewport)
    @sprites["c2"]=IconSprite.new(60,200,@viewport)
    @sprites["c3"]=IconSprite.new(100,200,@viewport)
    @sprites["c4"]=IconSprite.new(140,200,@viewport)
    @sprites["c5"]=IconSprite.new(180,200,@viewport)
    @sprites["c6"]=IconSprite.new(220,200,@viewport)
    @sprites["c6"]=IconSprite.new(220,200,@viewport)
    @sprites["c7"]=IconSprite.new(260,200,@viewport)
    @sprites["c8"]=IconSprite.new(300,200,@viewport)
    @sprites["c9"]=IconSprite.new(340,200,@viewport)
    @sprites["c10"]=IconSprite.new(380,200,@viewport)
    @sprites["c11"]=IconSprite.new(420,200,@viewport)
    @sprites["c12"]=IconSprite.new(460,200,@viewport)
    
    drawMainMenu(pokemon)
    pbFadeInAndShow(@sprites) { pbUpdate }
    pbScene
  end
  
  def drawMainMenu(pokemon)
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/CrystalRecorder/CR_background")
    @sprites["logo"].setBitmap("Graphics/Pictures/CrystalRecorder/CR_logo")
    @sprites["pokemon"].setBitmap("Graphics/Pictures/CrystalRecorder/Sprites/Placeholder")
    @sprites["b1"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_CrysPKMN_norm")
    @sprites["b2"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_search_norm")
    @sprites["b3"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_custom_norm")
    @sprites["b4"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_shutoff_norm")
    @sprites["b5"].setBitmap("Graphics/Pictures/CrystalRecorder/CRbutton_Recent_norm")
    case @selectedopt
    when 0; @sprites["b5"].setBitmap("Graphics/Pictures/CrystalRecorder/CRbutton_Recent_hover")
    when 1; @sprites["b1"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_CrysPKMN_hover")
    when 2; @sprites["b2"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_search_hover")
    when 3; @sprites["b3"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_custom_hover")
    when 4; @sprites["b4"].setBitmap("Graphics/Pictures/CrystalRecorder/CRButton_shutoff_hover")
    end
    @sprites["b5"].z=1
  end
  
  def drawAddCrystal
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    @sprites["background"].setBitmap("Graphics/Pictures/CrystalRecorder/CR_background")
    @sprites["c1"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c2"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c3"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c4"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c5"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c6"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c7"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c8"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c9"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c10"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c11"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    @sprites["c12"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
    varrand=1
    @sequence.split("").each do |i|
      if i=="0"
        @sprites["c#{varrand}"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqOFF")
      elsif i=="1"
        @sprites["c#{varrand}"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqUP")
      elsif i=="2"
        @sprites["c#{varrand}"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqDOWN")
      elsif i=="3"
        @sprites["c#{varrand}"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqLEFT")
      elsif i=="4"
        @sprites["c#{varrand}"].setBitmap("Graphics/Pictures/CrystalRecorder/FreqRIGHT")
      end
      varrand+=1
    end
  end
end