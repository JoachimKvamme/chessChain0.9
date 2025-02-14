extends RichTextLabel
 
var all_moves = [["d4","d5"],["c4","dxc4"]]
# change variable to the one inside _ready() when things are updated
# Might need to have it signal each time a move is made


func _ready() -> void:
	var rtl = $"."

	# var all_moves = <name of variable>.<name of source node>
	rtl.text += GameManager.game_string

func _process(delta: float) -> void:
	$".".text = GameManager.game_string

func _display_moves(moves: Array):
	var moves_as_string = ""
	for moveset in moves:
		if moveset.size() > 2:
			moves_as_string += "%d,%d\n" % [moveset[0], moveset[1]]
		
	return moves_as_string
