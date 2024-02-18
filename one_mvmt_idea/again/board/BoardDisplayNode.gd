extends Node2D

class_name BoardDisplayNode

@export var fallback_viewport_size : Vector2i = Vector2i(160, 144)
@export var board_scene : PackedScene
@export var min_border : int = 5
@export var bounce_on_load : bool = true

var current_board : BoardNode = null

#var target_board_scale : int = 1
var bsx : float = 0
var bsvx : float = 0.0
var bsy : float = 0
var bsvy : float = 0.0

#var _time : float = 0.0

func _ready():
	hide()
	if board_scene:
		set_scene(board_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	show()
	var window_size:Vector2i = get_viewport_rect().size - Vector2.ONE * min_border * 2
	
	var board_size:Vector2i = fallback_viewport_size
	if current_board: board_size = current_board.size
	
	var target_board_scale : float = floor(max(1,min(1.0*window_size.x/board_size.x,1.0*window_size.y/board_size.y)))
	var tsx : float = board_size.x * target_board_scale
	var tsy : float = board_size.y * target_board_scale
	
	if bsx <= 0:
		bsvx = 1.0
		bsvy = 1.0
		
	bsvx = lerp(bsvx, 5 * (tsx - bsx), 0.15)
	bsx += delta * bsvx
	bsvx *= 0.999
	bsx = lerp(bsx, tsx, 0.05)
	bsx = move_toward(bsx, tsx, 0.01 * delta)
	
	bsvy = lerp(bsvy, 5 * (tsy - bsy), 0.15)
	bsy += delta * bsvy
	bsvy *= 0.999
	bsy = lerp(bsy, tsy, 0.05)
	bsy = move_toward(bsy, tsy, 0.01 * delta)
	
	position = window_size / 2 + Vector2i(min_border, min_border) # im in the middle
	if board_size.x >= 1 and board_size.y >= 1:
		scale = Vector2(bsx / board_size.x, bsy / board_size.y)
#	_time += 0.5 * delta
#	rotation_degrees = 20 * sin(_time)
	$Control.set_position(-board_size/2)
	$Control.set_size(board_size)
	
	if current_board and current_board.next_scene:
		set_scene(current_board.next_scene)

func set_scene(scene:PackedScene):
	for child in $Control/SubViewportContainer/SubViewport.get_children(true):
		child.queue_free()
	var instantiated_scene = scene.instantiate()
	$Control/SubViewportContainer/SubViewport.add_child(instantiated_scene)
	if instantiated_scene is BoardNode:
		current_board = instantiated_scene
		if bounce_on_load:
			bsx *= 0.9
			bsy *= 0.9
		_physics_process(0)
	else:
		current_board = null # null
		push_error("BoardDisplayNode.gd - set scene to non-BoardNode scene")
