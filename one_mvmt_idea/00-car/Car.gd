extends MovingGuy

var _state : int = Reset
var state : int :
	get : return _state
	set (new_state) :
		if _state != new_state :
			_state = new_state
			_on_state_changed()

var _faceleft : bool = false
var faceleft : bool : 
	get : return _faceleft
	set (new_faceleft) :
		if _faceleft != new_faceleft:
			_faceleft = new_faceleft
			spr.flip_h = faceleft
			bufs.setmin(TURNBUF, 4)

const TURNBUF = 99991

enum { Reset = 49124,
	NoVroom, Vroom, Turning, JumpingUp, FallingDown }
func _on_state_changed():
	match state:
		Reset: pass
		NoVroom: spr.setup([13])
		Vroom: spr.setup([13])
		Turning: spr.setup([15])
		JumpingUp: spr.setup([16])
		FallingDown: spr.setup([14])

func _physics_process(_delta):
	pin.process_pins()
	bufs.process_bufs()
	accel_velocity(pin.stick.x * 1.0, 2.0, 0.1, 0.03)
	if pin.stick.x: faceleft = pin.stick.x < 0
	if pin.a.pressed: bufs.setmin(JUMPBUF, 4)
	
	if bufs.try_consume([FLORBUF, JUMPBUF]): velocity.y = -1.0
	elif bufs.try_consume([JUMPBUF]):
		velocity.y = -1.0
		var bubble = load("res://00-car/jumped_bubble.tscn").instantiate()
		bubble.position = position + Vector2.DOWN * 2.0
		get_parent().add_child(bubble)
	
	if bufs.has(TURNBUF): state = Turning
	elif not bufs.has(FLORBUF) and velocity.y < -1.0: state = JumpingUp
	elif not bufs.has(FLORBUF) and velocity.y > 0.0: state = FallingDown
	elif pin.stick.x: state = Vroom
	else: state = NoVroom
	process_slidey_move()
