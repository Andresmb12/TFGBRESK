extends Control

func _ready():
	configure_buttons()
	
func configure_buttons():
	
	$PlayButtonMenu/TextButton.append_text("[center][color=BLACK][b]JUGAR[/b][/color][/center]")
	$ExitButtonMenu/TextButton.append_text("[center][color=BLACK][b]SALIR[/b][/color][/center]")
	$RulesButtonMenu/TextButton.append_text("[center][color=BLACK][b]REGLAS[/b][/color][/center]")


func _on_play_button_menu_pressed():
	
	DataLoader._next_scene = "SettingPlayers"

	SceneManager.no_effect_change_scene("ProgressBar")


func _on_exit_button_menu_pressed():
	
	DataLoader._next_scene = "Exit"
	SceneManager.no_effect_change_scene("ProgressBar")


func _on_rules_button_menu_pressed():
	SceneManager.no_effect_change_scene("BreskRules")
