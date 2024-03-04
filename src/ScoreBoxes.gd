
extends Node2D
# MainBoard Script

@onready var scoreboxes = $ScoreBoxesTileMap
@onready var numbers_array = []
@export var v_scores : Array = Array()
# Called when the node enters the scene tree for the first time.

func set_editable_board(order):
	for n in scoreboxes.get_children():
		n.editable = order
		
func _ready():
	
	pass # Replace with function body.
	var used_rect = scoreboxes.get_used_rect()

	var map_width = used_rect.size.x
	var map_height = used_rect.size.y

	var EscenaNumero = preload("res://scenes/ResultBox.tscn")
	
	var tile_size = Vector2(scoreboxes.tile_set.tile_size) # Obtiene el tamaño de un tile
	print(tile_size)
	
	
	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		var row = []
		
		var number = EscenaNumero.instantiate()
			
		number.editable = false
		number.visible = true
		var index = Vector2(x,1)
#		
		var cell_coords = scoreboxes.map_to_local(index)
		cell_coords.x -=   (tile_size.x) / 2
		cell_coords.y -=   (tile_size.y) / 2
		number.position = cell_coords
		scoreboxes.add_child(number)  # Añade la instancia a la escena
		row.append(number)
		numbers_array.append(row)
		
	v_scores = numbers_array
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

