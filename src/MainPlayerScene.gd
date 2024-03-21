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
@onready var target_letter
@onready var orient_target_word
@onready var index_target_word
@onready var space_in_line : int #Huecos que me quedan donde quiero formar la palabra
@onready var pos_target_word
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
	var col = pos.y + 1
	var row = pos. x + 1
	var done = false
	var space = 0
	if orient == "HORIZONTAL":
		while col < BOARD_LIMIT and !done:
			if get_letter(row,col).is_empty():
				space += 1
			else:
				done = true
			col += 1
		done = true
	if orient == "VERTICAL":
		while row < BOARD_LIMIT and !done:
			if get_letter(row,col).is_empty():
				space += 1
			else:
				done = true
			row += 1
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
	print("tam=",n_mainboard.letters_main_board.size())
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
	print("SCRIPT del main player Scene")
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
	var i =  target_word.find(letter,word_in_progress.length())
	var board = n_mainboard.letters_main_board
	var placed = false
	if i != -1:
		print("Miro si la letra se puede poner en la palabra target")
		if orient_target_word == "HORIZONTAL":
			if board[pos_target_word.x][pos_target_word.y + i].is_empty():
				board[pos_target_word.x][pos_target_word.y + i].text = letter
				print("La letra me sirve y la pongo donde corresponde")
				placed = true
		if orient_target_word == "VERTICAL":
			if board[pos_target_word.x + i][pos_target_word.y].is_empty():
				board[pos_target_word.x + i][pos_target_word.y].text = letter
				print("La letra me sirve y la pongo donde corresponde")
				placed = true
	if !placed: # I try to place it otherwhere that does not mess my word
		for r in range(BOARD_LIMIT):
			for c in range(BOARD_LIMIT):
				if (orient_target_word == "VERTICAL" and c != pos_target_word.y):
					if board[r][c].text.is_empty():
						board[r][c].text = letter
						placed = true
				if (orient_target_word == "HORIZONTAL" and r != pos_target_word.x):
					if board[r][c].text.is_empty():
						placed = true
		if placed:
			print("Se ha colocado en el hueco libre que no molesta a la target word")
			
	if !placed:
		print("No se ha encontrado un hueco bueno asi que haremos dummy placing")
		return -1
							
		
# We JUST choose letter
func smart_choosing_letter(n=1):
	
	var letter
	var index
	if target_word.is_empty():
		index =  randi() % SmartBots.consonants.size()
		letter = SmartBots.consonants[index]
		word_in_progress += letter
		 
	elif word_in_progress != target_word:
		target_letter = target_word[index_target_word]
		letter = target_letter
		word_in_progress += letter
		index_target_word += 1
		
		
	else: #If word in progress = target word, we place #
		letter = SmartBots.space
		target_word = ""
	return letter
	
func get_target_word():
	var ver_space = get_space_in_line(pos_target_word,"HORIZONTAL")
	var hor_space = get_space_in_line(pos_target_word,"VERTICAL")
	var space = ver_space if (ver_space > hor_space) else hor_space
	orient_target_word = "HORIZONTAL" if hor_space > ver_space else "VERTICAL"
	
	print("Espacio libre a la ")
	if word_in_progress.length() == 1:
		target_word = get_desired_word(word_in_progress,space)
		print("Target Word = ", target_word)
		pass
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
	
