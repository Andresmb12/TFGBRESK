@tool
extends Control

# MainScene Script


@export var usernamevar: RichTextLabel
# Called when the node enters the scene tree for the first time.

var current_scene = null
func _ready():
	print("HOLAAA")
	$PlayerInfo/lblNickName.append_text("[center][color=BLACK][b]ANDRES M[/b][/color][/center]")



