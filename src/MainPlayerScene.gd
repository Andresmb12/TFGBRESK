extends Node2D

# MainScene Script

@export var usernamevar: String
@onready var nickname = $PlayerInfo/lblNickName
@onready var is_bot : bool
@onready var n_scoreboard = $ScoreBoardRoot
@onready var n_scoreboxes = $ScoreBoxes
@onready var n_mainboard = $MainBoardRoot
@onready var last_index: Vector2
@onready var longest_word : String
@onready var words_formed_by_player : Array
@onready var counter_placed: int
@onready var total_points: int
@onready var BOARD_LIMIT = 8
@onready var word_in_progress : String
@onready var target_word : String = ""
@onready var copy_target_word : String = ""
@onready var letter_chosen_by_me : bool
@onready var target_letter
@onready var placed : bool = false
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
	return n_mainboard.letters_main_board[row][col].text
func get_cell(row,col):
	return n_mainboard.letters_main_board[row][col]
func set_score(points, row, col):
	n_mainboard.letters_main_board[row][col].text = str(points)
	
func place_letter(letter, pos):
	print("PLACE LETTER")
	
	#await get_tree().create_timer(1,5).timeout
	n_mainboard.letters_main_board[pos.x][pos.y].text = letter
	n_mainboard.letters_main_board[pos.x][pos.y].release_focus()
	
	n_mainboard.highlight_letter(pos)
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
					new_word += found_letter
				
				elif (found_letter == "#" and new_word.length() > 1 ): #Word finished with #
					if DataLoader.check_word(new_word):
							words.append(new_word)
							points += new_word.length()
					new_word = ""
					
				elif found_letter != "#" and new_word.length() > 0: #Continue word
					new_word +=  get_letter(r,c)
					if(new_word.length() >= 2 and c == 7): #Word finished with limit
						if DataLoader.check_word(new_word):
							words.append(new_word)
							points += new_word.length()
						new_word = ""
		set_score(points, r, 8)
		total_points += points
						
	print("Palabras en Horizontal: ", words)
	words_formed_by_player += words

# Return how many empty cells are free on the desired orientation
func get_space_in_line(pos, orient):
	var col = (pos.y) 
	var row = (pos.x) 
	var done = false
	var space = 0
	if orient == "HORIZONTAL" and (pos.y==0 or get_letter(row,pos.y-1) == "#"):
		while col < BOARD_LIMIT and !done:
			col += 1
			if get_letter(row,col).is_empty():
				space += 1
			else:
				done = true
		done = true
	if orient == "VERTICAL" and (pos.x==0 or get_letter(pos.x-1,col) == "#"):
		while row < BOARD_LIMIT and !done:
			row  += 1
			if get_letter(row,col).is_empty():
				space += 1
			else:
				#possible TW beginning
				done = true
		done = true
	if space == 1:
		space = 0
	return space
	
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
					new_word += found_letter
				
				elif (found_letter == "#" and new_word.length() > 1 ): #Word finished with #
					if DataLoader.check_word(new_word):
						words.append(new_word)
						points += new_word.length()
					new_word = ""
					
				elif found_letter != "#" and new_word.length() > 0: #Continue word
					new_word +=  get_letter(r,c)
					if(new_word.length() >= 2 and r == 7): #Word finished with limit
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
		var aux = choose_next_target_pos()
		
		if first_letter_placed and aux != Vector2(-1,-1):
			pos_target_word = aux
			var l = get_letter(aux.x, aux.y)
			get_target_word(l,aux)
			print("new TW while placing")
			
			word_in_progress = target_word[0]
			copy_target_word = target_word
			target_letter = target_word[1]
		
func smart_placing_letter(letter):
	
	if letter == "Ñ":
		letter = "N"
	var board = n_mainboard.letters_main_board
	placed = false
	if !placed and target_word.is_empty() and copy_target_word.is_empty() and !first_letter_placed and letter != "#":
		pos_target_word = Vector2(0,0)
		place_letter(letter,pos_target_word)
		get_target_word(letter, pos_target_word)
		word_in_progress += letter
		counter_placed = 1
		copy_target_word = target_word
		orient_copy_target_word = orient_target_word
		placed = true
		print("primera TW generada")
		
	#if !placed and choose_next_target_pos() == Vector2(-1,-1) and copy_target_word.length() == word_in_progress.length() and copy_target_word.length() > 0:
		#var rand_pos = dummy_placing_letters() #last change
		#place_letter(letter,rand_pos)
		#print("todo el pescao vendio")
		#placed = true
		#pass
		
	if !placed and copy_target_word.is_empty() and letter != "#" and pos_target_word!= Vector2(-1,-1) and get_letter(pos_target_word.x,pos_target_word.y).is_empty():
		place_letter(letter, pos_target_word)
		print("se crea nueva target word")
		get_target_word(letter, pos_target_word)
		word_in_progress += letter
		counter_placed = 1
		copy_target_word = target_word
		orient_copy_target_word = orient_target_word
		placed = true
		
	place_without_tw_in_sight(letter)
		
	if !placed and copy_target_word.is_empty() and !target_word.is_empty():
		#if letter != "#":
			#word_in_progress += letter
		print("copy is empty: ",word_in_progress)
		copy_target_word = target_word
		orient_copy_target_word = orient_target_word
	
	place_and_separate(letter)
		
	print("la posicion es ", pos_target_word)
	
	place_in_word(letter)
	
	place_without_messing(letter)
	

func place_and_separate(letter):
	if !placed and letter == "#" and first_letter_placed and target_word.is_empty():
		print("we place separator here")
		var rand_pos = dummy_placing_letters()
		word_in_progress = "" #AQUI
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
	if !placed and copy_target_word.is_empty() and letter != "#" and (pos_target_word == Vector2(-1,-1) or target_letter == "#"):
		var rand_pos = choose_next_target_pos()
		if rand_pos != Vector2(-1,-1) and !get_letter(rand_pos.x,rand_pos.y).is_empty() and get_letter(rand_pos.x, rand_pos.y)!="#":
			get_target_word(get_letter(rand_pos.x,rand_pos.y), rand_pos)
			print("nueva TW con la letra que habia: ", target_word)
			word_in_progress = target_word[0]
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
			
			
func place_in_word(letter):
	var arr_indexes = DataLoader.find_occurrences(copy_target_word,letter)
	var board = n_mainboard.letters_main_board
	if !arr_indexes.is_empty() and !placed:
		
		for i in arr_indexes :
			if orient_copy_target_word == "HORIZONTAL":
				if board[pos_target_word.x][pos_target_word.y + i].text.is_empty():
					place_letter(letter,Vector2(pos_target_word.x,pos_target_word.y + i) )
					print("La letra me sirve HORZ y la pongo donde corresponde")
					 # prueba
					
					if !letter_chosen_by_me:
						word_in_progress += letter
						print("Se añade una letra de otro tio ",word_in_progress)
						check_word_while_placing()
						
					elif word_in_progress.length() > 0 and word_in_progress.length() < 3:
						print("UPDATE")
						word_in_progress += letter	
					counter_placed += 1	
					check_last_letter()
					
					placed = true
					break
			if orient_copy_target_word == "VERTICAL":
				if board[pos_target_word.x + i][pos_target_word.y].text.is_empty():
					place_letter(letter,Vector2(pos_target_word.x + i,pos_target_word.y) )
					print("La letra me sirve VERT y la pongo donde corresponde")
					
					if !letter_chosen_by_me:
						word_in_progress += letter
						print("Se añade una letra de otro tio ",word_in_progress)
						check_word_while_placing()
					
					elif word_in_progress.length() > 0 and word_in_progress.length() < 3 and target_word!=copy_target_word:
						print("update")	
						word_in_progress += letter
					counter_placed += 1 # prueba
					
					check_last_letter()
					
					placed = true
					break
	
	print("copy target word es: ", copy_target_word)
	print("word in progress vale: ", word_in_progress)


func place_without_messing(letter):
	var board = n_mainboard.letters_main_board
	if !placed and word_in_progress.length() < copy_target_word.length(): 
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
	var aux_pos
	# me falta el caso en el que se acaba la palabra pero aun no se sabe prox target word
	
		
	if target_letter == "#" and counter_placed >= copy_target_word.length():
			target_word = ""
			copy_target_word = ""
			print("BIG RESET")
			counter_placed = 0 
			pos_target_word = choose_next_target_pos() #last change
			
	elif counter_placed >= copy_target_word.length() and target_word.is_empty():
		target_word = ""
		copy_target_word = ""
		word_in_progress = ""
		print("vaciamos todo aunque no haya target word")
		target_letter = "#"
		
	elif counter_placed >= copy_target_word.length() and target_word.length() > 0:
		print("Se cambia la pos target")
		print("target letter es :", target_letter)
		
		aux_pos = choose_next_target_pos()
		if aux_pos != Vector2(-1,-1):
			#if word_in_progress[0] != target_word[0]: #test
			word_in_progress = target_word[0]
			print("UPDATE")
				
			copy_target_word = target_word
			orient_copy_target_word = orient_target_word
			counter_placed = 1
			pos_target_word = aux_pos 
			print("Se resetea copy word")
			print("y WP vale ",word_in_progress)
		else:
			target_word = ""
			word_in_progress = ""
			print("vaciamos todo")
			copy_target_word = ""# new
			target_letter = "#"
	elif word_in_progress.length() == copy_target_word.length() and target_word.is_empty():
		print("last case")
		target_word = ""	
		#copy_target_word = "" lo comento pq sino no me acaba bien
		word_in_progress = ""
		print("vaciamos todo")
		target_letter = "#"
		
		
		
		
		
# We JUST choose letter
func choose_next_target_pos():
	var best_next_target = 0
	var aux_target_hor
	var aux_target_ver
	var candidate
	var aux_pos : Vector2
	if first_letter_placed:
		for r in range(BOARD_LIMIT):
			for c in range(BOARD_LIMIT):
				if !get_letter(r,c).is_empty() and get_letter(r,c)!= "#":
					aux_target_hor = get_space_in_line(Vector2(r,c),"HORIZONTAL")
					aux_target_ver = get_space_in_line(Vector2(r,c),"VERTICAL")
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
					
func choose_without_target_word():
	var aux_letter
	var letter
	var index
		
	print("se intenta crear target word")
	print("se intenta con la pos target: ", pos_target_word)
	aux_letter = get_letter(pos_target_word.x, pos_target_word.y)
	if aux_letter.is_empty():
		index = randi() % SmartBots.consonants.size()
		letter = SmartBots.consonants[index]
		print("letra random y ya tiramos")
		get_target_word(letter,pos_target_word)
		#word_in_progress = letter
		counter_placed = 1
	elif (word_in_progress.is_empty() or word_in_progress==aux_letter) and aux_letter!= null and choose_next_target_pos() != Vector2(-1,-1) :
		print("target word generada con la letra que habia")
		get_target_word(aux_letter, pos_target_word)
		word_in_progress += aux_letter
		counter_placed = 1
		print("target word = ", target_word)
		
	elif choose_next_target_pos() != Vector2(-1,-1) and target_word.length() == word_in_progress.length():
		index = randi() % SmartBots.consonants.size()
		letter = SmartBots.consonants[index]
		print("target word generada con letra random:")
		get_target_word(letter, pos_target_word)
		word_in_progress += letter
		copy_target_word = target_word
		counter_placed = 1
		print("target word generada con letra random: ", target_word)
	elif target_word.is_empty() and word_in_progress.is_empty() and choose_next_target_pos() == Vector2(-1,-1):
		index = randi() % SmartBots.consonants.size()
		letter = SmartBots.consonants[index]
		print("letra random y a seguir")
	
	if letter == null:
		print("falla 1")
	return letter
	#index_target_word = 1

func choose_letter_from_target():
	var letter
	print("target word LENGTH= ", target_word.length())
	print("word progress LENGTH= ", word_in_progress.length())
	var not_okay = true
	while(not_okay):
		
		letter = target_word[index_target_word]
		print("target letter es", letter)
		if DataLoader.find_occurrences(target_word,letter).size() > DataLoader.find_occurrences(word_in_progress,letter).size():
			print("se elige letra aqui, word in progress: ", word_in_progress)
			not_okay = false
			
		if !target_word.is_empty():
			index_target_word = (index_target_word + 1) % target_word.length()
			
	word_in_progress += letter

	print("word in progress es: ", word_in_progress)
	print("la letra a devilver es: ", letter)
	return letter
	
func choose_when_word_finished(letter):
	print("PALABRA ACABADA")
	target_word = ""
	var aux = choose_next_target_pos()
	print("aux = ", aux)
	
	if first_letter_placed and (aux == Vector2(-1,-1) or aux == pos_target_word): #Not possible to form a 8 letter word
		print("we place separator")
		target_letter = "#"
		if letter == null:
			print("devolvemos separador")
			letter = "#"
	
	if first_letter_placed and aux != Vector2(-1,-1) and aux != pos_target_word: #and counter_placed == copy_target_word.length() and counter_placed > 0:
		var l = get_letter(aux.x, aux.y)
		# cuando se ha acabado la palabra, se piensa la proxima
		get_target_word(l,aux)
		print("ahora target word es: ", target_word)
		
		if letter == null:
			#esto está mal creo, problemas con index_target_WORD
			target_letter = target_word[index_target_word]
			print("word in progress now= ", word_in_progress)
			letter = target_letter
			
		else:
			target_letter = letter
			print("se entra aqui de choose letters")
			index_target_word = (index_target_word + 1) % target_word.length()
			print("WP VALE AQUI: ", word_in_progress)
			
	return letter	

func choose_from_next_target():
	var letter
	target_letter = target_word[index_target_word]
	print("word in progress now= ", word_in_progress)
	letter = target_letter
	print("letter a elegir: ",letter)
	print("index es ", index_target_word)
	index_target_word = (index_target_word + 1) % target_word.length()
	return letter
		
func smart_choosing_letter(n=1):
	var letter
	var aux_letter
	var index
	var chosen = false
	if target_letter == "#" and target_word.is_empty():
		target_letter = ""
		word_in_progress = ""
		return "#"
	
	if target_word.is_empty(): # probar and copy target vacia para el problema de las palabras n=2:
		letter = choose_without_target_word() 
		
	if letter == null and word_in_progress.length() != target_word.length() and !target_word.is_empty():
		letter = choose_letter_from_target()
		
	# tengo problema aqui de que acaba la palabra y no piensa en la nueva
	if word_in_progress.length() == target_word.length() and target_word.length() > 0 and target_word == copy_target_word:
		letter = choose_when_word_finished(letter)

	if letter == null and target_word != copy_target_word and !target_word.is_empty():
		letter = choose_from_next_target()
		#return smart_choosing_letter()
	if letter == null:
		print("falla ultimo")
	return letter
	
func get_target_word(letter, pos):
	#counter_placed = 1
	var hor_space = get_space_in_line(pos,"HORIZONTAL")
	var ver_space = get_space_in_line(pos,"VERTICAL")
	var space = ver_space if (ver_space > hor_space) else hor_space
	orient_target_word = "HORIZONTAL" if hor_space > ver_space else "VERTICAL"
	if copy_target_word.is_empty():
		orient_copy_target_word = orient_target_word
		copy_target_word = target_word
	print("orientacion: ",orient_target_word)

	target_word = get_desired_word(letter,space)
	index_target_word = 1
	print("Target Word = ", target_word)
	if target_word.length() < space:
		print("hay que añadir #")
		target_word += "#"
#returns a word that start by starting letter and of the size specified

func get_desired_word(starting_letter,size):
	print("encontrar una palabra que empieza por: ", starting_letter)
	print("y tiene de letras: ", size)
	print("se busca entre x palabras: ", DataLoader.bot_dictionary.keys().size())
	var word_found = ""
	var found = false
	while !found and size > 1:
		for w in DataLoader.bot_dictionary.keys():
			if w.length() == size and w.find(starting_letter) == 0 :
				word_found = w
				found = true
				break
		if !found: # If there is no existing word of that size, at least the longest
			size = size-1
			
	return word_found
	
