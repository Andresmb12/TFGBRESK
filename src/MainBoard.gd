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
	print("señal enviada desde tablero, letra: ", letter)
	b_letter_entered.emit(letter)
	
func set_editable_board(order):
	for n in mainboard.get_children():
		n.editable = order
		
func handle_letter_placed(letter):
	letter_placed.emit(letter)
		
func _ready():
	mainboard.set_process_input(false)
	var used_rect = mainboard.get_used_rect()

	var map_width = used_rect.size.x
	var map_height = used_rect.size.y

	var EscenaLetra = preload("res://scenes/Letter.tscn")
	var Letra = EscenaLetra.instantiate()
	
	var first_cell_coords = Vector2(used_rect.position.x, used_rect.position.y)
	
	var tile_size = Vector2(mainboard.tile_set.tile_size) # Obtiene el tamaño de un tile
	
	
	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		var row = []
		for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
			var letter = EscenaLetra.instantiate()
			
			letter.editable = false
			letter.visible = true
			var index = Vector2(x,y)
			var cell_coords = mainboard.map_to_local(index)
			cell_coords.x -=   (tile_size.x) / 2
			cell_coords.y -=   (tile_size.y) / 2
			letter.position = cell_coords
			mainboard.add_child(letter)  # Añade la instancia a la escena
			row.append(letter)
			letter.connect("letter_placed", self.handle_letter_placed)
			letter.connect("letter_entered", self.send_letter_entered)
		letters_main_board.append(row)
	print("El tamaño del tablero es de " , letters_main_board.size())
	tm_mainboard = mainboard

			
func _process(delta):
	
	pass

