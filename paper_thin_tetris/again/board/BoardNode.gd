@tool
extends Node2D
class_name BoardNode

var next_scene : PackedScene = null

@export var size : Vector2i = Vector2i(160, 144)
@export var outline_colour : Color = Color.CHARTREUSE
var _last_rendered_size : Vector2i

func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _last_rendered_size != size:
		queue_redraw()
		_last_rendered_size = size

func _draw():
	if Engine.is_editor_hint():
		draw_line(Vector2(      -1,      -1),Vector2(size.x+1,      -1),outline_colour)
		draw_line(Vector2(      -1,      -1),Vector2(      -1,size.y+1),outline_colour)
		draw_line(Vector2(size.x+1,size.y+1),Vector2(size.x+1,      -1),outline_colour)
		draw_line(Vector2(size.x+1,size.y+1),Vector2(      -1,size.y+1),outline_colour)
