@tool
extends SimpleTileMap
class_name SheetTileMap

@export var sheet : Sheet

func get_sheets_tilemap_path(source_sheet : Sheet) -> String:
	var path = source_sheet.resource_path
	var sheetindex = path.rfind("sheet.tres")
	if sheetindex > 0:
		return path.substr(0, sheetindex) + "tiles.tres"
		
	var tresindex = path.rfind(".tres")
	if tresindex > 0:
		return path.substr(0, tresindex) + "_tiles.tres"
	
	var resindex = path.rfind(".res")
	if resindex > 0:
		return path.substr(0, resindex) + "_tiles.res"
	
	push_error("Could not convert path " + path)
	return "" # error

func _physics_process(_delta):
	if sheet and not tile_set:
		var sheet_path = get_sheets_tilemap_path(sheet)
		if sheet_path:
			var loaded_tile_set = ResourceLoader.load(sheet_path)
			if loaded_tile_set == null:
				tile_set = TileSet.new()
				tile_set.tile_size = Vector2i(
					floori(sheet.texture.get_width() / sheet.hframes),
					floori(sheet.texture.get_height() / sheet.vframes)
				)
				var atlas = TileSetAtlasSource.new()
				atlas.texture = sheet.texture
				atlas.texture_region_size = Vector2i(10,10)
				for y in range(sheet.vframes):
					for x in range(sheet.hframes):
						atlas.create_tile(Vector2i(x,y), Vector2i.ONE)
				tile_set.add_source(atlas)
				ResourceSaver.save(tile_set, sheet_path)
				tile_set = ResourceLoader.load(sheet_path)
			else:
				tile_set = loaded_tile_set
