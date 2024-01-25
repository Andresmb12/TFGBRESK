extends Control
#MenuButton Script

# Called when the node enters the scene tree for the first time.

@export var textButton: RichTextLabel

var original_pos : Vector2

func _ready():
	original_pos = self.position
	pass
	
func interpolate_properties() -> void:
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector2(original_pos.x,original_pos.y-30),1)


func restore_properties() -> void:
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector2(original_pos.x,original_pos.y),1)

func _on_texture_button_mouse_entered():
	interpolate_properties()
	pass # Replace with function body.


func _on_texture_button_mouse_exited():
	restore_properties()
	pass # Replace with function body.
