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
	if DataLoader.play_type == DataLoader.game_play_types.BRESK:
		text = DataLoader.next_letter
		DataLoader.play_type = DataLoader.game_play_types.SKIP
		self.editable = false
	if DataLoader.play_type == DataLoader.game_play_types.LETTER_TO_CHOOSE:
		pass
	if DataLoader.play_type == DataLoader.game_play_types.SKIP:
		
		pass
	pass # Replace with function body.


func _on_gui_input(event):
	
	pass # Replace with function body.
