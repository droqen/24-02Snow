extends CharacterBody2D
class_name MovingGuy

const FLORBUF : int = 9119
const JUMPBUF : int = 9120

var _pin : Pin
var pin : Pin : 
	get :
		if _pin == null:
			if !has_node("Pin"):
				_pin = Pin.new()
				add_child(_pin)
			else: _pin = $Pin
		return _pin

var bufs : Bufs = Bufs.new()

@onready var spr : SheetSprite = $SheetSprite

func _physics_process(_delta):
	# please override this completely
	bufs.process_bufs()
	process_slidey_move()

func accel_velocity(dvx:float, dvy:float, avx:float, avy:float):
	velocity.x = move_toward(velocity.x, dvx, avx)
	velocity.y = move_toward(velocity.y, dvy, avy)

func process_slidey_move():
	var hit:KinematicCollision2D
	hit = move_and_collide(Vector2(velocity.x, 0))
	if hit: on_bonk_h(hit)
	hit = move_and_collide(Vector2(0, velocity.y))
	if hit: on_bonk_v(hit)
	
func on_bonk_h(hit:KinematicCollision2D):
	velocity.x = 0
func on_bonk_v(hit:KinematicCollision2D):
	if velocity.y >= 0:
		bufs.setmin(FLORBUF, 4)
	velocity.y = 0
 
