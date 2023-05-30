extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var mainboard = get_node("/root/MainBoard/MainBoardTileMap")

#
func _ready():
	print(mainboard.name)
	var used_rect = mainboard.get_used_rect()

	var map_width = used_rect.size.x
	var map_height = used_rect.size.y
	
	print("Anchura del TileMap: ", map_width)
	print("Altura del TileMap: ", map_height)
	
	var EscenaLetra = preload("res://Letter.tscn")
	var Letra = EscenaLetra.instantiate()
	
	var cell = mainboard.get_used_cells(0)[1]
	
	var cell_size = mainboard.get_quadrant_size()
	
	var cell_index = Vector2(0, 0)  # Índice de la casilla que deseas calcular

	var pos = mainboard.map_to_local(cell)

	
	

	Letra.position = pos
	mainboard.add_child(Letra)

