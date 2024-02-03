extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	#get_tree().change_scene_to_file("res://MainPlayerScene.tscn")
	pass # Replace with function body.

func _process(delta: float) ->void :
	$lblTimeRemaining.text = "%s " % $TextureProgressBar.value + "%"
	if($TextureProgressBar == 100):
		_change_to_next_scene()

func _change_to_next_scene(new_scene):
	

func _on_timer_timeout():
	$TextureProgressBar.value+=20
	pass # Replace with function body.
