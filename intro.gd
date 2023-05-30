extends Node2D


func _ready():
	$AnimationPlayer.play("intro1")
	await get_tree().create_timer(6).timeout
	$AnimationPlayer.play("fadeout")
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://MainScene.tscn")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
