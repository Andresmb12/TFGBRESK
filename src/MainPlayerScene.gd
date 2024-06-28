extends Node2D

# MainScene Script

@export var usernamevar: String
@onready var nickname = $PlayerInfo/lblNickName
@onready var is_bot : bool
@onready var bot_level : String
@onready var n_scoreboard = $ScoreBoardRoot
@onready var n_scoreboxes = $ScoreBoxes
@onready var n_mainboard = $MainBoardRoot
@onready var last_index: Vector2
@onready var longest_word : String
@onready var words_formed_by_player : Array
@onready var counter_placed: int
@onready var total_points: int
@onready var BOARD_LIMIT = 8
@onready var aux_pos_expert
@onready var aux_target_expert
@onready var word_in_progress : String
@onready var target_word : String = ""
@onready var copy_target_word : String = ""
@onready var letter_chosen_by_me : bool
@onready var to_be_placed : Array = []
@onready var target_letter : String = ""
@onready var placed : bool = false
@onready var own_dictionary : Dictionary
@onready var orient_target_word
@onready var orient_copy_target_word
@onready var index_target_word
@onready var space_in_line : int #Huecos que me quedan donde quiero formar la palabra
@onready var pos_target_word : Vector2
@onready var first_letter_placed = false
@export var mainboard: Array
#Ahora desde la escena de cada jugador, dentro de mainboard, tengo acceso
# a todas las casillas del tablero mediante mainboard[row][col].text

func get_letter(row,col):
	if row >= BOARD_LIMIT or col >= BOARD_LIMIT or row < 0 or col < 0:
		return ""
	return n_mainboard.letters_main_board[row][col].text
func get_cell(row,col):
	return n_mainboard.letters_main_board[row][col]
func set_score(points, row, col):
	n_mainboard.letters_main_board[row][col].text = str(points)
func bot_is_expert():
	return bot_level=="expert"
func bot_is_pro():
	return bot_level=="pro"	
func bot_is_advanced():
	return bot_level=="advanced"
func bot_is_starter():
	return bot_level=="starter"
	
func set_dictionary():
	if bot_is_expert():
		own_dictionary = DataLoader.spanish_dictionary
	elif usernamevar.contains("1") or bot_is_pro() or bot_is_starter() :
		own_dictionary = DataLoader.load_bot_words_from_file(DataLoader.bots_words_1)
	elif bot_is_advanced():
		own_dictionary = DataLoader.load_bot_words_from_file(DataLoader.bots_words_2)
func valid_position(pos):
	if pos == null:
		return Vector2(-1,-1)
	if pos.x == BOARD_LIMIT or pos.y == BOARD_LIMIT or pos.x < 0 or pos.y < 0 :
		pos = dummy_placing_letters()
	else:
		return pos
func place_letter(letter, pos):
	print("PLACE LETTER")
	pos = valid_position(pos)
	#await get_tree().create_timer(1,5).timeout
	if pos != Vector2(-1,-1) and pos != null:
		n_mainboard.letters_main_board[pos.x][pos.y].text = letter
		n_mainboard.letters_main_board[pos.x][pos.y].release_focus()

		n_mainboard.highlight_letter(pos)
	else:
		print("no se coloca")
	#await get_tree().create_timer(2).timeout
	#probar si este es el problema

func count_words_horz():
	var points = 0
	var words = []
	var new_word : String
	var found_letter
	for r in range(8):
		new_word = "" # Cada vez que paso de linea ya si habia alguna palabra formandose F
		points = 0
		for c in range(8):
			if !n_mainboard.letters_main_board[r][c].text.is_empty():
				found_letter = get_letter(r,c)
				
				if (c == 0 or get_letter(r,c-1) == "#") and found_letter != "#": #Start new word
					new_word = found_letter # New word
				
				elif (found_letter == "#" and new_word.length() > 1 ): #Word finished with #
					if DataLoader.check_word(new_word):
							words.append(new_word)
							points += new_word.length()
					new_word = ""
					
				elif found_letter != "#" and new_word.length() > 0: #Continue word
					new_word +=  get_letter(r,c)
					if new_word.length() >= 2 and (c == 7 or get_letter(r, c + 1) == "#"): #Word finished with limit
						if DataLoader.check_word(new_word):
							words.append(new_word)
							points += new_word.length()
						new_word = ""
		set_score(points, r, 8)
		total_points += points
						
	print("Palabras en Horizontal: ", words)
	words_formed_by_player += words
	
func check_word_block(pos, word):
	var board = n_mainboard.letters_main_board

	if orient_copy_target_word == "HORIZONTAL":
		for i in range(word.length()):
			var x = pos.x
			var y = pos.y + i
			if y >= BOARD_LIMIT:  # Fuera del tablero
				print("bloqueada")
				reset_everything()
				return true  # Bloqueada
			var cell_letter = board[x][y].text
			if !cell_letter.is_empty() and cell_letter != word[i]:
				print("bloqueada")
				reset_everything()
				return true  # Bloqueada
	else:  # VERTICAL
		for i in range(word.length()):
			var x = pos.x + i
			var y = pos.y
			if x >= BOARD_LIMIT:  # Fuera del tablero
				reset_everything()
				print("bloqueada")
				return true  # Bloqueada
			var cell_letter = board[x][y].text
			if !cell_letter.is_empty() and cell_letter != word[i]:
				reset_everything()
				print("bloqueada")
				return true  # Bloqueada

	return false  # No bloqueada
func reset_everything():
	copy_target_word = ""
	target_word = ""
	counter_placed = 0
	target_letter = ""
	word_in_progress = ""
	pos_target_word = Vector2(-1,-1)
	print("se cambia a ",pos_target_word)


func count_words_vertz():
	var words = []
	var new_word : String
	var points
	var found_letter
	for c in range(8):
		new_word = "" # Cada vez que paso de linea ya si habia alguna palabra formandose F
		points = 0
		for r in range(8):
			if !n_mainboard.letters_main_board[r][c].text.is_empty():
				found_letter = get_letter(r,c)
				
				if (r == 0 or get_letter(r-1,c) == "#") and found_letter != "#": #Start new word
					new_word = found_letter
				
				elif (found_letter == "#" and new_word.length() > 1 ): #Word finished with #
					if DataLoader.check_word(new_word):
						words.append(new_word)
						points += new_word.length()
					new_word = ""
					
				elif found_letter != "#" and new_word.length() > 0: #Continue word
					new_word +=  get_letter(r,c)
					if new_word.length() >= 2 and (r == 7 or get_letter(r + 1, c) == "#"): #Word finished with limit
						if DataLoader.check_word(new_word):
							words.append(new_word)
							points += new_word.length()
						new_word = ""
		set_score(points, 8, c)
		total_points += points
	print("Palabras en Vertical: ", words)
	words_formed_by_player += words

func update_index():
	last_index.y = last_index.y + 1 
	if last_index.y == 8:
		last_index.y = 0
		last_index.x += 1
		
func disable_score_cells():
	
	for i in range(0,9):
		n_mainboard.letters_main_board[i][8].focus_mode = Control.FOCUS_NONE 
		n_mainboard.letters_main_board[8][i].focus_mode = Control.FOCUS_NONE
  
func set_focus_mainboard(order):
	n_mainboard.set_focus_board(order)
	
func set_editable_subboards(order):
	n_mainboard.set_editable_board(order)
	n_scoreboard.set_editable_board(order)
	n_scoreboxes.set_editable_board(order)



func _ready():
	disable_score_cells()
	DataLoader.load_dictionary_from_file()
	
	last_index = Vector2(0,0)
	set_player_name(usernamevar)

func set_bot_level(level):
	bot_level = level

func set_player_name(name):
	usernamevar = name
	nickname.set_text("[center][color=BLACK][b]%s[/b][/color][/center]" % usernamevar.to_upper())

func calculate_points():
	words_formed_by_player = []
	total_points = 0
	count_words_horz()
	count_words_vertz()
	longest_word = DataLoader.get_longest_word(words_formed_by_player)
	#print(words_formed_by_player)
	
func _on_texture_button_pressed():
	calculate_points()

func check_word_while_placing():
	
		
	if word_in_progress.length() == copy_target_word.length() and target_word.length() > 0:
		print("check_word_while_placing")
		target_word = ""
		if bot_is_expert():
			expert_choosing_word()
		if target_word.is_empty():
			var aux = choose_next_target_pos()
			
			if first_letter_placed and aux != Vector2(-1,-1):
				pos_target_word = aux
				var l = get_letter(aux.x, aux.y)
				get_target_word(l,aux)
				print("new TW while placing")
				#aqui quizas poner counter placed a 1
				word_in_progress = target_word[0]
				counter_placed = 0 #cambio
				copy_target_word = target_word
				orient_copy_target_word = orient_target_word
				target_letter = target_word[1]
		
func smart_placing_letter(letter):
	
	print("se procede a colocar :", letter)
	print("WIP: ", word_in_progress)
	print("TW: ", target_word)
	print("CPTW: ", copy_target_word)
	print("TL: ",target_letter)
	if letter == "Ñ":
		letter = "N"
	var board = n_mainboard.letters_main_board
	placed = false
	if bot_level == "expert":
		expert_choosing_word()
		
	if !placed and target_word.is_empty() and copy_target_word.is_empty() and !first_letter_placed and letter != "#":
		pos_target_word = Vector2(0,0)
		place_letter(letter,pos_target_word)
		get_target_word(letter, pos_target_word)
		add_to_progress_word(letter) 
		counter_placed = 1
		copy_target_word = target_word
		orient_copy_target_word = orient_target_word
		placed = true
		print("primera TW generada")
	
	if !placed and target_word.is_empty() and copy_target_word.is_empty() and letter != "#" and pos_target_word!= Vector2(-1,-1) and get_letter(pos_target_word.x,pos_target_word.y).is_empty():
		place_letter(letter, pos_target_word)
		placed = true
		print("se crea nueva target word")
		get_target_word(letter, pos_target_word)
		if !target_word.is_empty():
			if word_in_progress.is_empty():
				add_to_progress_word(letter)
			counter_placed = 1
			copy_target_word = target_word
			orient_copy_target_word = orient_target_word
			placed = true
		
	place_without_tw_in_sight(letter)
		
	if !placed and copy_target_word.is_empty() and !target_word.is_empty():
		#if letter != "#":
			#add_to_progress_word(letter)
		print("copy is empty: ",word_in_progress)
		copy_target_word = target_word
		orient_copy_target_word = orient_target_word
	
	place_and_separate(letter)
		
	print("la posicion es ", pos_target_word)
	
	if !check_word_block(pos_target_word,copy_target_word):
		place_in_word(letter)
	
	place_without_messing(letter)
	
	if(!placed):
		place_wherever(letter)
	else:
		print("tras colocar quedan: ")
		print("counter placed = ", counter_placed)
		print("tw: ",target_word)
		print("wip: ",word_in_progress)
		print("cptw: ",copy_target_word)
	
func place_wherever(letter):
	var rand_pos = dummy_placing_letters() #last change
	print("target word empty y ponemos la letra donde sea")
	place_letter(letter,rand_pos)
	rand_pos = choose_next_target_pos()
	if rand_pos != Vector2(-1,-1):
		pos_target_word = rand_pos
		
		print("update pos_target = ", pos_target_word)
	placed = true
func place_and_separate(letter): #hay que dejarlo fino
	if !placed and letter == "#" and first_letter_placed and target_word.is_empty() and !copy_target_word.contains("#"):
		print("we place separator here")
		var rand_pos = dummy_placing_letters()
		word_in_progress = ""
		target_word = "" #last change
		copy_target_word = ""
		place_letter(letter,rand_pos)
		print("se evalua ",rand_pos)
		print("hay un ", get_letter(rand_pos.x, rand_pos.y))
		var aux_target_hor = check_line(rand_pos,"HORIZONTAL")
		print("en hor hay ", aux_target_hor)
		var aux_target_ver = check_line(rand_pos,"VERTICAL")
		print("en ver hay ", aux_target_ver)
		if aux_target_ver > aux_target_hor:
			orient_target_word = "VERTICAL"
			pos_target_word.x = rand_pos.x + 1
			pos_target_word.y = rand_pos.y
		else:
			orient_target_word = "HORIZONTAL"
			pos_target_word.x = rand_pos.x
			pos_target_word.y = rand_pos.y + 1
		print("pos target changed")
		placed = true
		
func place_without_tw_in_sight(letter):
	if !placed and letter=="#" and !first_letter_placed:
		var rand = dummy_placing_letters() #last change
		print("target word empty y ponemos la letra donde sea")
		place_letter(letter,rand)
		rand = choose_next_target_pos()
		if rand != Vector2(-1,-1):
			pos_target_word = rand
			
			print("update pos_target = ", pos_target_word)
		print("place_without_tw_in_sight la coloca")
		placed = true
	if !placed and copy_target_word.is_empty() and letter != "#" and ((pos_target_word == Vector2(-1,-1) or target_letter == "#")):
		var rand_pos = choose_next_target_pos()
		if rand_pos != Vector2(-1,-1) and !get_letter(rand_pos.x,rand_pos.y).is_empty() and get_letter(rand_pos.x, rand_pos.y)!="#":
			get_target_word(get_letter(rand_pos.x,rand_pos.y), rand_pos)
			print("nueva TW con la letra que habia: ", target_word)
			target_letter = ""#prueba andres
			print("y WIP ES antes: ", word_in_progress)
			word_in_progress = target_word[0]
			print("copy TW vale aun: ", copy_target_word)
			print("y WIP ES despues: ", word_in_progress)
			counter_placed = 1
			print("rand pos: ", rand_pos)
			print("target pos: ", pos_target_word)
		else:
			rand_pos = dummy_placing_letters() #last change
			print("target word empty y ponemos la letra donde sea")
			place_letter(letter,rand_pos)
			rand_pos = choose_next_target_pos()
			if rand_pos != Vector2(-1,-1):
				pos_target_word = rand_pos
				
				print("update pos_target = ", pos_target_word)
			placed = true
			print("place_without_tw_in_sight la coloca")
			
			
func place_in_word(letter):
	var arr_indexes = DataLoader.find_occurrences(copy_target_word,letter)
	#print("se va a intentar place_in_word la letra, ",letter)
	var board = n_mainboard.letters_main_board
	if !arr_indexes.is_empty() and !placed:
		print("se entra en place in word ->", arr_indexes)	
		print("la pos target es :", pos_target_word)
		for i in arr_indexes :
			if orient_copy_target_word == "HORIZONTAL":
				if board[pos_target_word.x][pos_target_word.y + i].text.is_empty():
					place_letter(letter,Vector2(pos_target_word.x,pos_target_word.y + i) )
					print("La letra me sirve HORZ y la pongo donde corresponde")
					 # prueba
					
					if !letter_chosen_by_me:
						add_to_progress_word(letter)
						print("Se añade una letra de otro tio ",word_in_progress)
						check_word_while_placing()
						
					elif word_in_progress.length() > 0 and word_in_progress.length() < 3 and !target_letter.is_empty():
						print("UPDATE")
						to_be_placed.erase(target_letter)
						add_to_progress_word(target_letter)
						target_letter = ""
					elif !to_be_placed.is_empty() and target_letter.is_empty() and word_in_progress.length()<3:
						
						add_to_progress_word( to_be_placed[0] )
						print("se añade una letra pendiente: ",to_be_placed[0])
						print("word in progress va: ", word_in_progress)
						to_be_placed.erase(to_be_placed[0])
						check_word_while_placing()
					else:
						if bot_level == "expert" and !to_be_placed.is_empty():
							add_to_progress_word( to_be_placed[0] )
							to_be_placed.erase(to_be_placed[0])
							
						print("No se añadio nada porque:")
						print("to be placed: ", to_be_placed)
						print("target_letter es",target_letter)
						print("WP ES ", word_in_progress)
					
					counter_placed += 1	
					check_last_letter()
	
					placed = true
					print("place_in_word la coloca counter=", counter_placed)
					
					break
			if orient_copy_target_word == "VERTICAL":
				if board[pos_target_word.x + i][pos_target_word.y].text.is_empty():
					place_letter(letter,Vector2(pos_target_word.x + i,pos_target_word.y) )
					print("La letra me sirve VERT y la pongo donde corresponde")
					
					if !letter_chosen_by_me:
						add_to_progress_word(letter)
						print("Se añade una letra de otro tio ",word_in_progress)
						check_word_while_placing()
					
					elif word_in_progress.length() > 0 and word_in_progress.length() < 3 and !target_letter.is_empty():
						print("UPDATE")
						to_be_placed.erase(target_letter)
						add_to_progress_word(target_letter)
						target_letter = ""
					elif !to_be_placed.is_empty() and target_letter.is_empty() and word_in_progress.length()<3:
						add_to_progress_word(to_be_placed[0])
						print("se añade una letra pendiente")
						to_be_placed.erase(to_be_placed[0])
						check_word_while_placing()
					else:
						if bot_level == "expert" and !to_be_placed.is_empty():
							add_to_progress_word( to_be_placed[0] )
							to_be_placed.erase(to_be_placed[0])
						print("No se añadio porque:")
						print("to be placed: ", to_be_placed)
						print("target_letter es",target_letter)
						print("WP ES ", word_in_progress)
						
					counter_placed += 1 # prueba
					
					check_last_letter()
					print("place_in_word la coloca counter=", counter_placed)
					placed = true
					break
	if placed:
		print("copy target word es: ", copy_target_word)
		print("word in progress vale: ", word_in_progress)
	else:
		print("problema")


func place_without_messing(letter):
	
	var board = n_mainboard.letters_main_board
	if !placed and word_in_progress.length() < copy_target_word.length(): 
		print("place_without_messing")
		for r in range(BOARD_LIMIT):
			if placed :
				break
			for c in range(BOARD_LIMIT):
				if (orient_copy_target_word == "VERTICAL" and c != pos_target_word.y):
					if board[r][c].text.is_empty():
						place_letter(letter,Vector2(r,c))
						placed = true
						break
				if (orient_copy_target_word == "HORIZONTAL" and r != pos_target_word.x):
					if board[r][c].text.is_empty():
						place_letter(letter,Vector2(r,c))
						placed = true
						break
		if placed:
			print("Se ha colocado en el hueco libre que no molesta a la target word")
		else:
			var aux_pos = dummy_placing_letters()
			place_letter(letter,aux_pos)
			print("Se coloca donde sea", aux_pos)
			placed = true
			
			


func check_line(pos, orient):
	#calculate if it's better to start word down vertically or right horizontally
	var col = (pos.y) 
	var row = (pos.x) 
	var done = false
	var space = 0
	if orient == "HORIZONTAL" and (pos.y==0 or get_letter(row,col) == "#"):
		while col < BOARD_LIMIT and !done:
			col += 1
			if get_letter(row,col).is_empty():
				print("espacio")
				space += 1
			else:
				print("hay una ", get_letter(row,col))
				done = true
		done = true
	if orient == "VERTICAL" and (pos.x==0 or get_letter(row,col) == "#"):
		while row < BOARD_LIMIT and !done:
			row  += 1
			if get_letter(row,col).is_empty():
				print("espacio")
				space += 1
			else:
				print("hay una ", get_letter(row,col))
				#possible TW beginning
				done = true
		done = true
	if space == 1:
		space = 0
	print("encontrado de espacio: ", space)
	return space
	pass

func check_last_letter():
	print("counter placed vale: ",counter_placed)
	print("word progress es: ",word_in_progress)
	var aux_pos
	
	# Caso 1: Se ha colocado un separador y se ha alcanzado la longitud de la palabra objetivo
	if target_letter == "#" and counter_placed >= copy_target_word.length() and !target_word.contains("#"):
			target_word = ""
			copy_target_word = ""
			print("BIG RESET")
			word_in_progress = ""
			counter_placed = 0 
			pos_target_word = choose_next_target_pos() #last change
	# Caso 2: Se ha alcanzado la longitud de la palabra objetivo y no hay una nueva palabra objetivo
	elif counter_placed >= copy_target_word.length() and target_word.is_empty():
		print("reset everything")
		target_word = ""
		copy_target_word = ""
		counter_placed = 0
		word_in_progress = ""
		aux_pos = choose_next_target_pos()
		if aux_pos==Vector2(-1,-1):
			target_letter = "#"
		else: #pruebas
			word_in_progress = get_letter(aux_pos.x,aux_pos.y)
		
	elif counter_placed >= copy_target_word.length() and target_word.length() > 0:
		if bot_level == "expert":
			word_in_progress = ""
			counter_placed = 0
			target_word = ""
			copy_target_word = ""
			expert_choosing_word()
		else:
			print("Se cambia la pos target")
			print("target letter es :", target_letter)
			
			aux_pos = choose_next_target_pos()
			if aux_pos != Vector2(-1,-1) and (target_word!=copy_target_word or (orient_copy_target_word!=orient_target_word and aux_pos==pos_target_word)):
				copy_target_word = target_word
				orient_copy_target_word = orient_target_word
				word_in_progress = target_word[0]
				counter_placed = 1 # here
				pos_target_word = aux_pos 
				print("Se resetea copy word",copy_target_word)
				print("orient = ",orient_copy_target_word)
				print("y WP vale ",word_in_progress)
			else :
				target_word = ""
				word_in_progress = ""
				print("vaciamos todo")
				copy_target_word = ""# new
				target_letter = "#" #new
	elif word_in_progress.length() == copy_target_word.length() and target_word.is_empty():
		print("last case")
		target_word = ""	
		#copy_target_word = "" lo comento pq sino no me acaba bien
		word_in_progress = ""
		print("vaciamos todo en last case")
		target_letter = "#"
		
			
		
# We JUST choose letter
func choose_next_target_pos():
	print("warning choose_next_target_pos")
	var best_next_target = 0
	var aux_target_hor
	var aux_target_ver
	var candidate
	var aux_pos : Vector2
	
	if bot_level == "advanced":
		return SmartBots.find_first_valid_position(n_mainboard.letters_main_board)
		
	if first_letter_placed :
		for r in range(BOARD_LIMIT):
			for c in range(BOARD_LIMIT):
				if !get_letter(r,c).is_empty() and get_letter(r,c)!= "#":
					aux_target_hor = SmartBots.get_space_in_line(Vector2(r,c),"HORIZONTAL",n_mainboard.letters_main_board)
					aux_target_ver = SmartBots.get_space_in_line(Vector2(r,c),"VERTICAL",n_mainboard.letters_main_board)
					
					candidate = aux_target_hor if aux_target_hor > aux_target_ver else aux_target_ver
					if candidate > best_next_target:
						print("candidate = ", candidate)
						best_next_target = candidate
						aux_pos = Vector2(r,c)

	else:
		print("letra en sitio random")
		aux_pos = dummy_placing_letters()
		best_next_target = 1
	
	if best_next_target == 0:
		aux_pos = Vector2(-1,-1)
	print("La mejor pos para empezar una palabra es: ", aux_pos)
	print("Con puntuacion: ", best_next_target)
	
	return aux_pos
			
func dummy_placing_letters():
	for row in range(8):
			for col in range(8):
				if get_letter(row,col).is_empty():
					return Vector2(row,col)
	return Vector2(-1,-1)				
func choose_without_target_word():
	var aux_letter = ""
	var letter = ""
	var index
	var aux_pos	= choose_next_target_pos()
	if target_word.is_empty():
		print("se intenta con la pos target: ", aux_pos)
		aux_letter = get_letter(aux_pos.x, aux_pos.y)
		print("aqui WP = ", word_in_progress)
		print("con la letra ", aux_letter)
		if aux_letter.is_empty():
			index = randi() % SmartBots.consonants.size()
			letter = SmartBots.consonants[index]
			print("letra random y ya tiramos")
			if aux_pos!=Vector2(-1,-1) or (!first_letter_placed and word_in_progress.is_empty()):
				get_target_word(letter,aux_pos) # cambios
				word_in_progress = letter
				copy_target_word = target_word
				counter_placed = 0
			print("se forma palabra con la letra random: ", target_word)
		elif (word_in_progress.is_empty() or word_in_progress==aux_letter) and choose_next_target_pos() != Vector2(-1,-1) :
			print("target word generada con la letra que habia")
			get_target_word(aux_letter, pos_target_word)
			if !target_word.is_empty():
				add_to_progress_word(aux_letter)
				#counter_placed = 1 creo andres
				print("target word = ", target_word)
				letter = target_word[1] #esta es
			
		elif choose_next_target_pos() != Vector2(-1,-1) and target_word.length() == word_in_progress.length():
			index = randi() % SmartBots.consonants.size()
			letter = SmartBots.consonants[index]
			print("target word generada con letra random:")
			get_target_word(letter, pos_target_word)
			if !target_word.is_empty():
				add_to_progress_word(letter)
				copy_target_word = target_word
				counter_placed = 0
				print("target word generada con letra random: ", target_word)
		elif target_word.is_empty(): #and word_in_progress.is_empty() and choose_next_target_pos() == Vector2(-1,-1):
			index = randi() % SmartBots.consonants.size()
			letter = SmartBots.consonants[index]
			print("letra random y a seguir")
		
		if letter.is_empty():
			print("falla choose_without_target")
		return letter
	#index_target_word = 1

func choose_letter_from_target():
	var letter = ""
	print("target word LENGTH= ", target_word.length())
	print("word progress LENGTH= ", word_in_progress.length())
	var not_okay = true
	while(not_okay):
		
		letter = target_word[index_target_word % target_word.length()]
		
		if DataLoader.find_occurrences(target_word,letter).size() > DataLoader.find_occurrences(word_in_progress,letter).size():
			print("se elige letra aqui, word in progress: ", word_in_progress)
			not_okay = false
			
		if !target_word.is_empty():
			index_target_word = (index_target_word + 1) % target_word.length()
	print("target_letter=", target_letter)
	
	add_to_progress_word(letter)
	if target_word!= "#":
		target_letter = ""
	print("word in progress es: ", word_in_progress)
	print("la letra a devilver es: ", letter)
	
	if letter.is_empty():
		print("falla letter from target")
	return letter
	
func choose_when_word_finished(letter):
	print("PALABRA ACABADA, quito target letter")
	#target_letter = ""
	target_word = ""
	var aux = Vector2(-1,-1)
	if bot_level == "expert":
		aux = expert_choosing_word()
	if aux == Vector2(-1,-1):
		aux = choose_next_target_pos()
	print("aux = ", aux)
	
	if target_word.is_empty() and first_letter_placed and (aux == Vector2(-1,-1) and !copy_target_word.contains("#")): #or (aux == pos_target_word and orient_copy_target_word == orient_target_word) ): #nueva prueba
		print("we place separator")
		if letter.is_empty():
			print("devolvemos separador")
			letter = "#"
		else:
			print("target a #")
			target_letter = "#"
	
	if first_letter_placed and aux != Vector2(-1,-1) and target_word.is_empty() :
		var l = get_letter(aux.x, aux.y)
		# cuando se ha acabado la palabra, se piensa la proxima
		get_target_word(l,aux)
		if !target_word.is_empty():
			if aux == pos_target_word and orient_target_word == orient_copy_target_word: #clave
				target_word = ""
				orient_target_word = copy_target_word
				print("al final no se puede")
			print("ahora target word es: ", target_word)
			
		if letter.is_empty() and !target_word.is_empty(): #Se devuelve 
			
			target_letter = target_word[index_target_word]
			index_target_word = (index_target_word + 1) % target_word.length() #test
			print("word in progress now= ", word_in_progress)
			letter = target_letter
			
		elif !target_word.is_empty(): #Se devuelve la ultima letra de la palabra por terminar
			print("LETTER = ",letter)
			# aqui se usa target_letter para meter la ultima letra
			target_letter = letter
			
			print("se entra aqui de choose letters")
			index_target_word = (index_target_word + 1) % target_word.length() #no deberia ser copy?
			if word_in_progress.length() < target_word.length():
				print("crece progress")
				add_to_progress_word(letter)
			print("WP VALE AQUI: ", word_in_progress)
				
		if letter.is_empty():
			print("when word finished")
	return letter	

func choose_from_next_target(i_letter):
	
	var letter = ""
	var aux = Vector2(-1,-1)
	if bot_level == "expert":
		aux = expert_choosing_word()
	
	if aux == Vector2(-1,-1):
		aux = choose_next_target_pos()
	print("aux = ", aux)
	
	if first_letter_placed and (aux == Vector2(-1,-1)) and !target_word.contains("#"):# ANDRES or aux == pos_target_word): #Not possible to form a 8 letter word
		print("we place separator")
		target_letter = "#"
		if letter.is_empty():
			print("devolvemos separador")
			letter = "#"
	else:
		print("i_letter = ",i_letter)
		target_letter = target_word[int(i_letter-1) % target_word.length()] #andres
		if bot_level == "expert":
			target_letter = target_word[int(target_word.length()-1) % target_word.length()]
		index_target_word = 1
		print("word in progress ahorita = ", word_in_progress)
		letter = target_letter
		#target_letter = "" #andres
		to_be_placed.append(target_letter)
		
		print("letter a elegir: ",letter)
		print("index es ", index_target_word)
		index_target_word = (index_target_word + 1) % target_word.length()
		
	if letter.is_empty():
		print("from next target")
	return letter

func add_to_progress_word(letter):
	if  word_in_progress.count(letter) < copy_target_word.count(letter) :
		word_in_progress += letter
	elif copy_target_word.is_empty() and word_in_progress.is_empty():
		word_in_progress += letter
	elif !word_in_progress.is_empty() and copy_target_word.is_empty() and target_word.is_empty():
		word_in_progress = ""
		print("probablemente se ha liado")
		
func expert_choosing_word():
	
	
	var next_tw : Array = [""]
	var aux_orient : Array = [""]
	aux_pos_expert = Vector2(-1,-1)
	
	if first_letter_placed and (target_word.is_empty() or counter_placed == copy_target_word.length()):
		print("viene el experto")
		aux_pos_expert = SmartBots.find_optimal_position(n_mainboard.letters_main_board, aux_orient, pos_target_word)
		
		if aux_pos_expert != Vector2(-1,-1) and aux_pos_expert != pos_target_word:
			print("experto ", aux_pos_expert)
			orient_target_word = aux_orient[0]
			if target_word.is_empty():
				if aux_orient[0] == "VERTICAL":
					aux_target_expert = SmartBots.get_ver_sequence(n_mainboard.letters_main_board, aux_pos_expert, next_tw)
				elif aux_orient[0] == "HORIZONTAL":
					aux_target_expert = SmartBots.get_hor_sequence(n_mainboard.letters_main_board, aux_pos_expert, next_tw)
				print("se pondria el objetivo en: ",aux_target_expert)
				target_word = next_tw[0]
				print("el expero tiene: ", target_word)
				target_letter = ""
			
			if copy_target_word.length() == word_in_progress.length() and counter_placed == copy_target_word.length() and !target_word.is_empty():
				pos_target_word = aux_pos_expert
				print("nueva pos de referencia: ", pos_target_word)
				word_in_progress = aux_target_expert
				copy_target_word = target_word
				orient_copy_target_word = orient_target_word
				counter_placed = word_in_progress.length()
				print("new word in progress: ", word_in_progress)
	if aux_pos_expert == null:
		print("nulo")
	return aux_pos_expert
	
		
func smart_choosing_letter(n):
	var letter = ""
	var aux_letter = ""
	var index
	var chosen = false
	
	if bot_level == "expert":
		expert_choosing_word()
	
	if !word_in_progress.is_empty() and target_word.is_empty() and copy_target_word.is_empty():
		word_in_progress = ""
	if target_letter == "#" and target_word.is_empty() and !copy_target_word.contains("#"):
		target_letter = ""
		word_in_progress = ""
		print("aqui del tiron")
		letter = "#"
	
	if letter.is_empty() and word_in_progress.length() != copy_target_word.length() and !target_word.is_empty():
		print("CHOOSE FROM TARGET")
		letter = choose_letter_from_target()
		
	# tengo problema aqui de que acaba la palabra y no piensa en la nueva
	print("letter en este punto otro es: ", letter)
	if word_in_progress.length() == target_word.length() and target_word.length() > 0 and target_word == copy_target_word:	
		print("CHOOSE when word finished")
		letter = choose_when_word_finished(letter)
		
	print("letter en este punto es: ", letter)
	print("y aqui TW vale: ", target_word)
	if letter.is_empty() and target_word != copy_target_word and !target_word.is_empty():
		print("choose from next target")
		letter = choose_from_next_target(n)
		#return smart_choosing_letter()
	if letter.is_empty() and target_word.is_empty(): # probar and copy target vacia para el problema de las palabras n=2:
		letter = choose_without_target_word() 
	if letter.is_empty():
		print("falla ultimo")
		index = randi() % SmartBots.vowels.size()
		letter = SmartBots.vowels[index]
		print("letra random y ya tiramos")
	return letter
	
func get_target_word(letter, pos):
	#counter_placed = 1
	var hor_space = SmartBots.get_space_in_line(pos,"HORIZONTAL", n_mainboard.letters_main_board)
	var ver_space = SmartBots.get_space_in_line(pos,"VERTICAL", n_mainboard.letters_main_board)
	var space = ver_space if (ver_space > hor_space) else hor_space
	if !first_letter_placed:
		space = 8
	print("space es: ",space)
	if space > 0:
		orient_target_word = "HORIZONTAL" if hor_space > ver_space else "VERTICAL"
		if copy_target_word.is_empty():
			orient_copy_target_word = orient_target_word
			copy_target_word = target_word
		print("orientacion: ",orient_target_word)
		if bot_level != "starter":
			target_word = SmartBots.get_desired_word(letter,space,own_dictionary)
		else:
			
			target_word = SmartBots.get_shortest_word(letter,space, own_dictionary)
		index_target_word = 1
		print("Target Word = ", target_word)
		if !target_word.is_empty() and target_word.length() < space:
			print("hace falta #")
			target_word += "#"
	else:
		print("no se puede aun")
		target_letter = ""
		word_in_progress = ""
		

	
func _on_andres_button_pressed():
	print("andresito")
	var aux_orient
	expert_choosing_word()
	pass # Replace with function body.
