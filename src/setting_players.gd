extends Node2D

@export var players_available: OptionButton
@export var delete_icon: Texture2D
# Called when the node enters the scene tree for the first time.
func _ready():
	$nickname_ctnr.hide()
	$OptionButton.disabled = true
	$ReadyButton.disabled = true
	for p in DataLoader.all_players:
		players_available.add_item(p)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_check_box_toggled(toggled_on):
	
	$nplayers_sbox.editable = !toggled_on
	
	if(toggled_on):
		DataLoader.nplayers = $nplayers_sbox.value
		if  DataLoader.game_players.size() == DataLoader.nplayers:
			$ReadyButton.disabled = false
		
	else:
		$ReadyButton.disabled = true
	
	if DataLoader.game_players.size() < DataLoader.nplayers:
		$OptionButton.disabled = !toggled_on
		
		


func show_players_list():
	$VBoxContainer/ItemList.clear()
	for player in DataLoader.game_players:
		$VBoxContainer/ItemList.add_icon_item(delete_icon)
		$VBoxContainer/ItemList.add_item(player)
		
	

func _on_confirm_new_player_btn_pressed():
	var player_name = $nickname_ctnr/lne_input.text.to_upper()
	if player_name.length() > 0:
		DataLoader.game_players.append(player_name)
		$OptionButton.selected = -1
		$nickname_ctnr/lne_input.clear()
		$nickname_ctnr.hide()
		update_players_settings()
		
		
func update_players_settings():
	$OptionButton.selected = -1
	show_players_list()
	validate_n_players()

func _on_option_button_item_selected(index):
	
	if index == 0:
		$nickname_ctnr.show()
	else:
		DataLoader.game_players.append(players_available.get_item_text(index))
		$nickname_ctnr.hide()
		update_players_settings()

func validate_n_players():
	
	if DataLoader.game_players.size() == DataLoader.nplayers:
		
		$OptionButton.disabled = true
		$ReadyButton.disabled = false
	else:
		
		$OptionButton.disabled = false
		$ReadyButton.disabled = true
	

func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	
	if index % 2 == 0: #Trash Icon Selected
		if(index > 0):
			DataLoader.game_players.remove_at(index-1)
		else:
			DataLoader.game_players.remove_at(index)
		print(DataLoader.game_players)
		$VBoxContainer/ItemList.remove_item(index)
		$VBoxContainer/ItemList.remove_item(index)
		validate_n_players()
	



func _on_ready_button_pressed():
	DataLoader._next_scene = "MainPlayerScene"
	SceneManager.no_effect_change_scene("ProgressBar")
