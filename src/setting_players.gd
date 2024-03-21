extends Node2D

@export var players_available: OptionButton
@export var delete_icon: Texture2D
@onready var nick_cont = $nickname_ctnr
@onready var ready_bttn = $ReadyButton
@onready var players_list = $VBoxContainer/ItemList
@onready var disp_players = $disp_players_btn
# Called when the node enters the scene tree for the first time.


func _ready():
	nick_cont.hide()
	disp_players.disabled = true
	ready_bttn.disabled = true
	for p in DataLoader.all_players:
		players_available.add_item(p)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_check_box_toggled(toggled_on):
	
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
	var player_name = nick_cont.get_node("lne_input").text.to_upper()
	if player_name.length() > 0:
		DataLoader.game_players[player_name] = false
		disp_players.selected = -1
		nick_cont.get_node("lne_input").clear()
		nick_cont.hide()
		update_players_settings()
		
		
func update_players_settings():
	disp_players.selected = -1
	show_players_list()
	validate_n_players()

func _on_option_button_item_selected(index):
	
	if index == 0:
		nick_cont.show()
	else:
		DataLoader.game_players[players_available.get_item_text(index)] = true
		nick_cont.hide()
		update_players_settings()

func validate_n_players():
	
	if DataLoader.game_players.keys().size() == DataLoader.nplayers:
		
		disp_players.disabled = true
		ready_bttn.disabled = false

	else:
		disp_players.disabled = false
		ready_bttn.disabled = true
	

func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	
	if index % 2 == 0: #Trash Icon Selected
		if(index > 0):
			DataLoader.game_players.erase(players_available.get_item_text(index-1))
		else:
			DataLoader.game_players.erase(players_available.get_item_text(index))
		print(DataLoader.game_players)
		players_list.remove_item(index) #I delete the player and the icon
		players_list.remove_item(index)
		validate_n_players()
	



func _on_ready_button_pressed():
	
	DataLoader._next_scene = "GameManager"
	SceneManager.no_effect_change_scene("ProgressBar")
