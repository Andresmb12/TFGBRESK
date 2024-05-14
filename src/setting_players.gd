extends Control

@export var players_available: OptionButton
@export var delete_icon: Texture2D

@onready var ready_bttn = $ReadyButton
@onready var players_list = $VBoxContainer/ItemList
@onready var disp_players = $disp_players_btn
# Called when the node enters the scene tree for the first time.

func hide_new_player_fields():
	#$lne_input.clear()
	$lne_input.hide()
	$confirm_btn.hide()
	$input_nicknm_te.hide()
	
func show_new_player_fields():
	$lne_input.show()
	$confirm_btn.show()
	$input_nicknm_te.show()
	$lne_input.grab_focus()
	
func _ready():
	
	$lne_input.hide()
	$confirm_btn.hide()
	$input_nicknm_te.hide()
	disp_players.disabled = true
	ready_bttn.disabled = true
	#$nplayers_sbox.get_line_edit().connect("focus_entered",self._on_nplayers_sbox_focus_entered)

	for p in DataLoader.all_players:
		players_available.add_item(p)
		



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_check_box_toggled(toggled_on):
	$CheckBox.icon
	$nplayers_sbox.editable = !toggled_on
	
	if(toggled_on):
		DataLoader.nplayers = $nplayers_sbox.value
		if  DataLoader.game_players.keys().size() == DataLoader.nplayers:
			ready_bttn.disabled = false
		
	else:
		ready_bttn.disabled = true
	
	if DataLoader.game_players.keys().size() < DataLoader.nplayers:
		disp_players.disabled = !toggled_on
		
		


func show_players_list():
	players_list.clear()
	for player in DataLoader.game_players.keys():
		players_list.add_icon_item(delete_icon)
		players_list.add_item(player)
		
	

func _on_confirm_new_player_btn_pressed():
	var player_name =$lne_input.text.to_upper()
	if player_name.length() > 0:
		DataLoader.game_players[player_name] = false
		disp_players.selected = -1
		
		hide_new_player_fields()
		
		update_players_settings()
		
		
func update_players_settings():
	disp_players.selected = -1
	show_players_list()
	validate_n_players()

func _on_option_button_item_selected(index):
	
	if index == 0:
		show_new_player_fields()
		
	else:
		DataLoader.game_players[players_available.get_item_text(index)] = true
		hide_new_player_fields()
		update_players_settings()

func validate_n_players():
	
	if players_list.item_count / 2 == DataLoader.nplayers:
		
		disp_players.disabled = true
		ready_bttn.disabled = false

	else:
		disp_players.disabled = false
		ready_bttn.disabled = true
	

func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	
	if index % 2 == 0: #Trash Icon Selected
		
		DataLoader.game_players.erase(players_list.get_item_text(index+1))
		print(DataLoader.game_players)
		players_list.remove_item(index) #I delete the player and the icon
		players_list.remove_item(index)
		validate_n_players()
	

func _on_ready_button_pressed():
	
	DataLoader._next_scene = "GameManager"
	SceneManager.no_effect_change_scene("ProgressBar")



func _on_exit_button_pressed():
	get_tree().quit()
	pass # Replace with function body.
