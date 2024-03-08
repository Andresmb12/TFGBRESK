extends Control

#Members
@onready var current_player
@onready var next_step = $lbl_next_step
@onready var bresk_dice = $Dice1
@onready var alph_dice = $Dice2
@onready var grid = $GridContainer
@onready var lbl_turn = $lbl_game_turn
@onready var last_letter
@onready var cont_letters = 0
@onready var n_chosen_letters = 0
@onready var general_scale = Vector2(0.47, 0.47)
@onready var focus_scale = Vector2(0.85, 0.85)
@onready var last_index = Vector2(0,0)
@onready var cont_chosen_letters = $cont_chosen_letters
@onready var cont_letter1 = $cont_chosen_letters/cont_letter1
@onready var cont_letter2 = $cont_chosen_letters/cont_letter2
@onready var cont_letter3 = $cont_chosen_letters/cont_letter3
@onready var nplayers = DataLoader.nplayers
@onready var turn : int = 1
@onready var actions = {"0": "LO SENTIMOS! SALTAMOS TU TURNO", 
"1": "ELIGE 1 LETRA Y LUEGO \nCOLOCALA EN EL TABLERO","2": "ELIGE 2 LETRAS Y LUEGO \nCOLOCALAS EN EL TABLERO",
"3": "ELIGE 3 LETRAS Y LUEGO \nCOLOCALAS EN EL TABLERO", "BRESK": "TIRA EL DADO Y COLOCA UNA LETRA",
"4": "PULSA EN UNA CASILLA PARA COLOCAR LA LETRA" ,"5": "TURNO DEL SIGUIENTE JUGADOR"}


var PlayersBoards: Dictionary
var Scores: Array

func _ready():
	DataLoader.play_type = DataLoader.game_play_types.SKIP
	grid.columns = 2
	grid.show()
	cont_chosen_letters.hide()
	for i in range(1,4):
		var cont_letter = cont_chosen_letters.get_node("cont_letter" + str(i))
		cont_letter.hide()
	#for i in range(1,4):
		#cont_chosen_letters.get_node("cont_letter" + str(i)).hide()
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
	#$Button.show()
	#$Button2.hide()
	$Dice1.hide()
	$Dice2.hide()
	
	focus_on_next_player()
	
	
	
	for i in range(1,nplayers+1):
		var p_container = get_node("GridContainer/svpcontainer" + str(i))
		if i != turn: #Difuminamos los tableros que no es su turno aun
			p_container.modulate.a = 0.5
		else:
			p_container.modulate.a = 1
		var player  = get_node("GridContainer/svpcontainer" + str(i) + "/SubViewport" + str(i) + "/MainScenePlayer" + str(i))
		player.set_player_name(DataLoader.all_players[i-1])
		PlayersBoards[DataLoader.all_players[i-1]] = player
		if nplayers == 2:
			grid.columns = 1
			player.position.x = grid.size.x / 4
		
		p_container.show()
		player.scale = general_scale
			
		
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
			current_player.position.x = 0
			current_player.scale = focus_scale
			current_player.set_editable_subboards(false)
			
		else:
			cont.hide()
	print("en la primera casilla hay: ", current_player.get_letter(Vector2(0,0)))
	bresk_dice.dice_is_thrown = false
	alph_dice.dice_is_thrown = false
	#$Button.hide()
	#$Button2.show()
	bresk_dice.show()
	bresk_dice.set_bresk_dice()
	bresk_dice.roll_dice()
	
func focus_on_next_player():
	print("SIGUIENTE JUGADOR")
	await get_tree().create_timer(5).timeout
	focus_on_player()
	pass # Replace with function body.


func go_back_to_game_view():
	
	grid.columns = 2
	turn = turn % nplayers + 1
	update_game()
	
	pass # Replace with function body.


func _on_bresk_dice_thrown(result):
	
	show_next_step(result)
	
	if result=="0":
		DataLoader.play_type = DataLoader.game_play_types.SKIP
		await get_tree().create_timer(3).timeout
		go_back_to_game_view()
		pass
	elif result == "BRESK":
		
		await get_tree().create_timer(3).timeout
		alph_dice.show()
		alph_dice.set_alphabet_dice()
		alph_dice.roll_dice()
		#throw second dice
	else:
		DataLoader.play_type = DataLoader.game_play_types.LETTER_TO_CHOOSE
		current_player.n_mainboard.set_editable_board(false)
		first_choose_n_letters(int(result))
		read_n_letters(int(result))
		
		pass
		#chooses result letters to write
		
func allow_placing_letters(letter, n):
	print("Señal recibida, n=",n)
	print("Letra elegida =", letter)
	n_chosen_letters += 1
	if n_chosen_letters == n:
		for i in range(1,n+1):
			var i_letter = cont_chosen_letters.get_node("cont_letter" + str(i) + "/Letter" + str(i))
			i_letter.disconnect("letter_entered", self.allow_placing_letters)
		print("Tablero desactivado")
		await get_tree().create_timer(4).timeout

func _on_btn_letter_n_pressed(i_button):
	print("Se llama")
	var cont_letter_i = cont_chosen_letters.get_node("cont_letter" + str(i_button)).get_node("Letter" + str(i_button))
	if !cont_letter_i.text.is_empty():
		current_player.n_mainboard.set_editable_board(false)
		current_player.n_mainboard.connect("letter_placed", self.handle_letter_placed)
		DataLoader.play_type = DataLoader.game_play_types.BRESK
		DataLoader.next_letter = cont_letter_i.text
		print("Se puede poner una letra")
	
	pass # Replace with function body.
	
func first_choose_n_letters(n):
	cont_chosen_letters.show()
	n_chosen_letters = 0
	var cont_i
	var btn_i
	for i in range(1,n+1):
		print("i = ",i)
		cont_i = cont_chosen_letters.get_node("cont_letter" + str(i))
		cont_i.show()
		btn_i = cont_i.get_node("btn_letter" + str(i))
		btn_i.connect("pressed", self.on_btn_letter_n_pressed)
		var i_letter = cont_chosen_letters.get_node("cont_letter" + str(i) + "/Letter" + str(i))
		i_letter.connect("letter_entered", self.allow_placing_letters.bind(n))
		
		

		
func save_letter(letter,n):
	
	cont_letters = cont_letters + 1
	print("LETTER SAVED: ", letter)
	print("cont_letters= ",cont_letters)
	print("n = ", n)
	if cont_letters == n:
		current_player.n_mainboard.disconnect("b_letter_entered", self.save_letter)
		await get_tree().create_timer(0.23).timeout
		current_player.set_editable_subboards(false)
		print("Tablero desactivado")
		show_next_step("5")
		await get_tree().create_timer(4).timeout
		go_back_to_game_view()
	
	pass
	
func read_n_letters(n):
	cont_letters = 0
	var i = 0
	current_player.n_mainboard.connect("b_letter_entered", self.save_letter.bind(n))
	pass
	
func handle_letter_placed(letter):
	print("Letra colocada: ",letter)
	show_next_step("5")
	await get_tree().create_timer(4).timeout
	go_back_to_game_view()
	
	
	
func _on_alph_dice_thrown(result):
	DataLoader.play_type = DataLoader.game_play_types.BRESK
	
	print("Ha salido la letra ", result)
	last_letter = result
	DataLoader.next_letter = result
	show_next_step("4")
	alph_dice.dice_is_thrown = false
	current_player.n_mainboard.connect("letter_placed", self.handle_letter_placed)
	
	pass # Replace with function body.





