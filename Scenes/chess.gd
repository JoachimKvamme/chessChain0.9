extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDHT = 50

const TEXTURE_HOLDER = preload("res://Scenes/texture_holder.tscn")
#
#const BLACK_BISHOP = preload("res://Assets/Chess/black_bishop.png")
#const BLACK_KING = preload("res://Assets/Chess/black_king.png")

#const BLACK_KNIGHT = preload("res://Assets/Chess/black_knight.png")
#const BLACK_PAWN = preload("res://Assets/Chess/black_pawn.png")
#const BLACK_QUEEN = preload("res://Assets/Chess/black_queen.png")
#const BLACK_ROOK = preload("res://Assets/Chess/black_rook.png")
#const WHITE_BISHOP = preload("res://Assets/Chess/white_bishop.png")
#const WHITE_KING = preload("res://Assets/Chess/white_king.png")
#const WHITE_KNIGHT = preload("res://Assets/Chess/white_knight.png")
#const WHITE_PAWN = preload("res://Assets/Chess/white_pawn.png")
#const WHITE_QUEEN = preload("res://Assets/Chess/white_queen.png")
#const WHITE_ROOK = preload("res://Assets/Chess/white_rook.png")
#

const PIECE_MOVE = preload("res://Assets/Chess/Piece_move.png")

const TURN_WHITE = preload("res://Assets/Chess/turn-white.png")
const TURN_BLACK = preload("res://Assets/Chess/turn-black.png")

const BLACK_BISHOP = preload("res://Assets/ChessOriginal/bishop-black-outlined.png")
const WHITE_BISHOP = preload("res://Assets/ChessOriginal/bishop-white-outlined.png")

const BLACK_KING = preload("res://Assets/ChessOriginal/king-black-outlined.png")
const WHITE_KING = preload("res://Assets/ChessOriginal/king-white-outlined.png")

const BLACK_KNIGHT = preload("res://Assets/ChessOriginal/knight-black-outlined.png")
const WHITE_KNIGHT = preload("res://Assets/ChessOriginal/knight-white-outlined.png")

const BLACK_PAWN = preload("res://Assets/ChessOriginal/pawn-black-outlined.png")
const WHITE_PAWN = preload("res://Assets/ChessOriginal/pawn-white-outlined.png")

const BLACK_QUEEN = preload("res://Assets/ChessOriginal/queen-black-outlined.png")
const WHITE_QUEEN = preload("res://Assets/ChessOriginal/queen-white-outlined.png")

const BLACK_ROOK = preload("res://Assets/ChessOriginal/rook-black-outlined.png")
const WHITE_ROOK = preload("res://Assets/ChessOriginal/rook-white-outlined.png")

const TILE_MARKING_BLACK_PERSPECTIVE = preload("res://Assets/ChessOriginal/tile_marking_black_perspective.png")
const TILE_MARKING_WHITE_PERSPECTIVE = preload("res://Assets/ChessOriginal/tile_marking_white_perspective.png")


@onready var pieces: Node2D = $pieces
@onready var dots: Node2D = $dots
@onready var turn: Sprite2D = $turn
@onready var white_pieces: Control = $"../CanvasLayer/white_pieces"
@onready var black_pieces: Control = $"../CanvasLayer/black_pieces"


# variables
# -6 = black king
# -5 = black queen
# -4 = black rook
# -3 = black bishop
# -2 = black knight
# -1 = black pawn
#  0
#  6 white king
#  5 white queen
#  4 white rook
#  3 white bishop
#  2 white knight
#  1 white pawn

@export var board : Array
var white : bool = true
@export var state : bool = false
var moves = []
var selected_piece : Vector2

var promotion_square = null

var white_king = false
var black_king = false
var white_rook_left = false
var white_rook_right = false
var black_rook_left = false
var black_rook_right = false

var en_passant = null

var black_king_pos = Vector2(7, 4)
var white_king_pos = Vector2(0, 4)

var fifty_move_rule = 0

var unique_board_moves : Array = []
var amount_of_same : Array = []

var move_number = 0

var line : String = ""
var row : String = ""

var capture : bool = false

var scanned_selected : String = ""

var move_was_made = false

var game_from : Array = [[]]
var game_to : Array = [[]]

var game_state : Array
var game_index : int = 0
var showing_board : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	white = true
	state = false
	moves = []

	promotion_square = null

	white_king = false
	black_king = false
	white_rook_left = false
	white_rook_right = false
	black_rook_left = false
	black_rook_right = false

	en_passant = null

	black_king_pos = Vector2(7, 4)
	white_king_pos = Vector2(0, 4)

	fifty_move_rule = 0

	unique_board_moves = []
	amount_of_same = []

	board.append([4, 2, 3, 5, 6, 3, 2, 4])
	board.append([1, 1, 1, 1, 1, 1, 1, 1])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([-1, -1, -1, -1, -1, -1, -1, -1])
	board.append([-4, -2, -3, -5, -6, -3, -2, -4])
	
	game_state.append(board)
	
	display_board()
	
	var white_buttons = get_tree().get_nodes_in_group("white_pieces")
	var black_buttons = get_tree().get_nodes_in_group("black_pieces")
	
	for button in white_buttons:
		button.pressed.connect(self._on_button_pressed.bind(button))

	for button in black_buttons:
		button.pressed.connect(self._on_button_pressed.bind(button))



func _input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseButton && event.is_pressed() && promotion_square == null:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if is_mouse_out(): return
				var var1 = snapped(get_global_mouse_position().x, 0) / CELL_WIDHT
				var var2 = abs(snapped(get_global_mouse_position().y, 0) / CELL_WIDHT)
				if !state && (white && board[var2][var1] > 0 || !white && board[var2][var1] < 0):
					move_was_made = false
					capture = false
					selected_piece = Vector2(var2, var1)
					print(var2, var1)
					show_options()
					scanned_selected = scan_selected_piece(var2, var1)
					state = true
				elif state:
					set_moves(var2, var1)
					if scan_move(var2, var1) != null && move_was_made:
						display_game()
						append_move(var2, var1)
						
					
		if event is InputEventKey and event.is_pressed():
			if event.keycode == KEY_R:
				print("R")
				reset()
					
		if event is InputEventKey and event.is_pressed():
			if event.keycode == KEY_P:
				play_from_input("Ng1", "Nf3")

func _process(delta: float) -> void:
	display_board()



func play_from_input(from : String, to : String):
	var var1
	var var2
	
	var2 = parsed_move(from).x
	var1 = parsed_move(from).y
	
	if !state && (white && board[var2][var1] > 0 || !white && board[var2][var1] < 0):
	
		print(parsed_move("e4"))
		selected_piece = parsed_move(from)
		show_options()
		state = true
	elif state:
		var2 = parsed_move(to).x
		var1 = parsed_move(to).y
		set_moves(var2, var1)

func reset():
	white = true
	state = false
	moves = []

	promotion_square = null

	white_king = false
	black_king = false
	white_rook_left = false
	white_rook_right = false
	black_rook_left = false
	black_rook_right = false

	en_passant = null

	black_king_pos = Vector2(7, 4)
	white_king_pos = Vector2(0, 4)

	fifty_move_rule = 0

	unique_board_moves = []
	amount_of_same = []
	game_index = 0
	
	board = [[4, 2, 3, 5, 6, 3, 2, 4],
	[1, 1, 1, 1, 1, 1, 1, 1],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-4, -2, -3, -5, -6, -3, -2, -4]]
	
	display_board()
			
func is_mouse_out():
	#if get_global_mouse_position().x < 0 || get_global_mouse_position().x > 144 || get_global_mouse_position().y > 0 || get_global_mouse_position().y < -144: return true
	if get_rect().has_point(to_local(get_global_mouse_position())): return false
	return true
	
func display_board():
	
	for child in pieces.get_children():
		child.queue_free()
	
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			holder.global_position = Vector2(j * CELL_WIDHT + (CELL_WIDHT / 2), -i * CELL_WIDHT - (CELL_WIDHT / 2))
			
			match board[i][j]:
				-6: holder.texture = BLACK_KING
				-5: holder.texture = BLACK_QUEEN
				-4: holder.texture = BLACK_ROOK
				-3: holder.texture = BLACK_BISHOP
				-2: holder.texture = BLACK_KNIGHT
				-1: holder.texture = BLACK_PAWN
				0: holder.texture = null
				6: holder.texture = WHITE_KING
				5: holder.texture = WHITE_QUEEN
				4: holder.texture = WHITE_ROOK
				3: holder.texture = WHITE_BISHOP
				2: holder.texture = WHITE_KNIGHT
				1: holder.texture = WHITE_PAWN
				
	if white: turn.texture = TURN_WHITE
	else: turn.texture = TURN_BLACK

func show_options():
	moves = get_moves(selected_piece)
	if moves == []:
		state = false
		return
	show_dots()

func show_dots():
	for i in moves:
		var holder = TEXTURE_HOLDER.instantiate()
		dots.add_child(holder)
		holder.texture = PIECE_MOVE
		holder.global_position = Vector2(i.y * CELL_WIDHT  + (CELL_WIDHT / 2), -i.x * CELL_WIDHT - (CELL_WIDHT / 2))
		
func delete_dots():
	for child in dots.get_children():
		child.queue_free()

func set_moves(var2, var1):
	
	var just_now = false
	
	for i in moves:
		if i.x == var2 && i.y == var1:
			fifty_move_rule += 1
			if is_enemy(Vector2(var2, var1)):
				fifty_move_rule = 0
			match board[selected_piece.x][selected_piece.y]:
				1: 
					fifty_move_rule = 0
					if i.x == 7: promote(i)
					if i.x == 3 && selected_piece.x == 1:
						en_passant = i
						just_now = true
					elif en_passant != null:
						if en_passant.y == i.y && selected_piece.y != i.y && en_passant.x == selected_piece.x:
							board[en_passant.x][en_passant.y] = 0
							capture = true
						
					
				-1:
					fifty_move_rule = 0
					if i.x == 0: promote(i)
					if i.x == 4 && selected_piece.x == 6:
						en_passant = i
						just_now = true
					elif en_passant != null:
						if en_passant.y == i.y && selected_piece.y != i.y && en_passant.x == selected_piece.x:
							board[en_passant.x][en_passant.y] = 0
							capture = true
				4:
					if selected_piece.x == 0 && selected_piece.y == 0: white_rook_left = true
					elif selected_piece.x == 0 && selected_piece.y == 7: white_rook_right = true
				-4:
					if selected_piece.x == 7 && selected_piece.y == 0: black_rook_left = true
					elif selected_piece.x == 7 && selected_piece.y == 7: black_rook_right = true
				
				6:
					if selected_piece.x == 0 && selected_piece.y == 4:
						white_king = true
						if i.y == 2:
							white_rook_left = true
							white_rook_right = true
							board[0][0] = 0
							board[0][3] = 4
						elif i.y == 6:
							white_rook_left = true
							white_rook_right = true
							board[0][7] = 0
							board[0][5] = 4
							
					white_king_pos = i
				-6: 
					if selected_piece.x == 7 && selected_piece.y == 4:
						black_king = true
						if i.y == 2:
							black_rook_left = true
							black_rook_right = true
							board[7][0] = 0
							board[7][3] = -4
						elif i.y == 6:
							black_rook_left = true
							black_rook_right = true
							board[7][7] = 0
							board[7][5] = -4
					black_king_pos = i
			if !just_now: en_passant = null
			if (white && board[var2][var1] < 0) || (!white && board[var2][var1] > 0):
				capture = true
			board[var2][var1] = board[selected_piece.x][selected_piece.y]
			board[selected_piece.x][selected_piece.y] = 0
			white = !white
			threefold_repetition(board)
			display_board()
			break
	delete_dots()
	
	state = false
	move_was_made = true
	
	if (selected_piece.x != var2 || selected_piece.y != var1) && (white && board[var2][var1] > 0 || !white && board[var2][var1] < 0):
		selected_piece = Vector2(var2, var1)
		show_options()
		state = true 
	
	elif is_stalemate():
		if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos): print("Checkmate!")
		else: print("Stalemate!")
		
	if fifty_move_rule == 50: print("Draw!")
	elif insufficient_material(): print("Draw!")
			

func get_moves(selected : Vector2):
	var _moves = []
	
	match abs(board[selected.x][selected.y]):
		1: _moves = get_pawn_moves(selected)
		2: _moves = get_knight_moves(selected)
		3: _moves = get_bishop_moves(selected)
		4: _moves = get_rook_moves(selected)
		5: _moves = get_queen_moves(selected)
		6: _moves = get_king_moves(selected)
	
	return _moves

func get_rook_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]
	
	for i in directions:
		var pos = piece_position
		pos += i
		while is_valid_position(pos):
			if is_empty(pos): 
				board[pos.x][pos.y] = 4 if white else -4
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
				board[pos.x][pos.y] = 0
				board[piece_position.x][piece_position.y] = 4 if white else -4
			elif is_enemy(pos):
				var t = board[pos.x][pos.y]
				board[pos.x][pos.y] = 4 if white else -4
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
				board[pos.x][pos.y] = t
				board[piece_position.x][piece_position.y] = 4 if white else -4
				break
			else: break
			
			pos += i
	
	return _moves
	
func get_bishop_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	for i in directions:
		var pos = piece_position
		pos += i
		while is_valid_position(pos):
			if is_empty(pos):
				board[pos.x][pos.y] = 3 if white else -3
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
				board[pos.x][pos.y] = 0
				board[piece_position.x][piece_position.y] = 3 if white else -3
			elif is_enemy(pos):
				var t = board[pos.x][pos.y]
				board[pos.x][pos.y] = 3 if white else -3
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
				board[pos.x][pos.y] = t
				board[piece_position.x][piece_position.y] = 3 if white else -3
				break
			else: break
			
			pos += i
	
	return _moves
	
func get_queen_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
	Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	for i in directions:
		var pos = piece_position
		pos += i
		while is_valid_position(pos):
			if is_empty(pos):
				board[pos.x][pos.y] = 5 if white else -5
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
				board[pos.x][pos.y] = 0
				board[piece_position.x][piece_position.y] = 5 if white else -5
			elif is_enemy(pos):
				var t = board[pos.x][pos.y]
				board[pos.x][pos.y] = 5 if white else -5
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
				board[pos.x][pos.y] = t
				board[piece_position.x][piece_position.y] = 5 if white else -5
				break
			else: break
			
			pos += i
	
	return _moves
func get_king_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(0,1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
	Vector2(1,1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	if white:
		board[white_king_pos.x][white_king_pos.y] = 0
	else:
		board[black_king_pos.x][black_king_pos.y] = 0
	
	for i in directions:
		var pos = piece_position + i
		if is_valid_position(pos):
			if !is_in_check(pos):
				if is_empty(pos): _moves.append(pos)
				elif is_enemy(pos): 
					_moves.append(pos)
				
				
	if white && !white_king:
		if !white_rook_left && is_empty(Vector2(0, 1)) && is_empty(Vector2(0, 2)) && !is_in_check(Vector2(0, 2)) && is_empty(Vector2(0, 3)) && !is_in_check(Vector2(0, 3)) && !is_in_check(Vector2(0, 4)):
			_moves.append(Vector2(0, 2))
		if !white_rook_right && !is_in_check(Vector2(0, 4)) && is_empty(Vector2(0, 5)) && !is_in_check(Vector2(0, 5)) && is_empty(Vector2(0, 6)) && !is_in_check(Vector2(0, 6)):
			_moves.append(Vector2(0, 6))
	elif !white && !black_king:
		if !black_rook_left && is_empty(Vector2(7, 1)) && is_empty(Vector2(7, 2)) && !is_in_check(Vector2(7, 2)) && is_empty(Vector2(7, 3)) && !is_in_check(Vector2(7, 3)) && !is_in_check(Vector2(7, 4)):
			_moves.append(Vector2(7, 2))
		if !black_rook_right && !is_in_check(Vector2(7, 4)) && is_empty(Vector2(7, 5)) && !is_in_check(Vector2(7, 5)) && is_empty(Vector2(7, 6)) && !is_in_check(Vector2(7, 6)):
			_moves.append(Vector2(7, 6))
	
	if white:
		board[white_king_pos.x][white_king_pos.y] = 6
	else:
		board[black_king_pos.x][black_king_pos.y] = -6
	
	return _moves
	
func get_knight_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(2, 1), Vector2(2, -1), Vector2(1, 2), Vector2(1, -2),
	Vector2(-2, 1), Vector2(-2, -1), Vector2(-1, 2), Vector2(-1, -2)]
	
	for i in directions:
		var pos = piece_position + i
		if is_valid_position(pos):
			if is_empty(pos):
				board[pos.x][pos.y] = 2 if white else -2
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
				board[pos.x][pos.y] = 0
				board[piece_position.x][piece_position.y] = 2 if white else -2
			elif is_enemy(pos):
				var t = board[pos.x][pos.y]
				board[pos.x][pos.y] = 2 if white else -2
				board[piece_position.x][piece_position.y] = 0
				if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
				board[pos.x][pos.y] = t
				board[piece_position.x][piece_position.y] = 2 if white else -2
	
	return _moves

func get_pawn_moves(piece_position : Vector2):
	var _moves = []
	var direction
	var is_first_move = false
	
	if white: direction = Vector2(1, 0)
	else: direction = Vector2(-1, 0)
	
	if white && piece_position.x == 1 || !white && piece_position.x == 6: is_first_move = true
	
	if en_passant != null && (white && piece_position.x == 4 || !white && piece_position.x == 3) && abs(en_passant.y - piece_position.y) == 1:
		var pos = en_passant + direction
		board[pos.x][pos.y] = 1 if white else -1
		board[piece_position.x][piece_position.y] = 0
		board[en_passant.x][en_passant.y] = 0
		if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
		board[pos.x][pos.y] = 0
		board[piece_position.x][piece_position.y] = 1 if white else -1
		board[en_passant.x][en_passant.y] = -1 if white else 1
	
	var pos = piece_position + direction
	if is_empty(pos):
		board[pos.x][pos.y] = 1 if white else -1
		board[piece_position.x][piece_position.y] = 0
		if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
		board[pos.x][pos.y] = 0
		board[piece_position.x][piece_position.y] = 1 if white else -1
	
	pos = piece_position + Vector2(direction.x, 1)
	if is_valid_position(pos):
		if is_enemy(pos):
			var t = board[pos.x][pos.y]
			board[pos.x][pos.y] = 1 if white else -1
			board[piece_position.x][piece_position.y] = 0
			if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
			board[pos.x][pos.y] = t
			board[piece_position.x][piece_position.y] = 1 if white else -1
	pos = piece_position + Vector2(direction.x, -1)
	if is_valid_position(pos):
		if is_enemy(pos):
			var t = board[pos.x][pos.y]
			board[pos.x][pos.y] = 1 if white else -1
			board[piece_position.x][piece_position.y] = 0
			if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
			board[pos.x][pos.y] = t
			board[piece_position.x][piece_position.y] = 1 if white else -1
		
	pos = piece_position + direction * 2
	if is_first_move && is_empty(pos) && is_empty(piece_position + direction):
		board[pos.x][pos.y] = 1 if white else -1
		board[piece_position.x][piece_position.y] = 0
		if white && !is_in_check(white_king_pos) || !white && !is_in_check(black_king_pos): _moves.append(pos)
		board[pos.x][pos.y] = 0
		board[piece_position.x][piece_position.y] = 1 if white else -1
	
	return _moves
	

func is_valid_position(pos : Vector2):
	if pos.x >= 0 && pos.x < BOARD_SIZE && pos.y >= 0 && pos.y < BOARD_SIZE: return true
	return false
	
func is_empty(pos : Vector2):
	if board[pos.x][pos.y] == 0: return true
	return false

func is_enemy(pos : Vector2):
	if white && board[pos.x][pos.y] < 0 || !white && board[pos.x][pos.y] > 0: return true
	return false

func promote(_var : Vector2):
	promotion_square = _var
	white_pieces.visible = white
	black_pieces.visible = !white
	
func _on_button_pressed(button):
	var num_char = int(button.name.substr(0, 1))
	board[promotion_square.x][promotion_square.y] = -num_char if white else num_char
	white_pieces.visible = false
	black_pieces.visible = false
	promotion_square = null
	display_board()
	
func is_in_check(king_pos : Vector2):
	var directions = [Vector2(0,1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
	Vector2(1,1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	var pawn_direction = 1 if white else -1
	var pawn_attacks =  [
		king_pos + Vector2(pawn_direction, 1),
		king_pos + Vector2(pawn_direction, -1)]
	
	for i in pawn_attacks:
		if is_valid_position(i):
			if(white && board[i.x][i.y] == -1 || !white && board[i.x][i.y] == 1): 
				return true
			
	for i in directions:
		var pos = king_pos + i
		if is_valid_position(pos):
			if white && board[pos.x][pos.y] == -6 || white && board[pos.x][pos.y] == 6: 
				return true
	
	for i in directions:
		var pos = king_pos + i
		while is_valid_position(pos):
			if !is_empty(pos):
				var piece = board[pos.x][pos.y]
				if (i.x == 0 || i.y == 0) && (white && piece in [-4, -5] || !white && piece in [4, 5]):
					return true
				elif (i.x != 0 && i.y != 0) && (white && piece in [-3, -5] || !white && piece in [3, 5]):
					return true
				break
			pos += i
	
	var knight_directions = [Vector2(2,1), Vector2(2, -1), Vector2(1, 2), Vector2(1, -2),
	Vector2(-2,1), Vector2(-2, -1), Vector2(-1, 2), Vector2(-1, -2)]
	
	for i in knight_directions:
		var pos = king_pos + i
		if is_valid_position(pos):
			if white && board[pos.x][pos.y] == -2 || !white && board[pos.x][pos.y] == 2:
				return true
	
	return false
				
	
func is_stalemate():
	if white:
		for i in BOARD_SIZE:
			for j in BOARD_SIZE:
				if board[i][j] > 0:
					if get_moves(Vector2(i, j)) != []: return false
	else:
		for i in BOARD_SIZE:
			for j in BOARD_SIZE:
				if board[i][j] < 0:
					if get_moves(Vector2(i, j)) != []: return false
	return true
	
func is_checkmate():
	if is_stalemate() && (white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos)): return true

func insufficient_material():
	var white_piece = 0
	var black_piece = 0
	
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			match board[i][j]:
				2, 3: 
					if white_piece == 0: white_piece += 1
					else: return false
				-2, -3:
					if black_piece == 0: black_piece += 1
					else: return false
				6, -6, 0: pass
				_:
					return false
				
	return true
	
func threefold_repetition(var1 : Array):
	for i in unique_board_moves.size():
		if var1 == unique_board_moves[i]:
			amount_of_same[i] += 1
			if amount_of_same[i] >= 3: print("Draw!")
			return
	unique_board_moves.append(var1.duplicate(true))
	amount_of_same.append(1)
	
	
func append_move(var2, var1):
	if !white:
		GameManager.game.append([])
		game_index += 1
	var played_move
	played_move = scan_move(var2, var1)
	GameManager.game[game_index].append(played_move)
	
func append_selected(played_move):
	if !white:
		game_from.append([])

	game_from[game_index].append(played_move)
	
	

func display_game():
	var game_string = ""
	var i = 1
	
	while i < game_to.size():
		game_string = game_string + "\n" + str(i) + ". "
		for x in game_to[i]:
			if game_to.size() % 2 != 0:
				game_string = game_string + x
			else:
				game_string = game_string + " " + x
		i = i + 1
	print(game_string)
		
		
		
	
func scan_move(var2, var1):
	var moves : Array
	var parsed_move
	
	if state: return
	
	if board[var2][var1] == 1 || board[var2][var1] == -1:
		if capture:
			if is_checkmate():
				return scanned_selected + "x" + scanned_capture(var2,var1) + "++"
			if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos):
				return pawn_move(var2, var1) + "+"
			return scanned_selected + "x" + scanned_capture(var2, var1)
		if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos):
			parsed_move = pawn_move(var2, var1) + "+"
		if is_checkmate():
				return pawn_move(var2, var1) + "++"
		else:
			return pawn_move(var2, var1)  
		
	if board[var2][var1] == 2 || board[var2][var1] == -2:
		if capture:
			if is_checkmate():
				return scanned_selected + "x" + scanned_capture(var2,var1) + "++"
			if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos):
				return knight_move(var2, var1) + "+"
			return scanned_selected + "x" + scanned_capture(var2, var1)
		if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos):
			return knight_move(var2, var1) + "+"
		if is_checkmate():
				return knight_move(var2, var1) + "++"
		else:
			return knight_move(var2, var1)
	if board[var2][var1] == 3 || board[var2][var1] == -3:
		if capture:
			if is_checkmate():
				return scanned_selected + "x" + scanned_capture(var2,var1) + "++"
			if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos):
				return scanned_selected + "x" + scanned_capture(var2,var1) + "+"
			return scanned_selected + "x" + scanned_capture(var2, var1)
		if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos):
			return bishop_move(var2, var1) + "+"
		if is_checkmate():
				return bishop_move(var2, var1) + "++"
		else:
			return bishop_move(var2, var1)
			
	if board[var2][var1] == 4 || board[var2][var1] == -4 :
		if capture:
			if is_checkmate():
				return scanned_selected + "x" + scanned_capture(var2,var1) + "++"
			if (white && is_in_check(white_king_pos)) || (!white && is_in_check(black_king_pos)):
				return scanned_selected + "x" + scanned_capture(var2, var1) + "+"
			return scanned_selected + "x" + scanned_capture(var2, var1)
		if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos):
			return rook_move(var2, var1) + "+"
		if white && is_checkmate() || !white && is_checkmate():
			return rook_move(var2, var1) + "++"
		else:
			return rook_move(var2, var1)
	if board[var2][var1] == 5 || board[var2][var1] == -5:
		if capture:
			if is_checkmate():
				return scanned_selected + "x" + scanned_capture(var2,var1) + "++"
			if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos):
				return scanned_selected + "x" + scanned_capture(var2,var1) + "+"
			return scanned_selected + "x" + scanned_capture(var2, var1)
		if white && is_in_check(white_king_pos) || !white && is_in_check(black_king_pos):
			return queen_move(var2, var1) + "+"
		if is_checkmate():
				return queen_move(var2, var1) + "++"
		else:
			return queen_move(var2, var1)
	if board[var2][var1] == 6 || board[var2][var1] == -6:
		if capture:
			return scanned_selected + "x" + scanned_capture(var2, var1)
		if scanned_selected == "Ke1" && king_move(var2, var1) == "Kg1" || scanned_selected == "Ke8" && king_move(var2, var1) == "Kg8":
			return "0-0"
		if scanned_selected == "Ke1" && king_move(var2, var1) == "Kc1" || scanned_selected == "Ke8" && king_move(var2, var1) == "Kc8":
			return "0-0-0"
		else:
			parsed_move = king_move(var2, var1)
			return parsed_move
	
	return parsed_move
	

func parsed_move(algebraic_move : String):
	match algebraic_move.substr(0,1):
		"a":
			return parsed_pawn_move(algebraic_move)
		"b":
			return parsed_pawn_move(algebraic_move)
		"c":
			return parsed_pawn_move(algebraic_move)
		"d":
			return parsed_pawn_move(algebraic_move)
		"e":
			return parsed_pawn_move(algebraic_move)
		"f":
			return parsed_pawn_move(algebraic_move)
		"g":
			return parsed_pawn_move(algebraic_move)
		"h":
			return parsed_pawn_move(algebraic_move)
		"K":
			return parsed_piece_move(algebraic_move)
		"Q":
			return parsed_piece_move(algebraic_move)
		"B":
			return parsed_piece_move(algebraic_move)
		"N":
			return parsed_piece_move(algebraic_move)
		
	
		
func parsed_pawn_move(algebraic_move):
	var move : Vector2
	var row : float
	var line : float
	match algebraic_move.substr(0,1):
		"a":
			row = 0
		"b":
			row = 1
		"c":
			row = 2
		"d":
			row = 3
		"e":
			row = 4
		"f":
			row = 5
		"g":
			row = 6
		"h":
			row = 7
	match algebraic_move.substr(1, 1):
			"1":
				line = 0
			"2":
				line = 1
			"3":
				line = 2
			"4":
				line = 3
			"5":
				line = 4
			"6":
				line = 5
			"7":
				line = 6
			"8":
				line = 7
	
	move = Vector2(line, row)
	return move
func parsed_piece_move(algebraic_move : String):
	var move : Vector2
	var row : float
	var line : float
	match algebraic_move.substr(1,1):
		"a":
			row = 0
		"b":
			row = 1
		"c":
			row = 2
		"d":
			row = 3
		"e":
			row = 4
		"f":
			row = 5
		"g":
			row = 6
		"h":
			row = 7
	match algebraic_move.substr(2, 1):
			"1":
				line = 0
			"2":
				line = 1
			"3":
				line = 2
			"4":
				line = 3
			"5":
				line = 4
			"6":
				line = 5
			"7":
				line = 6
			"8":
				line = 7
	
	move = Vector2(line, row)
	return move
	
func scan_selected_piece(var2, var1):
	if board[var2][var1] == 1 || board[var2][var1] == -1:
		return pawn_move(var2, var1)
	if board[var2][var1] == 2 || board[var2][var1] == -2:
		return knight_move(var2, var1)
	if board[var2][var1] == 3 || board[var2][var1] == -3:
		return bishop_move(var2, var1)
	if board[var2][var1] == 4 || board[var2][var1] == -4:
		return rook_move(var2, var1)
	if board[var2][var1] == 5 || board[var2][var1] == -5:
		return queen_move(var2, var1)
	if board[var2][var1] == 6 || board[var2][var1] == -6:
		return king_move(var2, var1)
	

func scanned_capture(var2, var1):
		match var2:
			0:
				line = "1"
			1:
				line = "2"
			2:
				line = "3"
			3:
				line = "4"
			4:
				line = "5"
			5:
				line = "6"
			6:
				line = "7"
			7:
				line = "8"
		match var1:
			0:
				row = "a"
			1:
				row = "b"
			2:
				row = "c"
			3:
				row = "d"
			4:
				row = "e"
			5:
				row = "f"
			6:
				row = "g"
			7:
				row = "h"
		return row + line

func pawn_move(var2, var1):

		match var2:
			0:
				line = "1"
			1:
				line = "2"
			2:
				line = "3"
			3:
				line = "4"
			4:
				line = "5"
			5:
				line = "6"
			6:
				line = "7"
			7:
				line = "8"
		match var1:
			0:
				row = "a"
			1:
				row = "b"
			2:
				row = "c"
			3:
				row = "d"
			4:
				row = "e"
			5:
				row = "f"
			6:
				row = "g"
			7:
				row = "h"
		return row + line
		
func knight_move(var2, var1):
		match var2:
			0:
				line = "1"
			1:
				line = "2"
			2:
				line = "3"
			3:
				line = "4"
			4:
				line = "5"
			5:
				line = "6"
			6:
				line = "7"
			7:
				line = "8"
		match var1:
			0:
				row = "Na"
			1:
				row = "Nb"
			2:
				row = "Nc"
			3:
				row = "Nd"
			4:
				row = "Ne"
			5:
				row = "Nf"
			6:
				row = "Ng"
			7:
				row = "Nh"
		return row + line
func bishop_move(var2, var1):
		match var2:
			0:
				line = "1"
			1:
				line = "2"
			2:
				line = "3"
			3:
				line = "4"
			4:
				line = "5"
			5:
				line = "6"
			6:
				line = "7"
			7:
				line = "8"
		match var1:
			0:
				row = "Ba"
			1:
				row = "Bb"
			2:
				row = "Bc"
			3:
				row = "Bd"
			4:
				row = "Be"
			5:
				row = "Bf"
			6:
				row = "Bg"
			7:
				row = "Bh"
		return row + line
		
func rook_move(var2, var1):
		match var2:
			0:
				line = "1"
			1:
				line = "2"
			2:
				line = "3"
			3:
				line = "4"
			4:
				line = "5"
			5:
				line = "6"
			6:
				line = "7"
			7:
				line = "8"
		match var1:
			0:
				row = "Ra"
			1:
				row = "Rb"
			2:
				row = "Rc"
			3:
				row = "Rd"
			4:
				row = "Re"
			5:
				row = "Rf"
			6:
				row = "Rg"
			7:
				row = "Rh"
		return row + line
		
func queen_move(var2, var1):
		match var2:
			0:
				line = "1"
			1:
				line = "2"
			2:
				line = "3"
			3:
				line = "4"
			4:
				line = "5"
			5:
				line = "6"
			6:
				line = "7"
			7:
				line = "8"
		match var1:
			0:
				row = "Qa"
			1:
				row = "Qb"
			2:
				row = "Qc"
			3:
				row = "Qd"
			4:
				row = "Qe"
			5:
				row = "Qf"
			6:
				row = "Qg"
			7:
				row = "Qh"
		return row + line
func king_move(var2, var1):
		match var2:
			0:
				line = "1"
			1:
				line = "2"
			2:
				line = "3"
			3:
				line = "4"
			4:
				line = "5"
			5:
				line = "6"
			6:
				line = "7"
			7:
				line = "8"
		match var1:
			0:
				row = "Ka"
			1:
				row = "Kb"
			2:
				row = "Kc"
			3:
				row = "Kd"
			4:
				row = "Ke"
			5:
				row = "Kf"
			6:
				row = "Kg"
			7:
				row = "Kh"
		return row + line

	
	
	
	
