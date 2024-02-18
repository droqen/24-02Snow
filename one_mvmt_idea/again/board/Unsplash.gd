extends Node2D
class_name Unsplash

@export var anim_player : AnimationPlayer
@export var unsplash_anim_name : String = "unsplash_default_animation"
@export var pause_during_anim : bool = true
@export var center_on_screen : bool = true

func _ready():
	if anim_player:
		anim_player.play(unsplash_anim_name)
		if pause_during_anim:
			process_mode = Node.PROCESS_MODE_ALWAYS
			get_tree().paused = true
			await anim_player.animation_finished
			get_tree().paused = false
			queue_free()
func _process(_delta):
	var window_size:Vector2i = get_viewport_rect().size
	position = window_size * 0.5
