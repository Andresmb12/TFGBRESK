extends Node
var BOARD_LIMIT = 8
var vowels = ["A", "E", "I", "O", "U"]
var consonants = [ "B", "C", "D", "F", "G","H", "J", "K", "L", "M", 
"N", "P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z" ]
var space = "#"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func is_vowel(letter):
	OS.get_cache_dir()
	return letter in vowels
	
func is_consonant(letter):
	return letter in consonants
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func get_letter(row,col,mainboard):
	return mainboard[row][col].text

func get_space_in_line(pos, orient, mainboard):
	var col = (pos.y) 
	var row = (pos.x) 
	var done = false
	var space = 0
	if orient == "HORIZONTAL" and (pos.y==0 or get_letter(row,pos.y-1,mainboard) == "#"):
		while col < BOARD_LIMIT and !done:
			col += 1
			if get_letter(row,col,mainboard).is_empty():
				space += 1
			else:
				done = true
		done = true
	if orient == "VERTICAL" and (pos.x==0 or get_letter(pos.x-1,col,mainboard) == "#"):
		while row < BOARD_LIMIT and !done:
			row  += 1
			if get_letter(row,col,mainboard).is_empty():
				space += 1
			else:
				#possible TW beginning
				done = true
		done = true
	if space == 1:
		space = 0
	return space
	
func find_first_valid_position(mainboard):
	var next_pos = Vector2(-1, -1) # Variable local para almacenar la posición encontrada

	for r in range(BOARD_LIMIT):
		for c in range(BOARD_LIMIT):
			if !get_letter(r, c, mainboard).is_empty() and get_letter(r, c, mainboard) != "#":  # Celda vacía
				var hor_space = get_space_in_line(Vector2(r, c), "HORIZONTAL", mainboard)
				var ver_space = get_space_in_line(Vector2(r, c), "VERTICAL", mainboard)

				# Si hay espacio suficiente en horizontal o vertical
				if hor_space >= 2 or ver_space >= 2: 
					next_pos = Vector2(r, c)  # Actualizar la variable local
					return next_pos  # Devolver la posición encontrada
	print("el avanzado lo intenta en: ", next_pos)
	return next_pos  # Devolver Vector2(-1, -1) si no se encontró ninguna posición válida
