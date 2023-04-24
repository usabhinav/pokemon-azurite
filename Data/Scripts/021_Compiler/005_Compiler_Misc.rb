require 'csv'

module Compiler
  EXPORT_MAP_INFORMATION_FOLDER = "Data/Exported Data"
  EXPORT_MAP_INFORMATION_EVENTS_FOLDER = "Data/Exported Data/Events"

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

  # Exports map information in csv formats so that online system can use it. Specifically:
  # 1. Data/Exported Data/tileset_info.csv
  # 2. Data/Exported Data/map_info.csv
  # 3. Data/Exported Data/Events/XXX.csv (for each map)
  def self.export_map_information
    # Create the necessary folders if they don't already exist
    Dir.mkdir(EXPORT_MAP_INFORMATION_FOLDER) if !(Dir.chdir(EXPORT_MAP_INFORMATION_FOLDER){true} rescue false)
    Dir.mkdir(EXPORT_MAP_INFORMATION_EVENTS_FOLDER) if !(Dir.chdir(EXPORT_MAP_INFORMATION_EVENTS_FOLDER){true} rescue false)
    map_infos = pbLoadMapInfos
    data_tilesets = load_data("Data/Tilesets.rxdata")
    # Export Tilesets.rxdata information
    CSV.open("#{EXPORT_MAP_INFORMATION_FOLDER}/tileset_info.csv", "wb") do |tileset_csv|
      tileset_csv << ["id", "name", "tileset_name"]
      for id in 0...data_tilesets.length
        data_tileset = data_tilesets[id]
        next if data_tileset.nil?
        tileset_csv << [id.to_s, data_tileset.name, data_tileset.tileset_name]
      end
    end
    # Export MapInfos.rxdata and individual map rxdatas
    CSV.open("#{EXPORT_MAP_INFORMATION_FOLDER}/map_info.csv", "wb") do |csv|
      csv << ["id", "name", "tileset_id", "width", "height", "bgm"]
      map_infos.keys.each do |id|
        map_info = map_infos[id]
        filename = sprintf("Data/Map%03d.rxdata", id)
        next if !pbRgssExists?(filename)
        map = load_data(filename)
        name = map_info.name
        tileset_id = map.tileset_id
        width = map.width
        height = map.height
        bgm = map.autoplay_bgm ? map.bgm.name : ""
        csv << [id.to_s, name, tileset_id.to_s, width.to_s, height.to_s, bgm]
        # Export MapXXX.rxdata
        export_map(id, map)
      end
    end
  end

  # Exports event and trainer info
  def self.export_map(map_id, map)
    trainer_events = []
    CSV.open("#{EXPORT_MAP_INFORMATION_EVENTS_FOLDER}/%03d.csv" % map_id, "wb") do |csv|
      csv << ["id", "name", "x", "y", "trainer_type", "trainer_name"]
      map.events.keys.sort.each do |id|
        event = map.events[id]
        name = event.name
        x = event.x
        y = event.y
        csv_row = [id.to_s, name, x.to_s, y.to_s]
        # We assume that all minor trainer events will have name of format Trainer(XXX)
        if /Trainer\([0-9]+\)/.match?(name)
          # We assume the first page will have the "TrainerBattle.start" command in a Conditional Branch script
          event.pages[0].list.each do |cmd|
            if cmd.code == 111 && cmd.parameters[0] == 12 # Conditional Branch, Script parameter
              # We assume script_args will look like:
              # [":TRAINER_TYPE", "\"TRAINER_NAME\""]
              script_args = cmd.parameters[1].split("(")[1].split(")")[0].split(",")
              csv_row.push(script_args[0].split(":")[1]) # Remove the colon from the symbol
              csv_row.push(script_args[1])
              break
            end
          end
        end
        # Append new row
        csv << csv_row
      end
    end
  end
end