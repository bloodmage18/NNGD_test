extends Camera2D

# Zoom settings
@export var zoom_speed: float = 0.1
@export var max_zoom: float = 3.0
@export var min_zoom: float = 0.5

# Drag settings
var is_dragging: bool = false
var drag_start_position: Vector2

func _input(event):
	# Handle zoom with the mouse wheel
	if event is InputEventMouseMotion:
		if is_dragging:
			var drag_delta = drag_start_position - event.global_position
			position += drag_delta
			drag_start_position = event.global_position

	elif event is InputEventMouseButton:
		# Start dragging with left mouse button
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_position = event.global_position
			else:
				is_dragging = false
		
		# Handle zoom with mouse wheel
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = Vector2(
				clamp(zoom.x - zoom_speed, min_zoom, max_zoom),
				clamp(zoom.y - zoom_speed, min_zoom, max_zoom)
			)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = Vector2(
				clamp(zoom.x + zoom_speed, min_zoom, max_zoom),
				clamp(zoom.y + zoom_speed, min_zoom, max_zoom)
			)
