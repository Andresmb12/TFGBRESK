extends LineEdit
# Number script
func _ready():
	pass
	

func _on_text_changed(new_text):
	text = new_text.to_upper()
	pass # Replace with function body.


func _on_focus_entered():
	self.editable = true
	pass # Replace with function body.


func _on_gui_input(event):
	
	pass # Replace with function body.
