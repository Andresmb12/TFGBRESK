extends Node2D

# MainScene Script

@export var usernamevar: String
@export var mainboard_node :Node2D
@export var scoreboard_node :Node2D
@export var scoreboxes_node :Node2D
@onready var nickname = $PlayerInfo/lblNickName
@onready var n_mboard = $MainBoardRoot/MainBoardTileMap


@export var mainboard: Array
#Ahora desde la escena de cada jugador, dentro de mainboard, tengo acceso
# a todas las casillas del tablero mediante mainboard[col][row].text
# Called when the node enters the scene tree for the first time.

var current_scene = null

		
var user_player = "ANDRES"

func constructor():
	usernamevar = $PlayerInfo/lblNickName.text
	mainboard_node = $MainBoardRoot
	scoreboard_node = $ScoreBoardRoot
	scoreboxes_node = $ScoreBoxes
	
func _ready():
	
	print("SCRIPT del main player Scene")
	
	set_player_name(usernamevar)

	
func set_player_name(name):
	usernamevar = name
	nickname.set_text("[center][color=BLACK][b]%s[/b][/color][/center]" % usernamevar.to_upper())



func set_mainboard(board):
	mainboard_node = board
	pass

func _on_texture_button_pressed():
	SceneManager.no_effect_change_scene("InitialMenu")
