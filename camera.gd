extends Camera2D

const ZOOM_FACTOR = .1

func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		zoom *= Vector2.ONE * (1 + ZOOM_FACTOR)
	if Input.is_action_just_pressed("zoom_out"):
		zoom *= Vector2.ONE * (1 - ZOOM_FACTOR)
