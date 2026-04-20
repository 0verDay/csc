extends ColorRect
class_name BoardCell

@export var grid_position: Vector2i = Vector2i.ZERO
@export var cell_size: Vector2 = Vector2(96.0, 96.0)

func _ready() -> void:
	color = Color(0.16, 0.18, 0.22, 1.0)
	custom_minimum_size = cell_size
	size = cell_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	queue_redraw()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		accept_event()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.85, 0.85, 0.85, 1.0), false, 2.0)
