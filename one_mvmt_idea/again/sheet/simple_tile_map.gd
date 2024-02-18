# author: pancelor!

@tool # for cerealmap
class_name SimpleTileMap
extends TileMap


@export var LAYER: int = 0
@export var SOURCE: int = 0

# NOTE: can't put this nicely in _ready b/c children might override _ready
@warning_ignore("integer_division") # this will floor
@onready var TILES_WIDE: int = (tile_set.get_source(SOURCE) as TileSetAtlasSource).texture.get_width()/tile_set.tile_size.x

signal cell_changed(cell: Vector2i)


## godot tilemaps are way more complex than we need.
## this code layer makes them simpler -- more like pico8.
##
## if you have 12 sprites laid out in a 4x3 grid, (TILES_WIDE=4)
## then these are the coordinates:
##   (0,0) (1,0) (2,0), (3,0)
##   (0,1) (1,1) (2,1), (3,1)
##   (0,2) (1,2) (2,2), (3,2)
## and these are the ids:
##   0 1 2 3
##   4 5 6 7
##   8 9 10 11
## invalid atlas coords (e.g. in return values) are represented as (-1,-1)
## invalid ids are represented as -1

## get the sprite id held in a cell
func mget(cell: Vector2i) -> int:
	var atlas = get_cell_atlas_coords(LAYER,cell)
	return atlas_to_id(atlas)

## set a cell to a sprite id
func mset(cell: Vector2i, tile_id: int) -> void:
	set_cell(LAYER,cell,SOURCE,id_to_atlas(tile_id))
	cell_changed.emit(cell)

## awkward name; oh well
func mget_used_cells() -> Array[Vector2i]:
	return get_used_cells(LAYER)
func mget_used_cells_by_id(id: int) -> Array[Vector2i]:
	return get_used_cells_by_id(LAYER,-1,id_to_atlas(id))



func atlas_to_id(atlas: Vector2i) -> int:
	match atlas:
		Vector2i(-1,-1): return -1
		_: return atlas.y*TILES_WIDE + atlas.x

func id_to_atlas(id: int) -> Vector2i:
	match id:
		-1: return Vector2i(-1,-1)
		_:
			@warning_ignore("integer_division") # we want it to floor
			return Vector2i(posmod(id,TILES_WIDE), id/TILES_WIDE)

func global_to_map(pos: Vector2) -> Vector2:
	return local_to_map(to_local(pos))

func map_to_global(pos: Vector2) -> Vector2:
	return to_global(map_to_local(pos))
