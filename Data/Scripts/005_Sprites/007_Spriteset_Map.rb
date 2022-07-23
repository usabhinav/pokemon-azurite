# Unused
class ClippableSprite < Sprite_Character
  def initialize(viewport, event, tilemap)
    @tilemap = tilemap
    @_src_rect = Rect.new(0, 0, 0, 0)
    super(viewport, event)
  end

  def update
    super
    @_src_rect = self.src_rect
    tmright = (@tilemap.map_data.xsize * Game_Map::TILE_WIDTH) - @tilemap.ox
    echoln "x=#{self.x},ox=#{self.ox},tmright=#{tmright},tmox=#{@tilemap.ox}"
    if @tilemap.ox - self.ox < -self.x
      # clipped on left
      diff = -self.x - @tilemap.ox + self.ox
      self.src_rect = Rect.new(@_src_rect.x + diff, @_src_rect.y,
                               @_src_rect.width - diff, @_src_rect.height)
      echoln "clipped out left: #{diff} #{@tilemap.ox - self.ox} #{self.x}"
    elsif tmright - self.ox < self.x
      # clipped on right
      diff = self.x - tmright + self.ox
      self.src_rect = Rect.new(@_src_rect.x, @_src_rect.y,
                               @_src_rect.width - diff, @_src_rect.height)
      echoln "clipped out right: #{diff} #{tmright + self.ox} #{self.x}"
    else
      echoln "-not- clipped out left: #{diff} #{@tilemap.ox - self.ox} #{self.x}"
    end
  end
end



class Spriteset_Map
  attr_reader :map

  @@viewport0 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Panorama
  @@viewport0.z = -100
  @@viewport1 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Map, events, player, fog
  @@viewport1.z = 0
  @@viewport3 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Flashing
  @@viewport3.z = 500

  def self.viewport   # For access by Spriteset_Global
    return @@viewport1
  end

  def initialize(map = nil)
    @map = (map) ? map : $game_map
    $scene.map_renderer.add_tileset(@map.tileset_name)
    @map.autotile_names.each { |filename| $scene.map_renderer.add_autotile(filename) }
    $scene.map_renderer.add_extra_autotiles(@map.tileset_id)
    @panorama = AnimatedPlane.new(@@viewport0)
    @fog = AnimatedPlane.new(@@viewport1)
    @fog.z = 3000
    @character_sprites = []
    @mirror_reflection_sprites = []
    mirror_list = $map_mirrors[@map.map_id]
    emptySprite = Sprite_Character.new(@@viewport1, nil)
    @map.events.keys.sort.each do |i|
      # In case the event doesn't have a sprite, don't use an entirely different Sprite_Character:
      isGraphic = false
      @map.events[i].pages.each do |page|
        if page.graphic.character_name != ""
          isGraphic = true
          break
        end
      end

      if (isGraphic)
        sprite = Sprite_Character.new(@@viewport1, @map.events[i])
      else
        sprite = emptySprite
      end
      @character_sprites.push(sprite)
      # Create a mirror reflection sprite per mirror for each event on this map
      if !@map.events[i] || (@map.events[i].name[/reflection/i] rescue false)
        for rect in mirror_list
          @mirror_reflection_sprites.push(Sprite_Mirror_Reflection.new(sprite, @map.events[i], @@viewport1, rect))
        end
      end
    end
    # Create a mirror reflection sprite per mirror for the player and per mirror for each of its followers
    if $scene.is_a?(Scene_Map)
      for rect in mirror_list
        # Player reflection
        @mirror_reflection_sprites.push(Sprite_Mirror_Reflection.new($scene.spritesetGlobal.playersprite, $game_player, @@viewport1, rect))
        # Reflection per follower
        for follower in $scene.spritesetGlobal.follower_sprites.sprites
          event = nil
          $game_temp.followers.each_follower do |ev, foll|
            if follower.character == ev
              event = follower.character
              break
            end
          end
          @mirror_reflection_sprites.push(Sprite_Mirror_Reflection.new(follower, event, @@viewport1, rect)) if event
        end
      end
    end
    @weather = RPG::Weather.new(@@viewport1)
    EventHandlers.trigger(:on_new_spriteset_map, self, @@viewport1)
    update
  end

  def dispose
    if $scene.is_a?(Scene_Map)
      $scene.map_renderer.remove_tileset(@map.tileset_name)
      @map.autotile_names.each { |filename| $scene.map_renderer.remove_autotile(filename) }
      $scene.map_renderer.remove_extra_autotiles(@map.tileset_id)
    end
    @panorama.dispose
    @fog.dispose
    @character_sprites.each { |sprite| sprite.dispose }
    @mirror_reflection_sprites.each {|sprite| sprite.dispose}
    @weather.dispose
    @panorama = nil
    @fog = nil
    @character_sprites.clear
    @mirror_reflection_sprites.clear
    @weather = nil
  end

  def getAnimations
    return @usersprites
  end

  def restoreAnimations(anims)
    @usersprites = anims
  end

  def update
    if @panorama_name != @map.panorama_name || @panorama_hue != @map.panorama_hue
      @panorama_name = @map.panorama_name
      @panorama_hue  = @map.panorama_hue
      @panorama.set_panorama(nil) if !@panorama.bitmap.nil?
      @panorama.set_panorama(@panorama_name, @panorama_hue) if !nil_or_empty?(@panorama_name)
      Graphics.frame_reset
    end
    if @fog_name != @map.fog_name || @fog_hue != @map.fog_hue
      @fog_name = @map.fog_name
      @fog_hue = @map.fog_hue
      @fog.set_fog(nil) if !@fog.bitmap.nil?
      @fog.set_fog(@fog_name, @fog_hue) if !nil_or_empty?(@fog_name)
      Graphics.frame_reset
    end
    tmox = (@map.display_x / Game_Map::X_SUBPIXELS).round
    tmoy = (@map.display_y / Game_Map::Y_SUBPIXELS).round
    @@viewport1.rect.set(0, 0, Graphics.width, Graphics.height)
    @@viewport1.ox = 0
    @@viewport1.oy = 0
    @@viewport1.ox += $game_screen.shake
    @panorama.ox = tmox / 2
    @panorama.oy = tmoy / 2
    @fog.ox         = tmox + @map.fog_ox
    @fog.oy         = tmoy + @map.fog_oy
    @fog.zoom_x     = @map.fog_zoom / 100.0
    @fog.zoom_y     = @map.fog_zoom / 100.0
    @fog.opacity    = @map.fog_opacity
    @fog.blend_type = @map.fog_blend_type
    @fog.tone       = @map.fog_tone
    @panorama.update
    @fog.update
    @character_sprites.each do |sprite|
      sprite.update
    end
    @mirror_reflection_sprites.each do |sprite|
      sprite.update
    end
    if self.map == $game_map
      @weather.fade_in($game_screen.weather_type, $game_screen.weather_max, $game_screen.weather_duration)
    else
      @weather.fade_in(:None, 0, 20)
    end
    @weather.ox   = tmox
    @weather.oy   = tmoy
    @weather.update
    @@viewport1.tone = $game_screen.tone
    @@viewport3.color = $game_screen.flash_color
    @@viewport1.update
    @@viewport3.update
  end
end
