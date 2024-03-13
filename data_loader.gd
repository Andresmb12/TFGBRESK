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

@onready var all_players: Array = ["Algoritmo-1","Algoritmo-2","Algoritmo-3","Algoritmo-4"]
@onready var nplayers: int = 4;
@onready var game_players : Array = Array()
var PlayerScene = preload("res://scenes/MainPlayerScene.tscn")
@onready var current_player  = PlayerScene.instantiate()
enum game_play_types {BRESK, LETTER_TO_CHOOSE, SKIP }
@onready var play_type
@onready var turn : int = 0
@onready var next_letter
@onready var fade_out_options = SceneManager.create_options(fade_out_speed, fade_out_pattern, fade_out_smoothness, fade_out_inverted)
@onready var fade_in_options = SceneManager.create_options(fade_in_speed, fade_in_pattern, fade_in_smoothness, fade_in_inverted)
@onready var general_options = SceneManager.create_general_options(color, timeout, clickable, add_to_back)

@onready var dictionary_route = "res://diccionarios/0_palabras_todas.txt"
@onready var spanish_dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func load_dictionary_from_file():
	
	var file = FileAccess.open(dictionary_route, FileAccess.READ)
	if file != null:
		var linea = file.get_line()
		while linea != "":
			linea = linea.strip_edges(true,true).to_upper()  # Eliminar espacios en blanco al principio y al final
			spanish_dictionary[linea] = linea  # La palabra se agrega como clave y como valor
			linea = file.get_line()  # Leer la siguiente línea
		file.close()
		print("Diccionario cargado correctamente")
	else:
		print("No se pudo abrir el archivo:", dictionary_route)

func check_word(word):
	return spanish_dictionary.has(word)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

	
