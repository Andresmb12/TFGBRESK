extends Node2D


# Called when the node enters the scene tree for the first time.
signal nextScene(scene)

func _ready():
	configure_buttons()
	
func configure_buttons():
	
	$PlayButtonMenu/TextureButton/TextButton.append_text("[center][color=BLACK][b]YEAH[/b][/color][/center]")
	$ExitButtonMenu/TextureButton/TextButton.append_text("[center][color=BLACK][b]QUIT[/b][/color][/center]")
	$CreditsButtonMenu/TextureButton/TextButton.append_text("[center][color=BLACK][b]CREDITS[/b][/color][/center]")



func _on_play_button_menu_pressed():
	
	SceneManager.change_scene("ProgressBar",SceneManager.create_options(),SceneManager.create_options(),SceneManager.create_general_options())
	
	pass # Replace with function body.


func _on_exit_button_menu_pressed():

	get_tree().quit() # default behavior
	pass # Replace with function body.
