#===============================================================================
#  Command Choices
#  UI ovarhaul
#===============================================================================
class ChoiceWindowEBDX
  MAX_ROWS = 5

  attr_accessor :index
  attr_reader :over
  #-----------------------------------------------------------------------------
  #  initialize the choice boxes
  #-----------------------------------------------------------------------------
  def initialize(viewport,commands,scene)
    @commands = commands
    @shownCommands = commands
    if @shownCommands.length > MAX_ROWS
      @shownCommands = @shownCommands[0, MAX_ROWS]
    end
    @scene = scene
    @index = 0
    @shownIndex = 0
    offset = 0
    @path = "Graphics/EBDX/Pictures/UI/"
    @viewport = viewport
    @sprites = {}
    @visibility = [false,false,false,false]
    @baseColor = Color.white
    @shadowColor = Color.new(0,0,0,192)
    # apply styling from PBS
    self.applyMetrics
    # generate sprites
    @sprites["sel"] = SpriteSheet.new(@viewport,4)
    @sprites["sel"].setBitmap(pbSelBitmap(@path+@selImg,Rect.new(0,0,92,38)))
    @sprites["sel"].speed = 4
    @sprites["sel"].ox = @sprites["sel"].src_rect.width/2
    @sprites["sel"].oy = @sprites["sel"].src_rect.height/2
    @sprites["sel"].z = 99999
    @sprites["sel"].visible = false
    bmp = pbBitmap(@path+@btnImg)
    for i in 0...@shownCommands.length
      k = @shownCommands.length - 1 - i
      @sprites["choice#{i}"] = Sprite.new(@viewport)
      @sprites["choice#{i}"].x = Graphics.width - bmp.width - 14 + bmp.width/2
      @sprites["choice#{i}"].y = Graphics.height - 136 - k*(bmp.height+4) + bmp.height/2
      @sprites["choice#{i}"].z = 99998
      @sprites["choice#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      @sprites["choice#{i}"].center!
      @sprites["choice#{i}"].opacity = 0
      choice = @sprites["choice#{i}"].bitmap
      pbSetSystemFont(choice)
      choice.blt(0,0,bmp,bmp.rect)
      pbDrawOutlineText(choice,0,8,bmp.width,bmp.height,@commands[i],@baseColor,@shadowColor,1)
    end
    bmp.dispose
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
    arrow_x = @sprites["choice0"].x - (@sprites["uparrow"].framewidth / 2)
    @sprites["uparrow"].x = arrow_x
    @sprites["uparrow"].y = @sprites["choice0"].y - @sprites["choice0"].height
    @sprites["uparrow"].z = 99999
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
    @sprites["downarrow"].x = arrow_x
    @sprites["downarrow"].y = @sprites["choice#{@shownCommands.length - 1}"].y
    @sprites["downarrow"].z = 99999
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
  end
  #-----------------------------------------------------------------------------
  #  apply styling from PBS
  #-----------------------------------------------------------------------------
  def applyMetrics
    # sets default values
    @btnImg = "btnEmpty"
    @selImg = "cmdSel"
    # looks up next cached metrics first
    d1 = EliteBattle.get(:nextUI)
    d1 = d1[:CHOICE_MENU] if !d1.nil? && d1.has_key?(:CHOICE_MENU)
    # looks up globally defined settings
    d2 = EliteBattle.get_data(:CHOICE_MENU, :Metrics, :METRICS)
    # proceeds with parameter definition if available
    for data in [d2, d1]
      if !data.nil?
        # applies a set of predefined keys
        @btnImg = data[:BUTTONS] if data.has_key?(:BUTTONS) && data[:BUTTONS].is_a?(String)
        @selImg = data[:SELECTOR] if data.has_key?(:SELECTOR) && data[:SELECTOR].is_a?(String)
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  dispose of the sprites
  #-----------------------------------------------------------------------------
  def dispose(scene)
    @sprites["uparrow"].visible = false
    @sprites["downarrow"].visible = false
    2.times do
      @sprites["sel"].opacity -= 128
      for i in 0...@shownCommands.length
        @sprites["choice#{i}"].opacity -= 128
      end
      scene.animateScene(true)
      scene.pbGraphicsUpdate
    end
    pbDisposeSpriteHash(@sprites)
  end
  #-----------------------------------------------------------------------------
  #  update choice selection
  #-----------------------------------------------------------------------------
  def update
    @sprites["sel"].visible = true
    @sprites["sel"].x = @sprites["choice#{@shownIndex}"].x
    @sprites["sel"].y = @sprites["choice#{@shownIndex}"].y - 2
    @sprites["sel"].update
    if Input.trigger?(Input::UP)
      pbSEPlay("EBDX/SE_Select1")
      @index -= 1
      @index = @commands.length-1 if @index < 0
      if @shownIndex > 0
        @shownIndex -= 1
      else
        @shownIndex = @shownCommands.length - 1 if @index == @commands.length - 1
        refreshButtonText
      end
      @sprites["choice#{@shownIndex}"].src_rect.y -= 6
    elsif Input.trigger?(Input::DOWN)
      pbSEPlay("EBDX/SE_Select1")
      @index += 1
      @index = 0  if @index >= @commands.length
      if @shownIndex < @shownCommands.length - 1
        @shownIndex += 1
      else
        @shownIndex = 0 if @index == 0
        refreshButtonText
      end
      @sprites["choice#{@shownIndex}"].src_rect.y -= 6
    end
    for i in 0...@shownCommands.length
      @sprites["choice#{i}"].opacity += 128 if @sprites["choice#{i}"].opacity < 255
      @sprites["choice#{i}"].src_rect.y += 1 if @sprites["choice#{i}"].src_rect.y < 0
    end
    @sprites["uparrow"].visible = (@index - @shownIndex != 0)
    @sprites["uparrow"].update
    @sprites["downarrow"].visible = (@index - @shownIndex != @commands.length - @shownCommands.length)
    @sprites["downarrow"].update
  end
  def shiftMode=(val); end
  def refreshButtonText
    # fill sprites with text
    bmp = pbBitmap(@path+@btnImg)
    for i in 0...@shownCommands.length
      k = @shownCommands.length - 1 - i
      @sprites["choice#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      @sprites["choice#{i}"].opacity = 0
      choice = @sprites["choice#{i}"].bitmap
      pbSetSystemFont(choice)
      choice.blt(0,0,bmp,bmp.rect)
      pbDrawOutlineText(choice,0,8,bmp.width,bmp.height,@commands[i + (@index - @shownIndex)],@baseColor,@shadowColor,1)
    end
    bmp.dispose
  end
  #-----------------------------------------------------------------------------
end
