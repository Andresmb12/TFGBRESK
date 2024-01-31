extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	#get_tree().change_scene_to_file("res://MainPlayerScene.tscn")
	pass # Replace with function body.





func _on_timer_timeout():
	$TextureProgressBar.value+=10
	pass # Replace with function body.
