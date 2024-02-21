extends MovingGuy

@export var tilemap : SheetTileMap

const LUNGEBUF : int = 993822
const COYOTEFALLBUF : int = 912482
const ATK_COOLDOWN_BUF : int = 192412

enum { Reset=5, Walk,Stand,Inair,CoyotePreFall,Falling,Lunging,Duck}
var _state : int = Reset
var state : int :
	get : return _state
	set (s2) :
		if _state != s2:
			var _prev_state = _state
			_state = s2
			_on_state_changed(_prev_state)

func _on_state_changed(prev):
	if prev == Lunging:
		bufs.setmin(ATK_COOLDOWN_BUF, 10)
	
	match state:
		Reset: pass
		Walk: spr.setup([3,2] if spr.frame != 3 else [2,3],8)
		Duck: spr.setup([3])
		Stand: spr.setup([2])
		Inair: spr.setup([4])
		#CoyotePreFall: spr.setup([4,6,6,4,4,6],4); bufs.setmin(COYOTEFALLBUF, 24); bufs.setmin(FLORBUF, 24)
		CoyotePreFall: spr.setup([4]); bufs.setmin(COYOTEFALLBUF, 8); bufs.setmin(FLORBUF, 8)
		Falling: spr.setup([6]); bufs.clr(FLORBUF); if pin.down.held: velocity.y = 0.5
		Lunging: spr.setup([7])
	if state == Duck:
		var cell = tilemap.local_to_map(position)
		var rounded_x = tilemap.map_to_local(cell).x
		if abs(position.x - rounded_x) < 3: position.x = rounded_x

func _ready():
	bufs.defon(FLORBUF, 6)
	bufs.defon(JUMPBUF, 6)
	bufs.defon(LUNGEBUF, 18)

func _physics_process(_delta):
	bufs.process_bufs()
	pin.process_pins()
	if pin.a.pressed: bufs.on(JUMPBUF)
	if state == Lunging: pin.stick = Vector2.ZERO
	if state != Lunging and pin.b.pressed and not bufs.has(ATK_COOLDOWN_BUF):
		state = Lunging
		bufs.on(LUNGEBUF)
		velocity.x = -2 if spr.flip_h else 2
		velocity.y = 0
		var cell = tilemap.local_to_map(position)
		var rounded_y = tilemap.map_to_local(cell).y - 0.1
		if abs(position.y - rounded_y) < 4: position.y = rounded_y
	match state:
		Lunging:		velocity.x *= 0.90
		#Falling:		accel_velocity(0.0, 1.5, 0.05, 0.05)
		CoyotePreFall:	accel_velocity(0.0, 0.5, 0.05, 0.025)
		_:				accel_velocity(pin.stick.x * 0.75, 1.5, 0.25, 0.05)
	if state == Falling:
		var cell = tilemap.local_to_map(position)
		var rounded_y = tilemap.map_to_local(cell).y - 0.1
		if abs(position.y + 1 - rounded_y) < 1: position.y = rounded_y
	if bufs.try_consume([FLORBUF,JUMPBUF]):
		var cell = tilemap.local_to_map(position)
		var rounded_x = tilemap.map_to_local(cell).x
		if abs(position.x + pin.stick.x - rounded_x) < 3: position.x = rounded_x
		var rounded_y = tilemap.map_to_local(cell).y - 0.1
		if abs(position.y - 1 - rounded_y) < 3: position.y = rounded_y
		velocity.x = 0.0
		velocity.y = -1.42
		if pin.down.held: velocity.y = -1.00
		state = Inair
	process_slidey_move(); spr.position.x = (roundi(position.x)-position.x)
	if pin.stick.x: spr.flip_h = pin.stick.x < 0
	match state:
		Lunging:
			if not bufs.has(LUNGEBUF): state = Reset
		Falling:
			if bufs.has(FLORBUF): state = Reset
		CoyotePreFall:
			if not bufs.has(FLORBUF) or pin.down.held: state = Falling
		_:
			if not bufs.has(FLORBUF):
				if velocity.y >= 0.3:
					if state != Inair: state = CoyotePreFall
					else: state = Falling
				else: state = Inair
			elif pin.stick.x: state = Walk
			elif pin.down.held: state = Duck
			else: state = Stand
