extends ColorRect
class_name ChessPiece

const TEAM_TOP := "yellow"
const TEAM_BOTTOM := "blue"

@export var team: String = ""
@export var board_position: Vector2i = Vector2i.ZERO

signal piece_hovered(piece: ChessPiece)
signal piece_unhovered(piece: ChessPiece)
signal piece_clicked(piece: ChessPiece)

var _is_hovered: bool = false
var _is_selected: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	_apply_visual_state()

func set_glow(active: bool) -> void:
	_is_hovered = active
	queue_redraw()

func set_selected(active: bool) -> void:
	_is_selected = active
	queue_redraw()

func _draw() -> void:
	if not _is_hovered and not _is_selected:
		return

	var glow_color := _get_glow_color()
	var border_color := _get_border_color()
	
	# Simulate box-shadow: 0 0 18px 4px
	draw_rect(Rect2(Vector2(-12.0, -12.0), size + Vector2(24.0, 24.0)), Color(glow_color.r, glow_color.g, glow_color.b, glow_color.a * 0.2), false, 8.0)
	draw_rect(Rect2(Vector2(-6.0, -6.0), size + Vector2(12.0, 12.0)), Color(glow_color.r, glow_color.g, glow_color.b, glow_color.a * 0.5), false, 6.0)
	draw_rect(Rect2(Vector2(-2.0, -2.0), size + Vector2(4.0, 4.0)), Color(glow_color.r, glow_color.g, glow_color.b, glow_color.a), false, 4.0)
	
	# Simulate border-color
	draw_rect(Rect2(Vector2.ZERO, size), border_color, false, 1.0)

func _on_mouse_entered() -> void:
	piece_hovered.emit(self)
	set_glow(true)

func _on_mouse_exited() -> void:
	piece_unhovered.emit(self)
	set_glow(false)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		accept_event()
		piece_clicked.emit(self)

func _apply_visual_state() -> void:
	color = _get_team_base_color()

func _get_team_base_color() -> Color:
	if team == TEAM_TOP:
		return Color(1.0, 0.54, 0.45, 1.0)
	if team == TEAM_BOTTOM:
		return Color(0.5, 1.0, 0.72, 1.0)
	return Color.WHITE

func _get_glow_color() -> Color:
	if team == TEAM_TOP:
		return Color(1.0, 80.0 / 255.0, 80.0 / 255.0, 0.35)
	if team == TEAM_BOTTOM:
		return Color(40.0 / 255.0, 220.0 / 255.0, 120.0 / 255.0, 0.35)
	return Color(1.0, 1.0, 1.0, 0.35)

func _get_border_color() -> Color:
	if team == TEAM_TOP:
		return Color(1.0, 120.0 / 255.0, 120.0 / 255.0, 0.75)
	if team == TEAM_BOTTOM:
		return Color(60.0 / 255.0, 220.0 / 255.0, 140.0 / 255.0, 0.75)
	return Color(1.0, 1.0, 1.0, 0.75)
