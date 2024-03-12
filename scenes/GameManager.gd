extends Control

#Members
@onready var next_step = $lbl_next_step
@onready var bresk_dice = $Dice1
@onready var alph_dice = $Dice2
@onready var grid = $GridContainer
@onready var current_player = $GridContainer/svpcontainer1/SubViewport1/MainScenePlayer1
@onready var lbl_turn = $lbl_game_turn
@onready var last_letter
@onready var letters_in_board = 0
@onready var cont_letters = 0
@onready var dice_player #has the id of the player who threw the dice
@onready var turn_completed = 0
@onready var n_chosen_letters = 0
@onready var n_placed_letters = 0
@onready var letters_to_place = 0
@onready var general_scale = Vector2(0.47, 0.47)
@onready var focus_scale = Vector2(0.85, 0.85)
@onready var last_index = Vector2(0,0)
@onready var current_play_type
@onready var cont_chosen_letters = $cont_chosen_letters
@onready var cont_letter1 = $cont_chosen_letters/cont_letter1
@onready var cont_letter2 = $cont_chosen_letters/cont_letter2
@onready var cont_letter3 = $cont_chosen_letters/cont_letter3
@onready var nplayers = DataLoader.nplayers
@onready var players_set = DataLoader.all_players
@onready var turn : int = 1
@onready var actions = {"0": "LO SENTIMOS! SALTAMOS TU TURNO", 
"1": "ELIGE 1 LETRA Y LUEGO \nCOLOCALA EN EL TABLERO","2": "ELIGE 2 LETRAS Y LUEGO \nCOLOCALAS EN EL TABLERO",
"3": "ELIGE 3 LETRAS Y LUEGO \nCOLOCALAS EN EL TABLERO", "BRESK": "TIRA EL DADO Y COLOCA UNA LETRA",
"4": "PULSA EN UNA CASILLA PARA COLOCAR LA LETRA" ,"NextPlayer": "TURNO DEL SIGUIENTE JUGADOR", 
"PlaceLetters": "COLOCA LAS LETRAS EN EL TABLERO", "7": "COLOCA LA LETRA EN EL TABLERO"}


var PlayersBoards: Dictionary
var Scores: Array

func _ready():
	DataLoader.play_type = DataLoader.game_play_types.SKIP
	current_play_type = DataLoader.game_play_types.SKIP
	grid.columns = 2
	grid.show()
	cont_chosen_letters.hide()
	for i in range(1,4):
		var cont_letter = cont_chosen_letters.get_node("cont_letter" + str(i))
		cont_letter.hide()

	for i in range(1,5):
		var p_container = get_node("GridContainer/svpcontainer" + str(i))
		p_container.hide()
	update_game()
	
func clean_letters_boxes():
	for i in range(1,4):
		var box = cont_chosen_letters.get_node("cont_letter" + str(i) + "/Letter" + str(i))
		box.clear()
		box.editable = true
		cont_chosen_letters.get_node("cont_letter" + str(i)).hide()

func show_next_step(action):
	current_player.modulate.a = 0.5
	var next_action = actions[action]
	next_step.text =  ("[center][color=WHITE][b]\n%s[/b][/color][/center]" % next_action)
	next_step.show()
	await get_tree().create_timer(4).timeout
	next_step.hide()
	
	current_player.modulate.a = 1
	
func update_game():
	if(turn_completed == nplayers):
		print("TURNO COMPLETADO, NEXT PLAYER ROLLS THE DICE")
		turn_completed = 0
		turn = turn % nplayers + 1 #Saltamos al tiró el dado el turno
		
	print("UPDATE GAME, TURNO DE ", turn)
	show_next_step("NextPlayer")
	
	cont_chosen_letters.hide()
	bresk_dice.hide()
	alph_dice.hide()
	#ARREGLAR QUE SE RESALTE EL JUGADOR CORRECTO DEL TURNO
	#Y TAMBIEN EL LABEL DE ES EL TURNO DE
	for i in range(1,nplayers+1):
		var p_container = get_node("GridContainer/svpcontainer" + str(i))
		if i != turn: #Difuminamos los tableros que no es su turno aun
			p_container.modulate.a = 0.5
		else:
			p_container.modulate.a = 1
		var player  = get_node("GridContainer/svpcontainer" + str(i) + "/SubViewport" + str(i) + "/MainScenePlayer" + str(i))
		player.set_player_name(players_set[i-1])
		#print("jugador configurado: ", player.usernamevar)
		player.id_player = i
		PlayersBoards[players_set[i-1]] = player
		if nplayers == 2:
			grid.columns = 1
			player.position.x = grid.size.x / 4
		
		p_container.show()
		player.scale = general_scale
			
	if(letters_in_board == 6 ):
		print("PARTIDA ACABADA, COMIENZA EL RECUENTO")
	else:
		focus_on_next_player()
		lbl_turn.text = ("[center][color=WHITE][b]ES TURNO DE %s[/b][/color][/center]" % players_set[turn-1])
	

func focus_on_player():
	print("llamada a focus_on_player , turno de ",turn)
		
	var root = get_tree().root
	
	grid.columns = 1
	
	for i in range(1,nplayers+1):
		var cont = grid.get_node("svpcontainer" + str(i))
		if(i == turn):
			
			print("turn_completed = ", turn_completed)
			cont.size = grid.size
			current_player = cont.get_node("SubViewport" + str(i) + "/MainScenePlayer" + str(i))
			current_player.position.x = 0
			current_player.scale = focus_scale
			current_player.set_editable_subboards(false)
			
		else:
			cont.hide()
			
	if turn_completed == 0: #New player rolls the dices
		
		clean_letters_boxes()
		bresk_dice.dice_is_thrown = false
		alph_dice.dice_is_thrown = false
		bresk_dice.show()
		bresk_dice.set_bresk_dice()
		bresk_dice.roll_dice()
		
	else: #Next player just places letters
		
		if current_play_type == DataLoader.game_play_types.BRESK:
			print("Colcoa la letra del dado Bresk")
			alph_dice.show()
			_on_alph_dice_thrown(alph_dice.result)
			
		if current_play_type == DataLoader.game_play_types.LETTER_TO_CHOOSE:
			print("Coloca letras")
			cont_chosen_letters.show()
			show_next_step("PlaceLetters")
			read_n_letters(int(bresk_dice.result))
			enable_placing_letters(int(bresk_dice.result))

	turn_completed += 1
	turn = turn % nplayers +1
	
func focus_on_next_player():
	print("SIGUIENTE JUGADOR")
	await get_tree().create_timer(5).timeout
	focus_on_player()
	pass # Replace with function body.

func go_back_to_game_view():
	
	grid.columns = 2
	update_game()


func _on_bresk_dice_thrown(result):
	
	show_next_step(result)
	
	if result=="0":
		DataLoader.play_type = DataLoader.game_play_types.SKIP
		await get_tree().create_timer(3).timeout
		turn_completed = 0
		#go_back_to_game_view()
	
	elif result == "BRESK":
		DataLoader.play_type = DataLoader.game_play_types.BRESK
		current_play_type = DataLoader.game_play_types.BRESK
		await get_tree().create_timer(3).timeout
		alph_dice.show()
		alph_dice.set_alphabet_dice()
		alph_dice.roll_dice()
		#throw second dice
	else:
		current_play_type =  DataLoader.game_play_types.LETTER_TO_CHOOSE
		current_player.n_mainboard.set_editable_board(false)
		read_n_letters(int(result))
		first_choose_n_letters(int(result))
		#read_n_letters(int(result))
		
#Cuando ya se han elegido las 3 letras , entonces se pueden colocar
#y ya no se pueden cambiar
func done_choosing_letters(n):
	for i in range(1,n+1):
			var cont_i = cont_chosen_letters.get_node("cont_letter" + str(i))
			var i_letter = cont_chosen_letters.get_node("cont_letter" + str(i) + "/Letter" + str(i))
			i_letter.disconnect("letter_entered", self.manage_placing_letters)
	print("Tablero desactivado")
	current_player.n_mainboard.set_editable_board(false)

func enable_placing_letters(n):
	
	for i in range(1,n+1):
		var cont_i = cont_chosen_letters.get_node("cont_letter" + str(i))
		var btn_i = cont_i.get_node("btn_letter" + str(i))
		btn_i.connect("pressed", self.on_btn_letter_n_pressed.bind(i))
			
#Contemplar en vez de usar n asi en las funciones usar el atributo result de BreskDice
func note_letter_to_players(letter):
	letters_in_board += 1
	print("Letras en el tablero:", letters_in_board)
	for i in range(1,nplayers+1):
		var player = grid.get_node("svpcontainer" + str(i) + "/SubViewport" + str(i) + "/MainScenePlayer" + str(i) )
		player.n_scoreboard.note_new_letter(letter, player.last_index)
		player.update_index()
		
		
		
func manage_placing_letters(letter, n):
	print("Señal recibida, n=",n)
	print("Letra elegida =", letter)
	note_letter_to_players(letter)
	n_chosen_letters += 1
	if n_chosen_letters == n:
		done_choosing_letters(n) #Disable Letters Boxes Lineedits
		enable_placing_letters(n)

func on_btn_letter_n_pressed(i_button):

	var cont_letter_i = cont_chosen_letters.get_node("cont_letter" + str(i_button)).get_node("Letter" + str(i_button))
	var btn_i = cont_chosen_letters.get_node("cont_letter" + str(i_button) + "/btn_letter" + str(i_button) )
	if !cont_letter_i.text.is_empty():
		current_player.n_mainboard.set_editable_board(false)
		#TRAS ESTA LINEA REALMENTE SE USA SIEMPRE EL GAME_PLAY_BRESK
		DataLoader.play_type = DataLoader.game_play_types.LETTER_TO_CHOOSE
		DataLoader.next_letter = cont_letter_i.text
		btn_i.disconnect("pressed", self.on_btn_letter_n_pressed)
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
		var i_letter = cont_chosen_letters.get_node("cont_letter" + str(i) + "/Letter" + str(i))
		i_letter.connect("letter_entered", self.manage_placing_letters.bind(n))
		
		
func save_letter(letter,n):
	print("last_index = ", last_index)
	cont_letters = cont_letters + 1
	print("LETTER SAVED: ", letter)
	print("cont_letters= ",cont_letters)
	print("n = ", n)
	current_player.count_words_horz()
	
	
	if cont_letters == n:
		#current_player.n_mainboard.disconnect("b_letter_entered", self.save_letter)
		await get_tree().create_timer(0.23).timeout
		current_player.set_editable_subboards(false)
		print("Tablero desactivado")
		await get_tree().create_timer(2).timeout
		show_next_step("NextPlayer")
		
		current_player.n_mainboard.disconnect("letter_placed", self.save_letter)
		$Button2.show()
		#go_back_to_game_view()
	
	pass
	
func read_n_letters(n):
	cont_letters = 0
	var i = 0
	letters_to_place = n
	current_player.n_mainboard.connect("letter_placed", self.save_letter.bind(n))
	pass
	
func handle_letter_placed(letter,n):
	
	n_placed_letters += 1
	if n_placed_letters == n:
		print("Letra colocada: ",letter)
		current_player.n_mainboard.disconnect("letter_placed", self.handle_letter_placed)
		show_next_step("NextPlayer")
		#await get_tree().create_timer(4).timeout
		#go_back_to_game_view()
		$Button2.show()
	
	
	
func _on_alph_dice_thrown(result):
	DataLoader.play_type = DataLoader.game_play_types.BRESK
	cont_letters = 0
	print("Ha salido la letra ", result)
	last_letter = result
	DataLoader.next_letter = result
	current_player.n_scoreboard.note_new_letter(result, current_player.last_index)
	current_player.update_index()
	show_next_step("4")
	alph_dice.dice_is_thrown = false
	current_player.n_mainboard.connect("letter_placed", self.save_letter.bind(1))
	
	pass # Replace with function body.





