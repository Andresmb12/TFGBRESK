extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func _process(_delta: float) ->void :
	$lblTimeRemaining.text = "%s " % $TextureProgressBar.value + "%"
	
	if($TextureProgressBar.value == 100):
		if DataLoader._next_scene == "Exit":
			get_tree().quit()
		else:
			SceneManager.change_scene(DataLoader._next_scene,DataLoader.fade_out_options, DataLoader.fade_in_options, DataLoader.general_options)
		pass

func _change_to_next_scene(new_scene):
	pass

func _on_timer_timeout():
	$TextureProgressBar.value+=20
	pass # Replace with function body.
