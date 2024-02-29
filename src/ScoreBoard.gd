extends Node2D
# MainBoard Script
@onready var scoreboard = $ScoreBoard
@export var n_scoreboard : TileMap
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.
	var used_rect = scoreboard.get_used_rect()

	var map_width = used_rect.size.x
	var map_height = used_rect.size.y

	var EscenaNumero = preload("res://scenes/Number.tscn")
	
	
	var tile_size = Vector2(scoreboard.tile_set.tile_size) # Obtiene el tamaño de un tile
	print(tile_size)
	var numbers_array = []
	
	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		var row = []
		for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
			var number = EscenaNumero.instantiate()
			
			number.editable = false
			number.visible = true
			var index = Vector2(x,y)
#			print(index)
			var cell_coords = scoreboard.map_to_local(index)
			cell_coords.x -=   (tile_size.x) / 2
			cell_coords.y -=   (tile_size.y) / 2
			number.position = cell_coords
			scoreboard.add_child(number)  # Añade la instancia a la escena
			row.append(number)
		numbers_array.append(row)
	n_scoreboard = scoreboard	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
