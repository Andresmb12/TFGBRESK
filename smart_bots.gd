extends Node
var BOARD_LIMIT = 8
var vowels = ["A", "E", "I", "O", "U"]
var consonants = [ "B", "C", "D", "F", "G","H", "J", "K", "L", "M", 
"N", "P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z" ]
var space = "#"
var used_positions : Array = []
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
	if row >= BOARD_LIMIT or col >= BOARD_LIMIT or row < 0 or col < 0:
		return ""
	return mainboard[row][col].text if !mainboard[row][col].text.is_empty() else ""

# Return how many empty cells are free on the desired orientation
func get_space_in_line(pos, orient, mainboard):
	var col = (pos.y) 
	var row = (pos.x) 
	var done = false
	var space = 0
	
	if orient == "HORIZONTAL" and (pos.y==0 or get_letter(row,pos.y-1,mainboard) == "#"):
		while col < BOARD_LIMIT and !done and space < BOARD_LIMIT:
			col += 1
			if get_letter(row,col,mainboard).is_empty():
				space += 1
			else:
				space += 1
				done = true
		done = true
	if orient == "VERTICAL" and (pos.x==0 or get_letter(pos.x-1,col,mainboard) == "#"):
		while row < BOARD_LIMIT and !done and space < BOARD_LIMIT:
			row  += 1
			if get_letter(row,col,mainboard).is_empty():
				space += 1
			else:
				space += 1
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
	


func get_desired_word(starting_letter,size, own_dictionary):
	print("encontrar una palabra que empieza por: ", starting_letter)
	print("y tiene de letras: ", size)
	print("se busca entre x palabras: ", own_dictionary.keys().size())
	var aux_size = size
	var word_found = ""
	var found = false
	while !found and size > 1:
		for w in own_dictionary.keys():
			if w.length() == size and w.find(starting_letter) == 0 :
				word_found = w
				found = true
				break
		if !found: # If there is no existing word of that size, at least the longest
			aux_size = aux_size-1
			if aux_size == 1:
				break
	return word_found

func get_shortest_word(starting_letter, size, own_dictionary):
	print("encontrar una palabra que empieza por: ", starting_letter)
	var aux_size = 2
	
	print("y tiene de letras: ", aux_size)
	print("se busca entre x palabras: ", own_dictionary.keys().size())
	var word_found = ""
	var found = false
	while !found and aux_size <= 8 and aux_size <= size:
		for w in own_dictionary.keys():
			if w.length() == aux_size and w.find(starting_letter) == 0 :
				word_found = w
				found = true
				break
		if !found: # If there is no existing word of that size, at least the longest
			aux_size = aux_size+1

	return word_found


func is_part_of_a_word(subword, posible_target):
	var found = false
	var word = ""
	for w in DataLoader.spanish_dictionary.keys():
		if w.contains(subword):
			found = true
			posible_target = w
			break
	print("es parte de ", word)
	return found
	
func get_hor_sequence(board, pos, next_tw):#, target, wip):

	var hor_sub_word = ""
	hor_sub_word = get_letter(pos.x, pos.y, board)
	var hor_space = 0
	var orient
	var need_spacer = false
	var posible_target
	var next_hor_let
	var blocked = false
	
	if !hor_sub_word.is_empty() and hor_sub_word!="#" and pos.y < BOARD_LIMIT and (pos.y == 0 or get_letter(pos.x, pos.y-1, board) == "#"):
		print("hor sequence found")
		for c in range(pos.y+1,BOARD_LIMIT):
			next_hor_let = get_letter(pos.x,c, board)
			if !next_hor_let.is_empty() and next_hor_let!= "#" and !blocked:
				hor_sub_word += get_letter(pos.x, c, board)
			elif next_hor_let.is_empty() :
				hor_space += 1
				blocked = true
			elif blocked and !next_hor_let.is_empty():
				hor_space -= 1
				need_spacer = true
			elif next_hor_let == "#":
				break
	if hor_sub_word.length() > 1 and hor_space > 0:
		print("se lleva de palabra: ", hor_sub_word)
		print("y queda de espacio: ", hor_space)
		var tw = get_desired_word(hor_sub_word, hor_space + hor_sub_word.length(), DataLoader.spanish_dictionary)
		if !tw.is_empty():
			
			print("se buscaria la palabra: ", tw)
			next_tw[0] = tw
			if need_spacer:
				next_tw[0] += "#"
			#target = tw
		else:
			# Si la subcadena no es parte de ninguna palabra se devuelve ""
			hor_sub_word = ""
			print("no hay palabra posible")
	else:
		hor_sub_word = ""
		print("no hay espacio asi que nada")
	return hor_sub_word
	
	
func get_ver_sequence(board, pos, next_tw):#, target, wip):
	
	var ver_sub_word = ""
	ver_sub_word = get_letter(pos.x, pos.y, board)
	var next_ver_let
	var ver_space = 0
	var need_spacer = false
	var posible_target
	var blocked = false
				
	if !ver_sub_word.is_empty() and ver_sub_word!="#" and pos.x < BOARD_LIMIT and (pos.x == 0 or get_letter(pos.x-1, pos.y, board) == "#"):
		print("ver sequence found")
		for r in range(pos.x+1,BOARD_LIMIT):
			next_ver_let = get_letter(r,pos.y, board)
			if !next_ver_let.is_empty() and next_ver_let!= "#" and !blocked:
				ver_sub_word += next_ver_let
			elif next_ver_let.is_empty():
				ver_space += 1
				blocked = true
			elif blocked and !next_ver_let.is_empty():
				ver_space -= 1
				need_spacer = true
			elif next_ver_let == "#":
				break
	if ver_sub_word.length() > 1 and ver_space > 0:
		print("se lleva de palabra: ", ver_sub_word)
		print("y queda de espacio: ", ver_space)
		var tw = get_desired_word(ver_sub_word, ver_space + ver_sub_word.length(), DataLoader.spanish_dictionary)
		if !tw.is_empty():
			print("se buscaria la palabra: ", tw)
			next_tw[0] = tw
			if need_spacer:
				next_tw[0] += "#"
		else:
			ver_sub_word = ""
			print("no hay palabra posible")
	else:
		print("no hay espacio asi que nada")
		ver_sub_word=""
	return ver_sub_word

				
func find_optimal_position(board, aux_orient, current_pos):
	var points = 0
	var next_pos = Vector2(-1, -1)
	var ver_points
	var next_wip
	var best_tw = ""
	var next_tw : Array = [""]
	var hor_points
	
	for r in range(BOARD_LIMIT):
		for c in range(BOARD_LIMIT):
			if !get_letter(r,c,board).is_empty() and Vector2(r,c)!=current_pos:
				hor_points = get_hor_sequence(board, Vector2(r,c), next_tw)
				ver_points = get_ver_sequence(board, Vector2(r,c), next_tw)
				print("en la pos: ", Vector2(r,c))
				print("se saca hor: ", hor_points)
				print("se saca ver: ", ver_points)
				if (hor_points.length() > 1 or ver_points.length() > 1) and next_tw[0].length() > best_tw.length():
					next_pos = Vector2(r,c)
					best_tw = next_tw[0]
					aux_orient[0] = "HORIZONTAL" if hor_points.length() > ver_points.length() else "VERTICAL"
					next_wip = hor_points if hor_points.length() > ver_points.length() else ver_points
					break
	print("experto devuelve: ", next_pos)
	if aux_orient.size() > 0:
		print("orient: ", aux_orient[0]) #este valor se queda aquí y me hace falta devolverlo tambien
	print("gana: ",next_wip)
	if next_pos == null:
		print("nulo")
	return next_pos

