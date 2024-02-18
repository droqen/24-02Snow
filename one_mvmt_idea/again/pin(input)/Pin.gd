extends Node
class_name Pin

var stick : Vector2
var a : PinButton = PinButton.new()
var b : PinButton = PinButton.new()
var up : PinButton = PinButton.new()
var down : PinButton = PinButton.new()
var left : PinButton = PinButton.new()
var right : PinButton = PinButton.new()

func clear():
	stick = Vector2.ZERO
	for pb_pair in [[a,"A"],[b,"B"],[up,"N"],[down,"S"],[left,"W"],[right,"E"]]:
		var pb = pb_pair[0]
		pb.pressed = false
		pb.released = false
		if pb.held:
			pb.held = false
			pb.released = true
func process_pins():
	stick = Vector2(
		Input.get_action_strength("E") - Input.get_action_strength("W"),
		Input.get_action_strength("S") - Input.get_action_strength("N")
	)
	for pb_pair in [[a,"A"],[b,"B"],[up,"N"],[down,"S"],[left,"W"],[right,"E"]]:
		var pb = pb_pair[0]
		pb.pressed = false
		pb.released = false
		if pb.held != (Input.get_action_strength(pb_pair[1]) > 0):
			pb.held = not pb.held
			if pb.held: pb.pressed = true
			else: pb.released = true
