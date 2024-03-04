extends Node2D

# MainScene Script

@export var usernamevar: String
@onready var nickname = $PlayerInfo/lblNickName

@onready var n_scoreboard = $ScoreBoardRoot
@onready var n_scoreboxes = $ScoreBoxes
@onready var n_mainboard = $MainBoardRoot

@export var mainboard: Array
#Ahora desde la escena de cada jugador, dentro de mainboard, tengo acceso
# a todas las casillas del tablero mediante mainboard[col][row].text
# Called when the node enters the scene tree for the first time.

var current_scene = null

		
var user_player = "ANDRES"


func set_editable_subboards(order):
	n_mainboard.set_editable_board(order)
	n_scoreboard.set_editable_board(order)
	n_scoreboxes.set_editable_board(order)
	
func _ready():
	
	print("SCRIPT del main player Scene")
	
	set_player_name(usernamevar)

	
func set_player_name(name):
	usernamevar = name
	nickname.set_text("[center][color=BLACK][b]%s[/b][/color][/center]" % usernamevar.to_upper())


func _on_texture_button_pressed():
	SceneManager.no_effect_change_scene("InitialMenu")
