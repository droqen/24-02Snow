extends Node

@export var solid_map : SheetTileMap
@export var fixed_tets : SheetTileMap
@export var moving_tets : SheetTileMap
@export var game_over : Node2D
@export var score_label : Label

var tet_auto_descent_timer : int = 0

var clearing_lines_timer : int = 0

var lines_cleared : int = 0

func _ready():
	game_over.hide()

func _physics_process(_delta):
	game_over.hide()
	score_label.text = str(lines_cleared)
	$Pin.process_pins()
	if clearing_lines_timer > 0:
		clearing_lines_timer -= 1
		if clearing_lines_timer == 0:
			update_clearing_lines()
	else:
		if $Pin.up.pressed:
			rottets()
		if $Pin.left.pressed: try_movetets(Vector2i.LEFT)
		if $Pin.right.pressed: try_movetets(Vector2i.RIGHT)
		if $Pin.down.pressed: if not try_movetets(Vector2i.DOWN): locktets()
		if $Pin.a.pressed:
			while try_movetets(Vector2i.DOWN): pass
			locktets()
		if tet_auto_descent_timer > 0:
			tet_auto_descent_timer -= 1
		else:
			if not hastets():
				var chs = get_column_heights()
				var highest = chs.min()
				var deepest = chs.max()
				match abs(highest - deepest):
					0:
						spawntet([Mino.O, Mino.J, Mino.L, Mino.T])
					1:
						if chs[0]==deepest and chs[0]==chs[1]:
							spawntet([Mino.S, Mino.O])
						elif chs[2]==deepest and chs[2]==chs[3]:
							spawntet([Mino.Z, Mino.O])
						elif chs[1]==deepest and chs[1]==chs[2]: spawntet([Mino.S, Mino.Z, Mino.T])
						elif chs[1]==deepest: spawntet([Mino.L, Mino.T])
						elif chs[2]==deepest: spawntet([Mino.J, Mino.T])
						else: spawntet([Mino.J, Mino.L, Mino.T])
					2:
						if chs[0]==deepest and chs[0]==chs[1]: spawntet(Mino.O)
						elif chs[1]==deepest and chs[1]==chs[2]: spawntet(Mino.O)
						elif chs[2]==deepest and chs[2]==chs[3]: spawntet(Mino.O)
						elif chs[0]+1==chs[1]: spawntet([Mino.S, Mino.T])
						elif chs[1]+1==chs[2]: spawntet([Mino.S, Mino.T])
						elif chs[2]+1==chs[3]: spawntet([Mino.S, Mino.T])
						elif chs[0]-1==chs[1]: spawntet([Mino.Z, Mino.T])
						elif chs[1]-1==chs[2]: spawntet([Mino.Z, Mino.T])
						elif chs[2]-1==chs[3]: spawntet([Mino.Z, Mino.T])
						elif abs(chs[0]-chs[1])==1: spawntet([Mino.S, Mino.T, Mino.Z])
						elif abs(chs[1]-chs[2])==1: spawntet([Mino.S, Mino.T, Mino.Z])
						elif abs(chs[2]-chs[3])==1: spawntet([Mino.S, Mino.T, Mino.Z])
						elif chs[0]+2==chs[1]: spawntet(Mino.L)
						elif chs[1]+2==chs[2]: spawntet(Mino.L)
						elif chs[2]+2==chs[3]: spawntet(Mino.L)
						elif chs[0]-2==chs[1]: spawntet(Mino.J)
						elif chs[1]-2==chs[2]: spawntet(Mino.J)
						elif chs[2]-2==chs[3]: spawntet(Mino.J)
						else: spawntet([Mino.J, Mino.L])
					3:
						if chs.count(highest)==3: spawntet(Mino.I)
						elif chs[0]+2==chs[1]: spawntet(Mino.L)
						elif chs[1]+2==chs[2]: spawntet(Mino.L)
						elif chs[2]+2==chs[3]: spawntet(Mino.L)
						elif chs[0]-2==chs[1]: spawntet(Mino.J)
						elif chs[1]-2==chs[2]: spawntet(Mino.J)
						elif chs[2]-2==chs[3]: spawntet(Mino.J)
						elif chs[0]+1==chs[1]: spawntet([Mino.S, Mino.T])
						elif chs[1]+1==chs[2]: spawntet([Mino.S, Mino.T])
						elif chs[2]+1==chs[3]: spawntet([Mino.S, Mino.T])
						elif chs[0]-1==chs[1]: spawntet([Mino.Z, Mino.T])
						elif chs[1]-1==chs[2]: spawntet([Mino.Z, Mino.T])
						elif chs[2]-1==chs[3]: spawntet([Mino.Z, Mino.T])
						else: spawntet(Mino.I)
					4,_: # 4 or more... gimme an I!
						spawntet(Mino.I)
			if not try_movetets(Vector2i.DOWN): locktets()
			tet_auto_descent_timer = 30

enum Mino {
	O=0, I=1,
	J, L, S, T, Z,
}

func update_clearing_lines():
	for tid in [4,5,6]:
		var tidcells = fixed_tets.mget_used_cells_by_id(tid)
		if len(tidcells):
			if tid == 6:
				var full_rows = []
				for cell in tidcells:
					if not cell.y in full_rows: full_rows.append(cell.y)
					fixed_tets.mset(cell, -1) # clear cell
				var drop : int = 0
				for y in range(14, -1, -1):
					if y in full_rows: drop += 1; continue;
					if drop > 0:
						for x in range(2,6):
							fixed_tets.mset(Vector2i(x,y+drop), fixed_tets.mget(Vector2i(x,y)))
							fixed_tets.mset(Vector2i(x,y), -1)
				return
			else:
				for cell in tidcells:
					fixed_tets.mset(cell, tid + 1)
				clearing_lines_timer = 10
				return

var bag : Array[int] = []

func refill_bag():
	bag = [0,1,2,3,4,5,6]

func spawntet(id=-1):
	if len(bag) == 0: refill_bag()
	if id is Array:
		var ids = id
		id = -1
		ids.shuffle()
		for maybe_id in ids:
			if maybe_id in bag:
				id = maybe_id
				break
	if not id in bag:
		if len(bag) == 0: refill_bag()
		id=bag[randi()%len(bag)]
	bag.erase(id)
	var tetid = 1
	var xys = []
	match id:
		Mino.O: xys = [[1,1],[2,1],[1,0],[2,0]]; tetid = 2
		Mino.I: xys = [[0,0],[2,0],[1,0],[3,0]]; tetid = 2
		Mino.J: xys = [[0,0],[1,0],[2,0],[2,1]]
		Mino.L: xys = [[3,0],[2,0],[1,0],[1,1]]; tetid = 3
		Mino.S: xys = [[1,0],[2,0],[0,1],[1,1]]
		Mino.T: xys = [[1,0],[2,0],[3,0],[2,1]]; tetid = 2
		Mino.Z: xys = [[1,0],[2,0],[2,1],[3,1]]; tetid = 3
	for xy in xys:
		moving_tets.mset(Vector2i(xy[0]+2, xy[1]), tetid)
	for xy in xys:
		if is_solid(Vector2i(xy[0]+2, xy[1])):
			get_tree().paused = true
			game_over.show()
func hastets() -> bool:
	match len(moving_tets.mget_used_cells()):
		0: return false
		4: return true
		_: push_error("Bad # of MovingTets: "+str(moving_tets.mget_used_cells())); moving_tets.clear(); return false
func rottets():
	if not hastets(): return # failed
	var used_rect = moving_tets.get_used_rect()
	var possible_pivots = []
	for ox in [-0.4,0.4]:
		for oy in [0.4,-0.4]:
			var pivot = Vector2i(
				roundi(used_rect.position.x + (used_rect.size.x - 1) * 0.5 + ox),
				roundi(used_rect.position.y + (used_rect.size.y - 1) * 0.5 + oy)
			)
			if not pivot in possible_pivots:
				possible_pivots.append(pivot)
	
	for pivot in possible_pivots:
		if try_rottets_around(pivot): break
	#print("possible pivots: "+str(possible_pivots))
func try_rottets_around(pivot:Vector2i) -> bool:
	if not hastets(): return false
	var movingcells = moving_tets.mget_used_cells()
	var tetid = moving_tets.mget(movingcells[0])
	var targetcells = []
	for cell in movingcells:
		var cell2 = Vector2i(pivot.y - cell.y, cell.x - pivot.x) + pivot
		targetcells.append(cell2)
	for cell in targetcells:
		if is_solid(cell):
			return false
	moving_tets.clear()
	for cell in targetcells:
		moving_tets.mset(cell, tetid)
	return true # it worked, wow
func try_movetets(dir:Vector2i) -> bool:
	if not hastets(): return false
	var movingcells = moving_tets.mget_used_cells()
	var tetid = moving_tets.mget(movingcells[0])
	for cell in movingcells:
		if is_solid(cell + dir): return false
	moving_tets.clear()
	for cell in movingcells:
		moving_tets.mset(cell + dir, tetid)
	return true
func locktets():
	for cell in moving_tets.mget_used_cells():
		fixed_tets.mset(cell, moving_tets.mget(cell))
	moving_tets.clear()
	for y in range(15):
		var line_full : bool = true
		for x in range(2,6):
			if fixed_tets.mget(Vector2i(x,y)) < 0:
				line_full = false
		if line_full:
			for x in range(2,6):
				fixed_tets.mset(Vector2i(x,y), 4)
			lines_cleared += 1
			clearing_lines_timer = 10

func is_solid(cell) -> bool:
	return solid_map.mget(cell) != 8 or fixed_tets.mget(cell) >= 0

func get_column_heights() -> Array[int]:
	var chs : Array[int] = []
	for x in range(2,6):
		for y in range(0,15+1):
			if is_solid(Vector2i(x,y)):
				chs.append(y-1)
				break
	return chs

func get_column_heights_zeroed() -> Array[int]:
	var chs = get_column_heights()
	var minus = chs.min()
	for i in range(4): chs[i] -= minus
	return chs
