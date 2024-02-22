@tool
extends Control

# MainScene Script


@export var usernamevar: RichTextLabel
# Called when the node enters the scene tree for the first time.

var current_scene = null
var user_player = DataLoader.game_players[0]
func _ready():
	
	$PlayerInfo/lblNickName.append_text("[center][color=BLACK][b]%s[/b][/color][/center]" % user_player.to_upper() )





func _on_texture_button_pressed():
	SceneManager.no_effect_change_scene("InitialMenu")
	pass # Replace with function body.
