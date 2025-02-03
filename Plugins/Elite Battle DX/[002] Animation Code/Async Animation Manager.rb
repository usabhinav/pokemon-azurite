module AsyncAnimationManager
  def self.update_animation(animation_data_list, current_sprite)
    # Update current sprite
    if animation_data_list.length > 0
      # Align all pending animation sprites with current sprite
      animation_data_list.each_with_index do |animation_data, i|
        animation_data.new_sprite.x = current_sprite.x
        animation_data.new_sprite.y = current_sprite.y
        animation_data.new_sprite.zoom_x = current_sprite.zoom_x
        animation_data.new_sprite.zoom_y = current_sprite.zoom_y
        animation_data.new_sprite.z = current_sprite.z - (i + 1)
      end
      animation_data = animation_data_list[0]
      completed = animation_data.update(current_sprite)
      # Dispose current sprite to display the new sprite behind it in full, and update the remaining animation data objects in the queue
      if completed
        current_sprite.visible = false
        current_sprite.dispose
        new_sprite = animation_data.new_sprite
        animation_data_list.each do |data|
          data.new_sprite.z += 1
        end
        animation_data_list.delete_at(0)
        return new_sprite
      end
    end
    return current_sprite
  end
end

#===============================================================================
# generic class to store data related to the any asynchronous sprite animation
#===============================================================================
class AsyncAnimationData
  # New sprite to overlay
  attr_reader :new_sprite
end

#===============================================================================
# custom class to store data related to the invert sprite colors animation
#===============================================================================
class InvertSpriteColorsAnimationData < AsyncAnimationData
  # X value of center of circle on bitmap
  attr_reader :start_center_x
  # Y value of center of circle on bitmap
  attr_reader :start_center_y
  # Method to update destination radius amount after animation has been updated
  # by one frame
  attr_reader :destination_radius_transform_proc
  # If true, circle animation goes inward instead of outward (i.e. circle
  # shrinks down).
  attr_reader :is_shrinking

  # Radius of the current circle in animation
  attr_accessor :current_circle_radius
  # List of x values (index is y value) of current circle in animation
  attr_accessor :previous_circle_x_coords
  
  def initialize(start_center_x, start_center_y, destination_radius_transform_proc, is_shrinking, new_sprite)
    @start_center_x = start_center_x
    @start_center_y = start_center_y
    @destination_radius_transform_proc = destination_radius_transform_proc
    @is_shrinking = is_shrinking
    @new_sprite = new_sprite
    @current_circle_radius = 0
    @previous_circle_x_coords = []
  end

  def update(current_sprite)
    x = @start_center_x
    y = @start_center_y
    # Get on-screen coordinates of circle center
    sprite_center = getSpriteCenter(current_sprite)
    start_center_x_screen = (x * current_sprite.zoom_x) + sprite_center[0] - (current_sprite.width * current_sprite.zoom_x / 2)
    start_center_y_screen = (y * current_sprite.zoom_y) + sprite_center[1] - (current_sprite.height * current_sprite.zoom_y / 2)
    # Maximum value that radius can reach before the entire sprite is inverted
    # We calculate the largest distance from the center to any point on the game screen, and we use that distance (plus some buffer)
    # as the maximum allowed radius.
    game_screen_corner_x = (start_center_x_screen <= Graphics.width / 2) ? Graphics.width : 0
    game_screen_corner_y = (start_center_y_screen <= Graphics.height / 2) ? Graphics.height : 0
    x_diff_with_zoom = ((game_screen_corner_x - start_center_x_screen) / current_sprite.zoom_x).ceil
    y_diff_with_zoom = ((game_screen_corner_y - start_center_y_screen) / current_sprite.zoom_y).ceil
    max_radius = Math.sqrt(x_diff_with_zoom ** 2 + y_diff_with_zoom ** 2).ceil
    max_radius += 4 # Arbitrary buffer
    needs_update = nil
    # Determine if animation is finished (i.e. circle has expanded to the maximum necessary or contracted to radius of 0).
    if @is_shrinking
      # On the first frame, the "previous circle" will be the max radius to cover the visible screen.
      @current_circle_radius = max_radius + @destination_radius_transform_proc.call(max_radius) if @previous_circle_x_coords.length == 0
      previous_circle_radius = @previous_circle_x_coords.length > 0 ? @previous_circle_x_coords[0] : max_radius
      needs_update = previous_circle_radius > 0
    else
      previous_circle_radius = @previous_circle_x_coords.length > 0 ? @previous_circle_x_coords[0] : 0
      needs_update = previous_circle_radius < max_radius
    end
    if needs_update
      # If circle is shrinking and it's the first frame, in addition to drawing the circle closing in, we also need to pre-invert the
      # non-visible portions of the bitmap, in case the screen zooms out during the middle of the animation.
      if @is_shrinking && @previous_circle_x_coords.length == 0
        # Top area
        current_sprite.bitmap.fill_rect(0, 0, current_sprite.bitmap.width, y - max_radius, Color.new(0, 0, 0, 0))
        # Bottom area
        current_sprite.bitmap.fill_rect(0, y + max_radius, current_sprite.bitmap.width, current_sprite.bitmap.height - y - max_radius, Color.new(0, 0, 0, 0))
        # Left area
        current_sprite.bitmap.fill_rect(0, 0, x - max_radius, current_sprite.bitmap.height, Color.new(0, 0, 0, 0))
        # Right area
        current_sprite.bitmap.fill_rect(x + max_radius, 0, current_sprite.bitmap.width - x - max_radius, current_sprite.bitmap.height, Color.new(0, 0, 0, 0))
      end
      new_circle_coords = []
      x_diff = @current_circle_radius
      y_diff = 0
      error = 0
      while x_diff >= y_diff
        # Stores x_diff of current circle to be used in the next iteration
        new_circle_coords.push(x_diff)
        previous_x_coord = @previous_circle_x_coords[y_diff]
        if @is_shrinking
          # Draws from previous circle, and assumes max_radius on the first frame
          mini_offset = previous_x_coord ? previous_x_coord - 1 : max_radius
          mini_length = mini_offset - x_diff + 1
          inner_offset = x_diff
          outer_offset = mini_offset
        else
          # Draws either from previous circle or line y = x, whichever is closer to current circle
          mini_offset = ((previous_x_coord && previous_x_coord > y_diff) ? previous_x_coord + 1 : y_diff)
          mini_length = x_diff - mini_offset + 1
          inner_offset = mini_offset
          outer_offset = x_diff
        end
        # Octants start from the mathematical definition of 0 degrees (the positive x-axis) and go counter-clockwise
        # Note that we could simplify this logic using loops and functions, however, we do not do this because using those
        # constructs adds additional overhead and makes the overall animation slower.
        # Octant 1
        current_sprite.bitmap.fill_rect(x + inner_offset, y - y_diff, mini_length, 1, Color.new(0, 0, 0, 0))
        # Octant 2
        current_sprite.bitmap.fill_rect(x + y_diff, y - outer_offset, 1, mini_length, Color.new(0, 0, 0, 0))
        # Octant 3
        current_sprite.bitmap.fill_rect(x - y_diff, y - outer_offset, 1, mini_length, Color.new(0, 0, 0, 0))
        # Octant 4
        current_sprite.bitmap.fill_rect(x - outer_offset, y - y_diff, mini_length, 1, Color.new(0, 0, 0, 0))
        # Octant 5
        current_sprite.bitmap.fill_rect(x - outer_offset, y + y_diff, mini_length, 1, Color.new(0, 0, 0, 0))
        # Octant 6
        current_sprite.bitmap.fill_rect(x - y_diff, y + inner_offset, 1, mini_length, Color.new(0, 0, 0, 0))
        # Octant 7
        current_sprite.bitmap.fill_rect(x + y_diff, y + inner_offset, 1, mini_length, Color.new(0, 0, 0, 0))
        # Octant 8
        current_sprite.bitmap.fill_rect(x + inner_offset, y + y_diff, mini_length, 1, Color.new(0, 0, 0, 0))
        # Bresenham Circle Algorithm (derived from Midpoint Circle Algorithm)
        x_change = 1 - 2*x_diff
        y_change = 1 + 2*y_diff
        # If error in true radius decreases by decrementing x, do so
        if 2*(error + y_change) + x_change > 0
          x_diff -= 1
          error += x_change
        end
        y_diff += 1
        error += y_change
      end
      # While shrinking, the above loop will not cover all pixels necessary to fill the space in between the inner and outer circle.
      # We need to fill in the 4 corners of space by doing a box fill (it will fill more pixels than necessary, but it is not a
      # very expensive operation).
      if @is_shrinking
        previous_circle_radius = @previous_circle_x_coords.length > 0 ? @previous_circle_x_coords[0] : max_radius
        remaining_area_size = previous_circle_radius - x_diff + 1
        # Top-right
        current_sprite.bitmap.fill_rect(x + x_diff, y - previous_circle_radius, remaining_area_size, remaining_area_size, Color.new(0, 0, 0, 0))
        # Top-left
        current_sprite.bitmap.fill_rect(x - previous_circle_radius, y - previous_circle_radius, remaining_area_size, remaining_area_size, Color.new(0, 0, 0, 0))
        # Bottom-left
        current_sprite.bitmap.fill_rect(x - previous_circle_radius, y + x_diff, remaining_area_size, remaining_area_size, Color.new(0, 0, 0, 0))
        # Bottom-right
        current_sprite.bitmap.fill_rect(x + x_diff, y + x_diff, remaining_area_size, remaining_area_size, Color.new(0, 0, 0, 0))
      end
      # Update current animation data
      @current_circle_radius += @destination_radius_transform_proc.call(@current_circle_radius)
      @previous_circle_x_coords = new_circle_coords
    end
    # Return if animation completed (if current circle radius has reached its destination radius)
    return @is_shrinking ? @current_circle_radius <= 0 : @current_circle_radius >= max_radius
  end

  def self.create_new(old_sprite, viewport, destination_radius_transform_proc, is_shrinking, battler_sprite = nil)
    # Create a copy of the previous sprite with invert transformation applied
    old_sprite_bitmap = old_sprite.bitmap
    new_sprite = Sprite.new(viewport)
    new_sprite.z = old_sprite.z - 1
    new_sprite.center!
    new_sprite.ox = old_sprite.ox
    new_sprite.oy = old_sprite.oy
    new_sprite.bitmap = Bitmap.new(old_sprite_bitmap.width, old_sprite_bitmap.height)
    new_sprite.bitmap.blt(0, 0, old_sprite_bitmap, old_sprite_bitmap.rect)
    new_sprite.invert = !old_sprite.invert
    # Get coordinates to start invert sprite animation from
    battler_center_x, battler_center_y = battler_sprite.nil? ? [Graphics.width / 2, Graphics.height / 2] : battler_sprite.getCenter(true)
    bg_center = getSpriteCenter(old_sprite)
    # coordinates on bitmap = (coordinates of bitmap relative to game screen) + (coordinates of battler relative to game screen)
    start_center_x = (((old_sprite.width * old_sprite.zoom_x / 2) - bg_center[0] + battler_center_x) / old_sprite.zoom_x).floor
    start_center_y = (((old_sprite.height * old_sprite.zoom_y / 2) - bg_center[1] + battler_center_y) / old_sprite.zoom_y).floor
    # Return new animation data
    return InvertSpriteColorsAnimationData.new(start_center_x, start_center_y, destination_radius_transform_proc, is_shrinking, new_sprite)
  end
end
