extends Node
class_name NavdiStateMachine

var state : NavdiState :
	get : return _current_state
	set (s) : goto (s)

var _current_state : NavdiState = null
var _states : Array[NavdiState]
var _state_finder_dict : Dictionary = Dictionary()

func _init(states : Array[NavdiState]):
	for state in states:
		add_state(state)
	goto.call_deferred(states[0])

func _physics_process(_delta):
	if _current_state:
		_current_state._proc()
		
func with_parent(parent : Node) -> NavdiStateMachine:
	parent.add_child(self)
	return self

func add_state(state : NavdiState):
	state.machine = self
	_states.append(state)
	_state_finder_dict[state.id] = state
	_state_finder_dict[state.name] = state

func goto(state_or_key):
	var next_state : NavdiState
	if state_or_key is NavdiState: next_state = state_or_key
	else:
		if _state_finder_dict.has(state_or_key):
			next_state = _state_finder_dict.get(state_or_key)
		else:
			push_error(self.name + " cannot find key " + str(state_or_key)); return false
	if next_state != _current_state:
		if not next_state: push_error("Cannot goto null state"); return false
		if not _state_finder_dict.has(next_state.id): push_error("State with unknown id " + str(next_state.id)); return false
		var prev_state : NavdiState = _current_state
		if prev_state:
			prev_state._on_exiting_to(next_state)
			remove_child(prev_state)
		add_child(next_state); 
		next_state._on_entered_from(prev_state)
		_current_state = next_state
		return true
	else:
		return false
