extends Node2D


# Called when the node enters the scene tree for the first time.
signal nextScene(scene)

func _ready():
	configure_buttons()
	
func configure_buttons():
	
	$PlayButtonMenu/TextureButton/TextButton.append_text("[center][color=BLACK][b]JUGAR[/b][/color][/center]")
	$ExitButtonMenu/TextureButton/TextButton.append_text("[center][color=BLACK][b]SALIR[/b][/color][/center]")
	$RulesButtonMenu/TextureButton/TextButton.append_text("[center][color=BLACK][b]REGLAS[/b][/color][/center]")



func _on_play_button_menu_pressed():
	
	DataLoader._next_scene = "MainPlayerScene"
	
	#SceneManager.change_scene("ProgressBar",SceneManager.create_options(),SceneManager.create_options(),SceneManager.create_general_options())
	SceneManager.no_effect_change_scene("ProgressBar")
	
	pass # Replace with function body.


func _on_exit_button_menu_pressed():
	
	DataLoader._next_scene = "Exit"
	SceneManager.no_effect_change_scene("ProgressBar")
	
	 # default behavior
	pass # Replace with function body.


func _on_rules_button_menu_pressed():
	SceneManager.no_effect_change_scene("BreskRules")
	pass # Replace with function body.
