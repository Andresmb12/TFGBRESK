extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	configure_buttons()

func configure_buttons():
	var playButton = get_node("PlayButtonMenu/TextureButton/TextButton")
	playButton.append_text("[center][color=BLACK][b]PLAY[/b][/color][/center]")
	var quitButton = get_node("ExitButtonMenu/TextureButton/TextButton")
	quitButton.append_text("[center][color=BLACK][b]QUIT[/b][/color][/center]")
	var creditsButton = get_node("CreditsButtonMenu/TextureButton/TextButton")
	creditsButton.append_text("[center][color=BLACK][b]CREDITS[/b][/color][/center]")


func _on_play_button_menu_pressed():
	get_tree().change_scene_to_file("res://ProgressBar.tscn")
	
	pass # Replace with function body.


func _on_exit_button_menu_pressed():
	get_tree().quit() # default behavior
	pass # Replace with function body.
