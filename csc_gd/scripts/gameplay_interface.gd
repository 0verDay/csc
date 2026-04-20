extends Control

var yellow_pieces: Array[ChessPiece] = []
var blue_pieces: Array[ChessPiece] = []
var yellow_cards: Array[CardUI] = []
var blue_cards: Array[CardUI] = []

var _is_dragging: bool = false
var _drag_start_mouse_pos: Vector2
var _drag_start_board_pos: Vector2

var _selected_piece: ChessPiece = null
var _selected_card: CardUI = null

const MIN_ZOOM: float = 0.5
const MAX_ZOOM: float = 2.0
const ZOOM_STEP: float = 0.1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$BoardContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$LeftPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$RightPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_gather_nodes()
	_bind_interactions()

func _gather_nodes() -> void:
	var board = $BoardContainer
	for child in board.get_children():
		if child is ChessPiece:
			if child.team == "yellow":
				yellow_pieces.append(child)
			elif child.team == "blue":
				blue_pieces.append(child)
				
	# Sort pieces from left to right (by board_position.x)
	yellow_pieces.sort_custom(func(a, b): return a.board_position.x < b.board_position.x)
	blue_pieces.sort_custom(func(a, b): return a.board_position.x < b.board_position.x)
	
	var left_panel = $LeftPanel
	for child in left_panel.get_children():
		if child is CardUI:
			yellow_cards.append(child)
			
	var right_panel = $RightPanel
	for child in right_panel.get_children():
		if child is CardUI:
			blue_cards.append(child)

func _input(event: InputEvent) -> void:
	var board = $BoardContainer
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if _is_mouse_over_ui(event.position):
					return
				_is_dragging = true
				_drag_start_mouse_pos = event.position
				_drag_start_board_pos = board.position
			else:
				_is_dragging = false
				
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if _is_mouse_over_ui(event.position):
				return
			_zoom_board(board, event.position, ZOOM_STEP)
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if _is_mouse_over_ui(event.position):
				return
			_zoom_board(board, event.position, -ZOOM_STEP)
			
	elif event is InputEventMouseMotion and _is_dragging:
		board.position = _drag_start_board_pos + (event.position - _drag_start_mouse_pos)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_deselect_current()

func _deselect_current() -> void:
	if _selected_piece:
		_selected_piece.set_selected(false)
		_selected_piece = null
	if _selected_card:
		_selected_card.set_selected(false)
		_selected_card = null

func _select_pair(piece: ChessPiece, card: CardUI) -> void:
	_deselect_current()
	_selected_piece = piece
	_selected_card = card
	if _selected_piece:
		_selected_piece.set_selected(true)
	if _selected_card:
		_selected_card.set_selected(true)

func _is_mouse_over_ui(mouse_pos: Vector2) -> bool:
	var left_panel = $LeftPanel
	var right_panel = $RightPanel
	if left_panel.get_global_rect().has_point(mouse_pos):
		return true
	if right_panel.get_global_rect().has_point(mouse_pos):
		return true
	return false

func _zoom_board(board: Control, mouse_pos: Vector2, zoom_delta: float) -> void:
	var old_scale = board.scale
	var new_scale_val = clamp(old_scale.x + zoom_delta, MIN_ZOOM, MAX_ZOOM)
	var new_scale = Vector2(new_scale_val, new_scale_val)
	
	if old_scale == new_scale:
		return
		
	var mouse_pos_local = (mouse_pos - board.position) / old_scale
	board.scale = new_scale
	board.position = mouse_pos - mouse_pos_local * new_scale
	
	if _is_dragging:
		_drag_start_mouse_pos = mouse_pos
		_drag_start_board_pos = board.position

func _bind_interactions() -> void:
	for i in range(min(yellow_pieces.size(), yellow_cards.size())):
		var piece = yellow_pieces[i]
		var card = yellow_cards[i]
		_connect_pair(piece, card)
		
	for i in range(min(blue_pieces.size(), blue_cards.size())):
		var piece = blue_pieces[i]
		var card = blue_cards[i]
		_connect_pair(piece, card)

func _connect_pair(piece: ChessPiece, card: CardUI) -> void:
	piece.piece_hovered.connect(func(_p): card.set_glow(true))
	piece.piece_unhovered.connect(func(_p): card.set_glow(false))
	card.card_hovered.connect(func(_c): piece.set_glow(true))
	card.card_unhovered.connect(func(_c): piece.set_glow(false))
	
	piece.piece_clicked.connect(func(_p): _select_pair(piece, card))
	card.card_clicked.connect(func(_c): _select_pair(piece, card))
