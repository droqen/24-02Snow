extends Node
class_name PinSetup

const DIR_N : String = "N"
const DIR_S : String = "S"
const DIR_W : String = "W"
const DIR_E : String = "E"
const DIR_DEADZONE : float = 0.25

const BUT_A : String = "A"
const BUT_B : String = "B"

func _ready():
	setup_action(DIR_N, [KEY_UP], [11], [1], [-1])
	setup_action(DIR_S, [KEY_DOWN], [12], [1], [1])
	setup_action(DIR_W, [KEY_LEFT], [13], [0], [-1])
	setup_action(DIR_E, [KEY_RIGHT], [14], [0], [1])
	setup_action(BUT_A, [KEY_Z], [0, 2])
	setup_action(BUT_B, [KEY_X], [1, 3])

func setup_action(action, _keys = [], _joy_buttons = [], _joy_axes = [], _joy_axis_polarities = []):
	InputMap.add_action(action, DIR_DEADZONE)
	for key in _keys:
		var ie_key = InputEventKey.new()
		ie_key.keycode = key
		InputMap.action_add_event(action, ie_key)
	for jb in _joy_buttons:
		var ie_jb = InputEventJoypadButton.new()
		ie_jb.button_index = jb
		InputMap.action_add_event(action, ie_jb)
	if len(_joy_axes) != len(_joy_axis_polarities):
		push_error("PinSetup.gd - # of joy axes and their polarities are mismatched")
	else: for i in range(len(_joy_axes)):
		var ja = _joy_axes[i]
		var jp = _joy_axis_polarities[i]
		var ie_ja = InputEventJoypadMotion.new()
		ie_ja.axis = ja
		ie_ja.axis_value = jp
		InputMap.action_add_event(action, ie_ja)
