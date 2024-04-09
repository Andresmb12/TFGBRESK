extends LineEdit
# Letter script

signal letter_placed(letter)
signal letter_entered(letter)

func _ready():

	pass
	
func validate_letters(your_string):
	var regex = RegEx.new()
	regex.compile("[a-zA-Z]+")
	if regex.search(str(your_string)):
		return your_string.to_upper()
	else:
		return your_string.to_upper()
		
func _on_text_changed(new_text):
	if !text.is_empty():
		text = validate_letters(new_text)
		text = text
		letter_entered.emit(text)
		self.editable = false
		pass # Replace with function body.


func _on_focus_entered():
	if DataLoader.play_type == DataLoader.game_play_types.BRESK and text.is_empty():
		text = DataLoader.next_letter
		letter_placed.emit(text,self)
		DataLoader.play_type = DataLoader.game_play_types.SKIP
		self.editable = false
		
	if DataLoader.play_type == DataLoader.game_play_types.LETTER_TO_CHOOSE and text.is_empty() :
		text = DataLoader.next_letter
		letter_placed.emit(text,self)
		DataLoader.play_type = DataLoader.game_play_types.SKIP
		self.editable = false
		pass
		
	if DataLoader.play_type == DataLoader.game_play_types.SKIP:
		pass
	pass # Replace with function body.


		
			
			
func _on_gui_input(event):
	
	pass # Replace with function body.
