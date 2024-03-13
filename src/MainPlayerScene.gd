extends Node2D

# MainScene Script

@export var usernamevar: String
@onready var nickname = $PlayerInfo/lblNickName
@onready var id_player
@onready var n_scoreboard = $ScoreBoardRoot
@onready var n_scoreboxes = $ScoreBoxes
@onready var n_mainboard = $MainBoardRoot
@onready var last_index: Vector2

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
						
	print("Palabras en Horizontal: ", words)


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
	print("Palabras en Vertical: ", words)

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


func _on_texture_button_pressed():
	
	count_words_horz()
	count_words_vertz()


