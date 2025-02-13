extends RichTextLabel
 
var all_moves = [["d4","d5"],["c4","dxc4"]]
# change variable to the one inside _ready() when things are updated
# Might need to have it signal each time a move is made

func _ready() -> void:
	# var all_moves = <name of variable>.<name of source node>
	_display_moves(all_moves) 


func _display_moves(moves: Array) -> void:
	var moves_as_string = ""
	for moveset in moves:
		moves_as_string += "%d,%d\n" % [moveset[0], moveset[1]]
		
	text = moves_as_string
