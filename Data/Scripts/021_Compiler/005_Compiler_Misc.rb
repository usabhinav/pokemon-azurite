module Compiler
  def self.cache_map_mirrors
    map_mirrors = Hash.new
    mapinfos = pbLoadMapInfos
    data_tilesets = load_data("Data/Tilesets.rxdata")
    mapinfos.keys.each do |id|
      filename = sprintf("Data/Map%03d.rxdata", id)
      next if !pbRgssExists?(filename)
      map = load_data(filename)
      terrain_tags = data_tilesets[map.tileset_id].terrain_tags
      map_mirrors[id] = get_mirrors(map, terrain_tags)
    end
    save_data(map_mirrors, "Data/map_mirrors.dat")
  end

  # Gets list of clusters of mirror tiles
  def self.get_mirrors(map, terrain_tags)
    width = map.width
    height = map.height
    checked = Array.new(height){Array.new(width) {false}}
    list = []
    for x in 0...width
      for y in 0...height
        if !checked[y][x]
          cur_list = []
          check_mirror(x, y, checked, cur_list, map, terrain_tags)
          if cur_list.length > 0
            x_list = []
            y_list = []
            for i in cur_list
              x_list.push(i[0])
              y_list.push(i[1])
            end
            list.push(Rect.new(x_list.min, y_list.min, (x_list.max - x_list.min + 1), (y_list.max - y_list.min + 1)))
          end
        end
      end
    end
    return list
  end

  def self.check_mirror(x, y, checked, cur_list, map, terrain_tags)
    width = map.width
    height = map.height
    return if x < 0 || x >= width || y < 0 || y >= height
    if !checked[y][x]
      is_mirror = false
      [2, 1, 0].each do |i|
        terrain = GameData::TerrainTag.try_get(terrain_tags[map.data[x, y, i]])
        if terrain.id == :Mirror
          is_mirror = true
          break
        end
      end
      checked[y][x] = true
      if is_mirror
        cur_list.push([x, y])
        check_mirror(x + 1, y, checked, cur_list, map, terrain_tags)
        check_mirror(x - 1, y, checked, cur_list, map, terrain_tags)
        check_mirror(x, y + 1, checked, cur_list, map, terrain_tags)
        check_mirror(x, y - 1, checked, cur_list, map, terrain_tags)
      end
    end
  end
end