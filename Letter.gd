extends LineEdit
# Letter script


func _ready():
	pass
	
func validate_letters(your_string):
	var regex = RegEx.new()
	regex.compile("[a-zA-Z]+")
	if regex.search(str(your_string)):
		return your_string.to_upper()
	else:
		return your_string.to_upper()#""
		
func _on_text_changed(new_text):
	text = validate_letters(new_text)
	text = text
	pass # Replace with function body.


func _on_focus_entered():
	#self.editable = true
	pass # Replace with function body.


func _on_gui_input(event):
	
	pass # Replace with function body.
