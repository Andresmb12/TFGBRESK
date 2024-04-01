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
@onready var total_points: int
@onready var BOARD_LIMIT = 8
@onready var word_in_progress : String
@onready var target_word : String = ""
@onready var copy_target_word : String = ""
@onready var letter_chosen_by_me : bool = false
@onready var target_letter
@onready var orient_target_word
@onready var index_target_word
@onready var space_in_line : int #Huecos que me quedan donde quiero formar la palabra
@onready var pos_target_word : Vector2
@onready var first_letter_placed = false
@export var mainboard: Array
#Ahora desde la escena de cada jugador, dentro de mainboard, tengo acceso
# a todas las casillas del tablero mediante mainboard[row][col].text

func get_letter(row,col):
	return n_mainboard.letters_main_board[row][col].text
	
func set_score(points, row, col):
	n_mainboard.letters_main_board[row][col].text = str(points)
	
func place_letter(letter, pos):
	n_mainboard.letters_main_board[pos.x][pos.y].text = letter


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
	var row = (pos. x ) 
	var done = false
	var space = 0
	if orient == "HORIZONTAL" and (pos.y==0 or get_letter(row,pos.y-1)== "#"):
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
				print("hay una ", get_letter(row,col))
				done = true
		done = true
	print("Queda de espacio %s huecos" % space)
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
	
func smart_placing_letter(letter):
	
	if copy_target_word.is_empty():
		if letter != "#":
			word_in_progress = letter
		print("copy esta vacia")
		copy_target_word = target_word
		
	#print("word in progress: ")
	var arr_indexes = DataLoader.find_occurrences(copy_target_word,letter)
	
	var board = n_mainboard.letters_main_board
	var placed = false
	if letter == target_letter:
		index_target_word += 1
	if !arr_indexes.is_empty():
		
		for i in arr_indexes :
			if orient_target_word == "HORIZONTAL":
				if board[pos_target_word.x][pos_target_word.y + i].text.is_empty():
					board[pos_target_word.x][pos_target_word.y + i].text = letter
					print("La letra me sirve HORZ y la pongo donde corresponde")
					if !letter_chosen_by_me:
						word_in_progress += letter
					placed = true
					
					
					break
			if orient_target_word == "VERTICAL":
				if board[pos_target_word.x + i][pos_target_word.y].text.is_empty():
					board[pos_target_word.x + i][pos_target_word.y].text = letter
					print("La letra me sirve VERT y la pongo donde corresponde")
					if !letter_chosen_by_me:
						word_in_progress += letter
					placed = true
					
					break
	if !placed: # I try to place it otherwhere that does not mess my word
		for r in range(BOARD_LIMIT):
			if placed :
				break
			for c in range(BOARD_LIMIT):
				if (orient_target_word == "VERTICAL" and c != pos_target_word.y):
					if board[r][c].text.is_empty():
						board[r][c].text = letter
						placed = true
						break
				if (orient_target_word == "HORIZONTAL" and r != pos_target_word.x):
					if board[r][c].text.is_empty():
						board[r][c].text = letter
						placed = true
						
						break
		if placed:
			print("Se ha colocado en el hueco libre que no molesta a la target word")
	
	if !placed:
		print("No se ha encontrado un hueco bueno asi que haremos dummy placing")
		return -1
	else:
		return 0
							

func check_last_letter():
	print("CHECK LAST LETTER")
	if copy_target_word.length() == word_in_progress.length() and copy_target_word.length() > 0:
		print("palabra completada")
		word_in_progress = ""
		print("Ahora si que nos olvidamos de la ex target word")
		copy_target_word = target_word
		
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
				if !get_letter(r,c).is_empty():
					aux_target_hor = get_space_in_line(Vector2(r,c),"HORIZONTAL")
					aux_target_ver = get_space_in_line(Vector2(r,c),"VERTICAL")
					candidate = aux_target_hor if aux_target_hor > aux_target_ver else aux_target_ver
					if candidate > best_next_target:
						print("candidate = ", candidate)
						best_next_target = candidate
						aux_pos = Vector2(r,c)
	else:
		aux_pos = dummy_placing_letters()
			
	print("La mejor pos para empezar una palabra es: ", aux_pos)
	print("Con puntuacion: ", candidate)
	
	return aux_pos
			
func dummy_placing_letters():
	for row in range(8):
			for col in range(8):
				if get_letter(row,col).is_empty():
					return Vector2(row,col)
					
func smart_choosing_letter(n=1):
	var letter
	var index
	letter_chosen_by_me = true
			
	if target_word.is_empty() :
		
		index = randi() % SmartBots.consonants.size()
		letter = SmartBots.consonants[index]
		word_in_progress += letter
		
		get_target_word(letter, pos_target_word)
		copy_target_word = target_word
		print("target word generada con letra random: ", target_word)
		#index_target_word = 1
		 
	elif word_in_progress.length() != target_word.length():
		print("target word = ", target_word)
		var not_okay = true
		while(not_okay):
			
			letter = target_word[index_target_word]
			print("target letter es", letter)
			if DataLoader.find_occurrences(target_word,letter).size() > DataLoader.find_occurrences(word_in_progress,letter).size():
				not_okay = false
				if target_word.length() == word_in_progress.length():
					# Asi en cuanto pongo la ultima letra ya la regenero
					copy_target_word = ""
					print("ultima letra puesta")
		
			if !target_word.is_empty():		
				index_target_word = (index_target_word + 1) % target_word.length()
		
		
		word_in_progress += letter
		print("word in progress es: ", word_in_progress)
		print("la letra a devilver es: ", letter)
		
		if word_in_progress.length() == target_word.length() and target_word.length() > 0:
			print("PALABRA ACABADA")
			target_word = ""
			var aux =  choose_next_target_pos()
			var l =  get_letter(aux.x, aux.y)
			get_target_word(l,aux)
			print("ahora target word es: ", target_word)
			letter = target_word[index_target_word]
			# ULTIMAS LINEAS
			#return smart_choosing_letter()
			pass
		return letter
		
	if word_in_progress.length() + 1 == target_word.length() and target_word.length() > 0: #If word in progress = target word, we place #
		print("Ya reiniciamos TARGET WORD")
		#print("nuevo target word", target_word)
		# en vez de coger una letra random, miramos que letra tiene más espacio
		# y buscamos nueva target word
		target_word = ""
		pos_target_word = choose_next_target_pos()
		word_in_progress = ""
		
		return letter
		
	return letter
	
func get_target_word(letter, pos):
	var hor_space = get_space_in_line(pos,"HORIZONTAL")
	var ver_space = get_space_in_line(pos,"VERTICAL")
	var space = ver_space if (ver_space > hor_space) else hor_space
	orient_target_word = "HORIZONTAL" if hor_space > ver_space else "VERTICAL"
	print("orientacion: ",orient_target_word)

	target_word = get_desired_word(letter,space)
	index_target_word = 1
	print("Target Word = ", target_word)
#returns a word that start by starting letter and of the size specified

func get_desired_word(starting_letter,size):
	var word_found = ""
	var found = false
	while !found:
		for w in DataLoader.spanish_dictionary.keys():
			if w.find(starting_letter) == 0 and w.length() == size:
				word_found = w
				found = true
				break
		if !found: # If there is no existing word of that size, at least the longest
			size = size-1
	return word_found
	
