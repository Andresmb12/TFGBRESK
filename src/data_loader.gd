extends Node

@onready var _next_scene = ""

@export var scene: String
@export var fade_out_speed: float = 1.0
@export var fade_in_speed: float = 1.0
@export var fade_out_pattern: String = "fade"
@export var fade_in_pattern: String = "fade"
@export var null_fade_out_pattern: String = "ignore"
@export var null_fade_in_pattern: String = "ignore"
@export var fade_out_smoothness = 0.1 # (float, 0, 1)
@export var fade_in_smoothness = 0.1 # (float, 0, 1)
@export var fade_out_inverted: bool = false
@export var fade_in_inverted: bool = false
@export var color: Color = Color(0, 0, 0)
@export var timeout: float = 0.0
@export var clickable: bool = false
@export var add_to_back: bool = true

@onready var all_players: Dictionary = { "Bot Principiante" : true, "Bot Pro": true ,"Bot Avanzado": true, "Bot Experto": true}
@onready var bot_players_levels: Dictionary = {"Bot Principiante" : "starter",  "Bot Pro": "pro", "Bot Avanzado" : "advanced","Bot Experto": "expert"}
@onready var nplayers: int = 3
@onready var game_players : Dictionary = Dictionary()
var PlayerScene = preload("res://scenes/MainPlayerScene.tscn")
@onready var current_player  = PlayerScene.instantiate()
enum game_play_types {BRESK, LETTER_TO_CHOOSE, SKIP, COUNT }
@onready var alphabet = [
	"A", "B", "C", "D", "E", "F", "G", "#","H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"
]
@onready var play_type
@onready var turn : int = 0
@onready var max_letters = 64
enum GAME_MODES {TEST, REAL}
@onready var current_game_mode = GAME_MODES.REAL
@onready var next_letter

@onready var fade_out_options = SceneManager.create_options(fade_out_speed, fade_out_pattern, fade_out_smoothness, fade_out_inverted)
@onready var fade_in_options = SceneManager.create_options(fade_in_speed, fade_in_pattern, fade_in_smoothness, fade_in_inverted)
@onready var general_options = SceneManager.create_general_options(color, timeout, clickable, add_to_back)
@onready var platform
@onready var bots_words_1 = "res://diccionarios/filtered_spanish_dictionary.txt"
@onready var bots_words_2= "res://diccionarios/new_filtered_spanish_dictionary.txt"
@onready var dictionary_route = "res://diccionarios/0_palabras_todas.txt"
@onready var spanish_dictionary = {}
@onready var choosing_letters = false
@onready var my_stylebox

# Called when the node enters the scene tree for the first time.
func _ready():
	
	print("estamos en ")
	print(OS.get_name())
	platform = OS.get_name()
	if OS.get_name()=="Android":
		get_viewport().size = DisplayServer.screen_get_size()
		pass
	if OS.get_name() == "Windows" or OS.get_name() == "Linux":
		get_viewport().size = Vector2i(1280,720)
		pass
		#
	
	pass # Replace with function body.

	
func get_longest_word(words):
	var longest = ""
	for w in words:
		if w.length() > longest.length():
			longest = w
	return longest
	
func find_occurrences(word: String, letter: String) -> Array:
	var occurrences = []
	for i in range(word.length()):
		if word[i] == letter:
			occurrences.append(i)

	return occurrences
	
func load_dictionary_from_file():
	
	var file = FileAccess.open(dictionary_route, FileAccess.READ)
	
	if file != null:
		var line = file.get_line()
		while line != "":
			line = line.strip_edges(true,true).to_upper()  # Eliminar espacios en blanco al principio y al final
			spanish_dictionary[line] = line  # La palabra se agrega como clave y como valor
			line = file.get_line()  # Leer la siguiente línea
		file.close()
		print("Diccionario cargado correctamente")
	else:
		print("No se pudo abrir el archivo:", dictionary_route)

func load_bot_words_from_file(route):
	var bot_dictionary = {}
	var file = FileAccess.open(route, FileAccess.READ)
	
	if file != null:
		var line = file.get_line()
		while line != "":
			line = line.strip_edges(true,true).to_upper()  # Eliminar espacios en blanco al principio y al final
			bot_dictionary[line] = line  # La palabra se agrega como clave y como valor
			line = file.get_line()  # Leer la siguiente línea
		file.close()
		print("Diccionario cargado correctamente")
		return bot_dictionary
	else:
		print("No se pudo abrir el archivo:", route)

func check_word(word):
	return spanish_dictionary.has(word)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

	
