@tool
extends Control

# MainScene Script

@export var usernamevar: RichTextLabel
@onready var mainboard_node
@onready var scoreboard_node
@onready var nickname = $PlayerInfo/lblNickName

@export var mainboard: Array
#Ahora desde la escena de cada jugador, dentro de mainboard, tengo acceso
# a todas las casillas del tablero mediante mainboard[col][row].text
# Called when the node enters the scene tree for the first time.

var current_scene = null

		
var user_player = "ANDRES"

func _ready():
	mainboard_node = get_node("MainBoardRoot")
	scoreboard_node = get_node("ScoreBoardRoot")
	print("desde aqui mide: ", mainboard_node.letters_main_board.size())
	mainboard = mainboard_node.letters_main_board
	print("SCRIPT del main player Scene")
	nickname.append_text("[center][color=BLACK][b]%s[/b][/color][/center]" % user_player.to_upper() )
	#user_player = DataLoader.game_players[0]
	

func _on_texture_button_pressed():
	
	SceneManager.no_effect_change_scene("InitialMenu")
	
	pass # Replace with function body.
