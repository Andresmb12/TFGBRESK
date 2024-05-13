extends Node2D
# MainBoard Script
@onready var scoreboard = $ScoreBoard
@export var n_scoreboard : TileMap
@onready var letters_noted
# Called when the node enters the scene tree for the first time.

func set_editable_board(order):
	for n in scoreboard.get_children():
		n.editable = order
		n.focus_mode = Control.FOCUS_NONE
		
func note_new_letter(letter, pos):
	letters_noted[pos.x][pos.y].text = letter
		
func _ready():
	
	set_editable_board(false)
	pass # Replace with function body.
	var used_rect = scoreboard.get_used_rect()

	var map_width = used_rect.size.x
	var map_height = used_rect.size.y

	var EscenaNumero = preload("res://scenes/Number.tscn")
	
	
	var tile_size = Vector2(scoreboard.tile_set.tile_size) # Obtiene el tamaño de un tile
	
	var letters_noted_array = []
	
	for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
		var column = []  # Cambio de 'row' a 'column' para representar una columna en la matriz
		for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
			var number = EscenaNumero.instantiate()
			number.editable = true
			number.visible = true
			var index = Vector2(x,y)	
			var cell_coords = scoreboard.map_to_local(index)
			cell_coords.x -=   (tile_size.x) / 2
			cell_coords.y -=   (tile_size.y) / 2
			number.position = cell_coords
			scoreboard.add_child(number)  # Añade la instancia a la escena
			column.append(number)  # Cambio de 'row' a 'column' para agregar a la columna
		letters_noted_array.append(column)  # Cambio de 'row' a 'column' para agregar la columna a la matriz

	n_scoreboard = scoreboard	
	letters_noted = letters_noted_array

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
