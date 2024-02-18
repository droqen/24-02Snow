extends MovingGuy

@export var tilemap : SheetTileMap

enum { Reset=5, Walk,Stand,Inair,Falling}
var _state : int = Reset
var state : int :
	get : return _state
	set (s2) :
		if _state != s2:
			_state = s2
			_on_state_changed()

func _on_state_changed():
	match state:
		Walk: spr.setup([3,2],8)
		Stand: spr.setup([2])
		Inair: spr.setup([4])
		Falling: spr.setup([6])

func _ready():
	bufs.defon(FLORBUF, 6)
	bufs.defon(JUMPBUF, 6)

func _physics_process(_delta):
	bufs.process_bufs()
	pin.process_pins()
	if pin.a.pressed: bufs.setmin(JUMPBUF, 4)
	accel_velocity(pin.stick.x * 0.75, 1.5, 0.25 if velocity.y < 0.1 else 0.0, 0.05)
	if bufs.try_consume([FLORBUF,JUMPBUF]):
		var cell = tilemap.local_to_map(position)
		var rounded_x = tilemap.map_to_local(cell).x
		if abs(position.x + pin.stick.x - rounded_x) < 3: position.x = rounded_x
		velocity.x = 0.0
		velocity.y = -1.45
	process_slidey_move()
	if pin.stick.x: spr.flip_h = pin.stick.x < 0
	if not bufs.has(FLORBUF):
		if velocity.y >= 0.3: state = Falling
		else: state = Inair
	elif pin.stick.x:
		state = Walk
	else:
		state = Stand
