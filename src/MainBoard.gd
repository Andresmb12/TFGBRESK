extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal b_letter_entered(letter)
signal letter_placed(letter)
@export var letters_main_board: Array
@export var tm_mainboard : TileMap
@onready var mainboard = $MainBoardTileMap
@onready var editable = false
#
func send_letter_entered(letter):
	#print("señal enviada desde tablero, letra: ", letter)
	b_letter_entered.emit(letter)
	
func set_editable_board(order):
	for n in mainboard.get_children():
		n.editable = order

func highlight_letter(pos):
	print("highlight: ",pos)
	var my_stylebox = letters_main_board[0][0].get_theme_stylebox("read_only").duplicate()
	for r in range(9):
		for c in range(9):
			if pos !=  Vector2(r,c) :
				letters_main_board[r][c].remove_theme_stylebox_override("read_only")
	await get_tree().create_timer(2).timeout
	for r in range(8):
		for c in range(8):
			letters_main_board[r][c].add_theme_stylebox_override("read_only",my_stylebox)
	
	await get_tree().create_timer(2).timeout
		
		
func handle_letter_placed(letter, letter_node):
	
	letter_placed.emit(letter)
	var my_stylebox = letter_node.get_theme_stylebox("read_only").duplicate()
	
	for n in mainboard.get_children():
		if n != letter_node:
			n.remove_theme_stylebox_override("read_only")
			
	await get_tree().create_timer(1.5).timeout
	for n in mainboard.get_children():
		n.add_theme_stylebox_override("read_only", my_stylebox)
		
	await get_tree().create_timer(2).timeout
		
func _ready():
	mainboard.set_process_input(false)
	
	var used_rect = mainboard.get_used_rect()

	var map_width = used_rect.size.x
	var map_height = used_rect.size.y

	var EscenaLetra = preload("res://scenes/Letter.tscn")
	var Letra = EscenaLetra.instantiate()
	
	var first_cell_coords = Vector2(used_rect.position.x, used_rect.position.y)
	
	var tile_size = Vector2(mainboard.tile_set.tile_size) # Obtiene el tamaño de un tile

	for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
		var column = []  # Cambio de 'row' a 'column' para representar una columna en la matriz
		for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
			var letter = EscenaLetra.instantiate()
			#letter.editable = false
			letter.visible = true
			var index = Vector2(x,y)
			var cell_coords = mainboard.map_to_local(index)
			cell_coords.x -=   (tile_size.x) / 2
			cell_coords.y -=   (tile_size.y) / 2
			letter.position = cell_coords
			mainboard.add_child(letter)  # Añade la instancia a la escena
			column.append(letter)
			letter.connect("letter_placed", self.handle_letter_placed)
			letter.connect("letter_entered", self.send_letter_entered)
		letters_main_board.append(column)  # Cambio de 'row' a 'column' para agregar la columna a la matriz

	print("El tamaño del tablero es de ", letters_main_board.size())
	

			
func _process(delta):
	
	pass

