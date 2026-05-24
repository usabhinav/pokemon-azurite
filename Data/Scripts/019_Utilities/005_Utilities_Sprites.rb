class ScrollingTextSprite < BitmapSprite
  attr_reader   :text
  attr_accessor :maxlines
  attr_accessor :base
  attr_accessor :shadow
  attr_accessor :draw_method
  
  def initialize(width, height, viewport = nil)
    super(width, height, viewport)
    reset_text_timer
  end

  def update
    super
    return if @text.nil?
    @timer += 1
    calculated_y = 0
    # Hardcoded wait time of 1.5 seconds for now
    initial_wait_frames = Graphics.frame_rate * 1.5
    if @timer >= initial_wait_frames
      effective_timer = @timer - initial_wait_frames
      # Hardcoded speed of 1 pixel every 2 frames (20px per second) for now
      y_diff = effective_timer / 2
      y_diff = [y_diff, @max_y_diff].min
      calculated_y = -y_diff
    end
    # Hardcoded wait time of 3 seconds for now
    final_wait_frames = Graphics.frame_rate * 3
    max_effective_timer = initial_wait_frames + (@max_y_diff * 2) # Hardcoded speed
    # Restart scroll from top
    if @timer >= max_effective_timer + final_wait_frames
      calculated_y = 0
      reset_text_timer
    end
    if @current_y != calculated_y
      self.bitmap.clear
      if @draw_method == "drawFormattedTextEx"
        new_chars = @chars.map {|char| new_char = char.dup; new_char[2] += calculated_y; new_char }
        new_chars = new_chars.filter {|char| char[2] > -32 && char[2] < @maxlines * 32 }
        drawFormattedChars(bitmap, new_chars)
      else
        drawTextEx(self.bitmap, 0, calculated_y, self.bitmap.width, 99,   # overlay, x, y, width, num lines
                  @text, @base, @shadow)
      end
      @current_y = calculated_y
    end
  end

  def text=(value)
    @text = value
    if @text.nil?
      @max_y_diff = 0
    else
      if @draw_method == "drawFormattedTextEx"
        @chars = getFormattedTextChars(self.bitmap, 0, 2, self.bitmap.width, @text, @base, @shadow)
        @max_y_diff = [(@chars.last[2] - (@maxlines - 1) * 32), 0].max
      else
        normtext = getLineBrokenChunks(self.bitmap, @text, self.bitmap.width, nil)
        @max_y_diff = [(normtext.last[2] - (@maxlines - 1) * 32), 0].max
      end
    end
    reset_text_timer
  end

  def reset_text_timer
    @timer = 0
    @current_y = nil
  end
end

#===============================================================================
#
#===============================================================================
# Represents a window with no formatting capabilities. Its text color can be set,
# though, and line breaks are supported, but the text is generally unformatted.
# The text scrolls if it exceeds the max lines allowed.
class Window_UnformattedScrollingTextPokemon < Window_UnformattedTextPokemon
  attr_accessor :scrolling_text_sprite

  def text=(value)
    @scrolling_text_sprite&.text = value.gsub(/\r/, "")
    super
  end

  def baseColor=(value)
    @scrolling_text_sprite&.base = value
    super
  end

  def shadowColor=(value)
    @scrolling_text_sprite&.shadow = value
    super
  end

  def self.newWithSize(text, x, y, width, height, maxlines, baseColor, shadowColor, viewport = nil)
    ret = super(text, x, y, width, height, viewport)
    ret.scrolling_text_sprite = ScrollingTextSprite.new(width - ret.borderX - SpriteWindow_Base::TEXTPADDING, height - ret.borderY, viewport)
    pbSetSystemFont(ret.scrolling_text_sprite.bitmap)
    ret.scrolling_text_sprite.x = x + ret.startX
    ret.scrolling_text_sprite.y = y + ret.startY + 6
    ret.scrolling_text_sprite.maxlines = maxlines
    ret.scrolling_text_sprite.base = baseColor
    ret.scrolling_text_sprite.shadow = shadowColor
    ret.scrolling_text_sprite.text = text
    return ret
  end

  def refresh
  end

  def refreshWithoutLineBreaks
  end

  def update
    @scrolling_text_sprite&.update
  end

  def visible=(visible)
    super
    @scrolling_text_sprite&.visible = visible
  end

  def color=(color)
    super
    @scrolling_text_sprite&.color = color
  end
end

class PokemonPartyIconSprites
  def initialize(viewport = nil, party = nil, x = nil, y = nil, disable_anim = true)
    # Bitmap sprite setup
    if viewport
      @viewport = viewport
    else
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @viewport.visible = true
    end
    @party = party
    @x = x
    @y = y
    @disable_anim = disable_anim
    @sprites = {}
    refreshPokemonIconSprites
    @bitmapsprite = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    bitmap = @bitmapsprite.bitmap
    pbSetSmallFont(bitmap)
    @bitmapsprite.visible = true
    @bitmapsprite.opacity = 0
  end

  def party=(party)
    @party = party
    refreshPokemonIconSprites
  end

  def refreshPokemonIconSprites
    for i in 0...6
      refreshPokemonAtIndex(i)
    end
  end

  def refreshPokemonAtIndex(i)
    if @party && @party[i]
      poke = @party[i]
      if @sprites["pokemonIcon#{i}"].nil?
        icon_sprite = PokemonIconSprite.new(poke, @viewport)
        icon_sprite.setOffset(PictureOrigin::CENTER)
        icon_sprite.x = @x + 32 + (i % 2 == 0 ? 0 : 64)
        icon_sprite.y = @y + 32 + (i / 2) * 64
        icon_sprite.z = 2
        icon_sprite.disable_anim = @disable_anim
        icon_sprite.update
        @sprites["pokemonIcon#{i}"] = icon_sprite
      else
        @sprites["pokemonIcon#{i}"].pokemon = poke
      end
    elsif !@sprites["pokemonIcon#{i}"].nil?
      @sprites["pokemonIcon#{i}"].visible = false
      @sprites["pokemonIcon#{i}"].dispose
      @sprites["pokemonIcon#{i}"] = nil
    end
  end

  def disposed?
    return @bitmapsprite.disposed?
  end
  
  def dispose
    @bitmapsprite.dispose if @bitmapsprite
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def visible
    return @bitmapsprite.visible
  end

  def visible=(visible)
    @bitmapsprite.visible = visible
    @sprites.each_value do |s|
      next if s.nil?
      s.visible = visible
    end
  end

  def color
    return @bitmapsprite.color
  end

  def color=(color)
    @bitmapsprite.color = color
    @sprites.each_value do |s|
      next if s.nil?
      s.color = color
    end
  end
end

class GenericTextWindow
  def initialize(name, viewport = nil)
    @window = Window_AdvancedTextPokemon.new(name)
    @window.resizeToFit(name, Graphics.width)
    @window.x        = Graphics.width - @window.width
    @window.y        = -@window.height
    if viewport
      @window.viewport = viewport
    else
      @window.viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @window.viewport.z = 99999
    end
    @frames = 0
  end

  def disposed?
    @window.disposed?
  end

  def dispose
    @window.dispose
  end

  def update
    return if @window.disposed?
    @window.update
    if @frames > Graphics.frame_rate * 2
      @window.y -= 4
      @window.dispose if @window.y + @window.height < 0
    else
      @window.y += 4 if @window.y < 0
      @frames += 1
    end
  end
end
