extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$nickname_ctnr.hide()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_check_box_toggled(toggled_on):
	$nplayers_sbox.editable = !toggled_on
	pass # Replace with function body.


func _on_confirm_new_player_btn_pressed():
	var player_name = $nickname_ctnr/LineEdit.text
	if player_name.length() > 0:
		DataLoader.players.append(player_name)
		$VBoxContainer/ItemList.add_item(player_name)
		$OptionButton.selected = -1
		$nickname_ctnr.hide()
		pass # Replace with function body.


func _on_option_button_item_selected(index):
	if index == 0:
		$nickname_ctnr.show()
	else:
		$nickname_ctnr.hide()
	pass # Replace with function body.



