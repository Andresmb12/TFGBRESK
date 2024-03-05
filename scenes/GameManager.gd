extends Control

#Members
@onready var current_player
@onready var next_step = $lbl_next_step
@onready var bresk_dice = $Dice1
@onready var alph_dice = $Dice2
@onready var grid = $GridContainer
@onready var viewport1 = $GridContainer/svpcontainer1/SubViewport1
@onready var lbl_turn = $lbl_game_turn
@onready var last_letter
@onready var last_index = Vector2(0,0)
@onready var player4 = $GridContainer/svpcontainer4/SubViewport4/MainScenePlayer4
@onready var nplayers = DataLoader.nplayers
@onready var turn : int = 1
@onready var actions = {"0": "LO SENTIMOS! SALTAMOS TU TURNO", 
"1": "COLOCA 1 LETRA EN EL TABLERO","2": "COLOCA 2 LETRAS EN EL TABLERO",
"3": "COLOCA 3 LETRAS EN EL TABLERO", "BRESK": "TIRA EL DADO Y COLOCA UNA LETRA",
"4": "PULSA EN UNA CASILLA PARA COLOCAR LA LETRA" }


var PlayersBoards: Dictionary
var Scores: Array

func _ready():
	DataLoader.play_type = DataLoader.game_play_types.SKIP
	grid.columns = 2
	for i in range(1,5):
		var p_container = get_node("GridContainer/svpcontainer" + str(i))
		p_container.hide()
	update_game()

func show_next_step(action):
	current_player.modulate.a = 0.5
	var next_action = actions[action]
	next_step.text =  ("[center][color=WHITE][b]\n%s[/b][/color][/center]" % next_action)
	next_step.show()
	await get_tree().create_timer(3).timeout
	next_step.hide()
	
	current_player.modulate.a = 1
	
func update_game():
	print("UPDATE GAME")
	next_step.hide()
	$Button.show()
	$Button2.hide()
	$Dice1.hide()
	$Dice2.hide()
	for i in range(1,nplayers+1):
		var p_container = get_node("GridContainer/svpcontainer" + str(i))
		if i != turn: #Difuminamos los tableros que no es su turno aun
			p_container.modulate.a = 0.5
		else:
			p_container.modulate.a = 1
		var player  = get_node("GridContainer/svpcontainer" + str(i) + "/SubViewport" + str(i) + "/MainScenePlayer" + str(i))
		player.set_player_name(DataLoader.game_players[i-1])
		PlayersBoards[DataLoader.game_players[i-1]] = player
		p_container.show()
		var scale : float = float(grid.columns) / float(nplayers)
		player.scale = Vector2(0.47, 0.47)
		
	lbl_turn.text = ("[center][color=WHITE][b]ES TURNO DE %s[/b][/color][/center]" % PlayersBoards.keys()[turn-1])
	

func focus_on_player():
	
	var root = get_tree().root
	grid.columns = 1
	for i in range(1,5):
		var cont = grid.get_node("svpcontainer" + str(i))
		print("es el turno de ",turn)
		if(i == turn):
			cont.size = grid.size
			current_player = cont.get_node("SubViewport" + str(i) + "/MainScenePlayer" + str(i))
			current_player.scale = Vector2(0.85,0.85)
			current_player.set_editable_subboards(false)
			
		else:
			cont.hide()
	print("en la primera casilla hay: ", current_player.get_letter(Vector2(0,0)))
	bresk_dice.dice_is_thrown = false
	alph_dice.dice_is_thrown = false
	$Button.hide()
	$Button2.show()
	bresk_dice.show()
	bresk_dice.set_bresk_dice()
	bresk_dice.roll_dice()
	
func _on_button_pressed():
	print("SIGUIENTE JUGADOR")
	focus_on_player()
	pass # Replace with function body.


func _on_button_2_pressed():
	
	grid.columns = 2
	turn = turn % nplayers + 1
	update_game()
	
	pass # Replace with function body.


func _on_bresk_dice_thrown(result):
	
	show_next_step(result)
	
	if result=="0":
		DataLoader.play_type = DataLoader.game_play_types.SKIP
		await get_tree().create_timer(2).timeout
		_on_button_2_pressed()
		pass
	elif result == "BRESK":
		
		await get_tree().create_timer(3).timeout
		alph_dice.show()
		alph_dice.set_alphabet_dice()
		alph_dice.roll_dice()
		#throw second dice
	else:
		DataLoader.play_type = DataLoader.game_play_types.LETTER_TO_CHOOSE
		current_player.set_editable_subboards(true)
		pass
		#chooses result letters to write
	


func _on_alph_dice_thrown(result):
	DataLoader.play_type = DataLoader.game_play_types.BRESK
	
	print("Ha salido la letra ", result)
	last_letter = result
	
	DataLoader.next_letter = result
	show_next_step("4")
	alph_dice.dice_is_thrown = false
	pass # Replace with function body.
