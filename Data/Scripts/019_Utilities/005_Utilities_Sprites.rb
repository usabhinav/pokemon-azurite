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