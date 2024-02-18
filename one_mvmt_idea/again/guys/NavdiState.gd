extends Node
class_name NavdiState
# buf & adj

var machine : NavdiStateMachine
var id : int = -1
var active : bool = false
var age : int = 0
var cbs_enter : Array[Callable]
var cbs_proc : Array[Callable]
var cbs_exit : Array[Callable]
var prev_state : NavdiState
var next_state : NavdiState

func _init(__id : int,):
	self.id = __id
	self.name = str(__id)
func _on_entered_from(_prev_state : NavdiState):
	prev_state = _prev_state
	next_state = null
	active = true
	age = 0
	for cb_enter in cbs_enter: cb_enter.call(self)
func _proc():
	age += 1
	for cb_proc in cbs_proc: cb_proc.call(self); if not active: break;
func _on_exiting_to(_next_state : NavdiState):
	next_state = _next_state
	active = false
	for cb_exit in cbs_exit: cb_exit.call(self)

func goto(state_or_key): machine.goto(state_or_key)

func with_name(__name : String = "") -> NavdiState: name = __name; return self
func with_enter(cb : Callable) -> NavdiState: cbs_enter.append(cb); return self
func with_proc(cb : Callable) -> NavdiState: cbs_proc.append(cb); return self
func with_exit(cb : Callable) -> NavdiState: cbs_exit.append(cb); return self

func with_autonext(autonext_timer : int, autonext_statekey) -> NavdiState:
	return with_proc(func(_me): if age >= autonext_timer: goto(autonext_statekey))
