extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var mainboard = get_node("/root/MainRoot/MainBoardRoot/MainBoardTileMap")

#
func _ready():
	print(mainboard.name)
	var used_rect = mainboard.get_used_rect()

	var map_width = used_rect.size.x
	var map_height = used_rect.size.y

	var EscenaLetra = preload("res://Letter.tscn")
	var Letra = EscenaLetra.instantiate()
	
	var first_cell_coords = Vector2(used_rect.position.x, used_rect.position.y)
	print("tamaño: ", used_rect.size)
	var tile_size = Vector2(mainboard.tile_set.tile_size) # Obtiene el tamaño de un tile
	print(tile_size)
	var letters_array = []
	print("yeah", Vector2(used_rect.position.x, used_rect.position.y))
	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		var row = []
		for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
			var letter = EscenaLetra.instantiate()
			
			letter.editable = false
			letter.visible = true
			var index = Vector2(x,y)
#			print(index)
			var cell_coords = mainboard.map_to_local(index)
			cell_coords.x -=   (tile_size.x) / 2
			cell_coords.y -=   (tile_size.y) / 2
			letter.position = cell_coords
			mainboard.add_child(letter)  # Añade la instancia a la escena
			row.append(letter)
		letters_array.append(row)
		
#	letters_array[0][1].editable = false
	

