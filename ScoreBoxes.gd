
extends TileMap
# MainBoard Script

@onready var scoreboxes = get_node("/root/MainSceneRoot/ScoreBoxes/ScoreBoxesTileMap")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.
	var used_rect = scoreboxes.get_used_rect()

	var map_width = used_rect.size.x
	var map_height = used_rect.size.y

	var EscenaNumero = preload("res://ResultBox.tscn")
	var Numero = EscenaNumero.instantiate()
	
	var tile_size = Vector2(scoreboxes.tile_set.tile_size) # Obtiene el tamaño de un tile
	print(tile_size)
	var numbers_array = []
	
	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		var row = []
		
		var number = EscenaNumero.instantiate()
			
		number.editable = true
		number.visible = true
		var index = Vector2(x,1)
#		print(index)
		var cell_coords = scoreboxes.map_to_local(index)
		cell_coords.x -=   (tile_size.x) / 2
		cell_coords.y -=   (tile_size.y) / 2
		number.position = cell_coords
		scoreboxes.add_child(number)  # Añade la instancia a la escena
		row.append(number)
		numbers_array.append(row)
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

