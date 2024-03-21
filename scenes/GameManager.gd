extends Control

#Members
@onready var next_step = $lbl_next_step
@onready var bresk_dice = $Dice1
@onready var alph_dice = $Dice2
@onready var grid = $GridContainer
@onready var back_to_results = $back_to_results_btn
@onready var current_player = $GridContainer/svpcontainer1/SubViewport1/MainScenePlayer1
@onready var lbl_turn = $lbl_game_turn
@onready var results_screen = $ResultsScreen
@export var view_icon: Texture2D
@export var delete_icon: Texture2D
@onready var last_letter
@onready var letters_in_board = 0
@onready var cont_letters = 0
@onready var dice_player #has the id of the player who threw the dice
@onready var turn_completed = 0
@onready var n_chosen_letters = 0
@onready var n_placed_letters = 0
@onready var general_scale = Vector2(0.47, 0.47)
@onready var focus_scale = Vector2(0.85, 0.85)
@onready var last_index = Vector2(0,0)
@onready var current_play_type
@onready var cont_chosen_letters = $cont_chosen_letters
@onready var cont_letter1 = $cont_chosen_letters/cont_letter1
@onready var cont_letter2 = $cont_chosen_letters/cont_letter2
@onready var cont_letter3 = $cont_chosen_letters/cont_letter3
@onready var results_list = $ResultsScreen/results_list
@onready var nplayers = DataLoader.nplayers
@onready var players_set : Dictionary
@onready var data_players = []
@onready var turn : int = 1
@onready var longest_bonus_winner = []
@onready var GAME_FINISHED = false
@onready var SHOW_RESULTS = false
@onready var game_longest_word
@onready var index_letter_to_place
@onready var max_words_formed = 0
@onready var max_words_bonus_winner
@onready var actions = {"0": "LO SENTIMOS! SALTAMOS TU TURNO", 
"1": "ELIGE 1 LETRA Y LUEGO \nCOLOCALA EN EL TABLERO","2": "ELIGE 2 LETRAS Y LUEGO \nCOLOCALAS EN EL TABLERO",
"3": "ELIGE 3 LETRAS Y LUEGO \nCOLOCALAS EN EL TABLERO", "BRESK": "TIRA EL DADO Y COLOCA UNA LETRA",
"4": "PULSA EN UNA CASILLA PARA COLOCAR LA LETRA" ,"NextPlayer": "TURNO DEL SIGUIENTE JUGADOR", 
"PlaceLetters": "COLOCA LAS LETRAS EN EL TABLERO", "7": "COLOCA LA LETRA EN EL TABLERO",
"end": "PARTIDA ACABADA, COMIENZA EL RECUENTO", "throw": "tira el dado"}


func _ready():
	$Button.hide()
	$Button.show()
	if DataLoader.game_players.is_empty():
		players_set = DataLoader.all_players
		nplayers = DataLoader.all_players.size()
		nplayers = 2
	else:
		players_set = DataLoader.game_players
	var player
	for p in range(1,nplayers+1):
		data_players.append(get_player(p))
		player = get_player(p)
		player.set_player_name(players_set.keys()[p-1])
		print("Cargo al jugador: ", player.usernamevar)
		player.is_bot = players_set[player.usernamevar]
		if player.is_bot:
			player.set_editable_subboards(false)
			
		print("Es BOT?", player.is_bot)
		print(data_players[p-1])
	results_screen.hide()
	DataLoader.load_dictionary_from_file()
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
	#show_results_screen()
	
func clean_letters_boxes():
	for i in range(1,4):
		var box = cont_chosen_letters.get_node("cont_letter" + str(i) + "/Letter" + str(i))
		box.clear()
		box.editable = true
		cont_chosen_letters.get_node("cont_letter" + str(i)).hide()
		

	
func show_next_step(action):
	#current_player.modulate.a = 0.5
	var next_action = actions[action]
	next_step.text =  ("[center][color=WHITE][b]\n%s %s[/b][/color][/center]" % [current_player.usernamevar , next_action] )
	next_step.show()
	await get_tree().create_timer(3).timeout
	next_step.hide()
	
	current_player.modulate.a = 1
	
func update_game():
	if(turn_completed == nplayers): #CHECK IF CURRENT PLAY IS FINISHED
		if letters_in_board == DataLoader.max_letters: #END OF GAME
			turn = 0
			GAME_FINISHED = true
			current_play_type = DataLoader.game_play_types.COUNT
			print("JUEGO ACABADO")
			show_next_step("end")
			
		print("TURNO COMPLETADO, NEXT PLAYER ROLLS THE DICE")
		turn_completed = 0
		turn = turn % nplayers + 1 # We jump to the next player who se
		
	
	print("UPDATE GAME, TURNO DE ", turn)
	show_next_step("NextPlayer")
	
	cont_chosen_letters.hide()
	bresk_dice.hide()
	alph_dice.hide()

	# Here we show all the players and their boards
	for i in range(1,nplayers+1):
		var p_container = get_node("GridContainer/svpcontainer" + str(i))
		if i == turn or GAME_FINISHED: # We highlight the board of the turn's player
			p_container.modulate.a = 1
		else:
			p_container.modulate.a = 0.5
		var player  = get_player(i)
		
		if nplayers == 2: # In this case I change the view
			grid.columns = 1
			player.position.x = grid.size.x / 4
		p_container.show()
		player.scale = general_scale
	print("DE MOMENTO SE HAN PUESTO DE LETRAS: ",letters_in_board)
		
	if !SHOW_RESULTS:
		focus_on_next_player()
	#lbl_turn.text = ("[center][color=WHITE][b]ES TURNO DE %s[/b][/color][/center]" % DataLoader.all_players[turn-1].usernamevar)
	
func get_player(i):
	var p = get_node("GridContainer/svpcontainer" + str(i) + "/SubViewport" + str(i) + "/MainScenePlayer" + str(i))
	return p
	
func get_bonuses_winners():	
	game_longest_word = ""
	
	for i in range(1,nplayers+1):
		var player  = get_player(i)
		if player.longest_word.length() > game_longest_word.length() :
			longest_bonus_winner = i
			game_longest_word = player.longest_word
		if player.words_formed_by_player.size() > max_words_formed:
			max_words_formed = player.words_formed_by_player.size()
			max_words_bonus_winner = i
	
			

func get_winner():
	var longest_words = []
	var winner_score = 0
	var winner
	get_bonuses_winners()
	#aqui me he quedado
	for i in range(1,nplayers+1):
		var player  = get_node("GridContainer/svpcontainer" + str(i) + "/SubViewport" + str(i) + "/MainScenePlayer" + str(i))
		#player.calculate_points()
		if player.longest_word.length() == game_longest_word.length():
			player.n_scoreboxes.set_longest_bonus(true)
			player.total_points += 5
		else:
			player.n_scoreboxes.set_longest_bonus(false)
			
		if player.words_formed_by_player.size() == max_words_formed:
			player.n_scoreboxes.set_words_bonus(true)
			player.total_points += 3
		else:
			player.n_scoreboxes.set_words_bonus(false)
		if player.total_points > winner_score:
			winner_score = player.total_points
			winner = player
	for i in range(1,nplayers+1):
		var p = get_player(i)
		p.n_scoreboxes.set_total_score(p.total_points)
	lbl_turn.text = ("[center][color=WHITE][b]EL GANADOR ES %s[/b][/color][/center]" % winner.usernamevar)
	#show_results_screen()
	# AQUI HACER ALGO PARA DETENER POR COMPLETO EL JUEGO Y QUE NO SE VUELVA A HACER FOCUS ON PLAYER
	#QUEDANDOSE SOLO EL GAME_VIEW
		

func show_results_screen():
	back_to_results.hide()
	grid.hide()
	cont_chosen_letters.hide()
	$Dice2.hide()
	$Dice1.hide()
	$Button.hide()
	$Button2.hide()
	results_screen.show()
	
func fill_results_table():
	#results_screen.show()
	results_list.add_item("               JUGADOR")
	results_list.add_item("          NºPALABRAS")
	results_list.add_item("   PALABRA MAS LARGA   ")
	results_list.add_item("     PUNTOS TOTALES   ")
	sort_players()
	var prueba = false
	var aux = 5
	var word = "ye"
	print("hay n jugadores n=", data_players.size())
	for p in data_players:
		if prueba:
			aux = aux + 2
			p.longest_word = word
			word = "petardos"
			p.total_points = aux * 2
			p.words_formed_by_player = ["y", "a", "e"]
			
			results_list.add_item("       " + "ANDRES",view_icon)
			results_list.add_item("                   " + str(15))
			results_list.add_item("                " + p.longest_word)
			results_list.add_item("                     " + str(p.total_points))
		else:
			
			results_list.add_item("       " + p.usernamevar,view_icon)
			results_list.add_item("                   " + str(p.words_formed_by_player.size()))
			results_list.add_item("                " + p.longest_word)
			results_list.add_item("                     " + str(p.total_points))

	
func compare_players(p1,p2):
	return p2.total_points < p1.total_points
	
func sort_players():
	data_players.sort_custom(compare_players)

func make_focus(turn):
	var root = get_tree().root
	
	grid.columns = 1
	
	for i in range(1,nplayers+1):
		var cont = grid.get_node("svpcontainer" + str(i))
		if(i == turn):
			print("se entra")
			cont.size = grid.size
			current_player = get_player(i) # IMP here I get CURRENT PLAYER
			current_player.position.x = 0
			current_player.scale = focus_scale
			current_player.set_editable_subboards(false)
		else:
			cont.hide()
			
func focus_on_player():
	
	make_focus(turn)
	
	if turn_completed == 0 and !GAME_FINISHED: #New player rolls the dices
		
		clean_letters_boxes()
		bresk_dice.dice_is_thrown = false
		alph_dice.dice_is_thrown = false
		bresk_dice.show()
		bresk_dice.set_bresk_dice()
		bresk_dice.roll_dice()
		
		if current_player.is_bot:
			bresk_dice.focus_mode = Control.FOCUS_NONE
			print("Juega ahora un BOT")
			show_next_step("throw")
			await get_tree().create_timer(3).timeout
			
			bresk_dice._on_button_pressed() # First he throws the dice
			
			
		
	else: #Next player just places letters
			
		if current_play_type == DataLoader.game_play_types.COUNT:
			show_next_step("end")
			await get_tree().create_timer(2).timeout
			current_player.calculate_points()
			if turn == nplayers:
				await get_tree().create_timer(3).timeout
				SHOW_RESULTS = true
				get_winner()
				$Button.show()
				
			await get_tree().create_timer(3).timeout
			go_back_to_game_view()
			
		if current_play_type == DataLoader.game_play_types.BRESK:
			alph_dice.show()
			_on_alph_dice_thrown()
			
		if current_play_type == DataLoader.game_play_types.LETTER_TO_CHOOSE:
			cont_chosen_letters.show()
			show_next_step("PlaceLetters")
			read_n_letters(int(bresk_dice.result))
			print("llamada a enable en el IF")
			enable_placing_letters(int(bresk_dice.result))
		

	turn_completed += 1
	turn = turn % nplayers +1
	
	
	

	
func focus_on_next_player():
	
	print("SIGUIENTE JUGADOR")
	await get_tree().create_timer(2).timeout
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
		go_back_to_game_view()
	
	elif result == "BRESK":
		current_play_type = DataLoader.game_play_types.BRESK
		await get_tree().create_timer(3).timeout
		alph_dice.show()
		alph_dice.set_alphabet_dice()
		alph_dice.roll_dice()
		letters_in_board += 1
		
		if current_player.is_bot: # Bot throws letters dice
			alph_dice.focus_mode = Control.FOCUS_NONE
			show_next_step("throw")
			await get_tree().create_timer(3).timeout
			alph_dice._on_button_pressed()
		#throw second dice
	else:
		current_play_type =  DataLoader.game_play_types.LETTER_TO_CHOOSE
		current_player.n_mainboard.set_editable_board(false)
		if letters_in_board + int(result) > DataLoader.max_letters:
			result = str(DataLoader.max_letters - letters_in_board)
			bresk_dice.result = result
		
		read_n_letters(int(result)) # Allow to 
		first_choose_n_letters(int(result))
		if current_player.is_bot:
			bot_choose_letters(int(result))
			await get_tree().create_timer(3).timeout
			show_next_step(result)
			
		
func bot_choose_letters(n):
	var chosen_letter
	var index
	cont_chosen_letters.focus_mode = Control.FOCUS_NONE
	for i in range(1,n+1):
		# chosen_letter = dummy_choose_a_letter()
		chosen_letter = current_player.smart_choosing_letter()
		await get_tree().create_timer(2).timeout
		
		get_letter(i).text = chosen_letter
		get_letter(i).letter_entered.emit(chosen_letter)

func dummy_choose_a_letter():
	var index = randi() % DataLoader.alphabet.size()
	var chosen_letter = DataLoader.alphabet[index]
	return chosen_letter

func dummy_placing_letters():
	for row in range(8):
			for col in range(8):
				if current_player.get_letter(row,col).is_empty():
					return Vector2(row,col)
					
	
func bot_place_letters(n,choose = true):
	var board = current_player.n_mainboard.letters_main_board
	var pos
	var letter
	var placed = 1
	for i in range(1,n+1):
		if choose :
			letter = get_letter(i).text
		else:
			letter = DataLoader.next_letter
			
		await get_tree().create_timer(2.5).timeout
		
		if current_player.smart_placing_letter(letter) == -1:
			pos = dummy_placing_letters()
			print("posicion dummy elegida: ",pos)
			current_player.pos_target_word = pos
			current_player.get_target_word()
			board[pos.x][pos.y].text = letter
			DataLoader.next_letter = letter

		
		save_letter(letter,n)
					
#Cuando ya se han elegido las 3 letras , entonces se pueden colocar
#y ya no se pueden cambiar
func done_choosing_letters(n):
	for i in range(1,n+1):
			var cont_i = cont_chosen_letters.get_node("cont_letter" + str(i))
			var i_letter = get_letter(i)
			i_letter.disconnect("letter_entered", self.manage_placing_letters)
	print("Tablero desactivado")
	current_player.n_mainboard.set_editable_board(false)

func enable_placing_letters(n):
	if current_player.is_bot:
		bot_place_letters(n)
	else:
		for i in range(1,n+1):
			var cont_i = cont_chosen_letters.get_node("cont_letter" + str(i))
			cont_i.modulate.a = 1
			var btn_i = get_button(i)
			var i_letter = get_letter(i)
			if !btn_i.is_connected("pressed",self.on_btn_letter_n_pressed):
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
		print("Ya se han elegido las letras")
		done_choosing_letters(n) #Disable Letters Boxes Lineedits
		print("llamada e enable en manage_placing")
		enable_placing_letters(n)

func on_btn_letter_n_pressed(i_button):
	print("i_button= ",i_button )
	var cont_letter_i = cont_chosen_letters.get_node("cont_letter" + str(i_button)).get_node("Letter" + str(i_button))
	var btn_i = get_button(i_button)
	if !cont_letter_i.text.is_empty():
		current_player.n_mainboard.set_editable_board(false)
		#TRAS ESTA LINEA REALMENTE SE USA SIEMPRE EL GAME_PLAY_BRESK
		DataLoader.play_type = DataLoader.game_play_types.LETTER_TO_CHOOSE
		DataLoader.next_letter = cont_letter_i.text
		#AQUI GUARDO EL INDICE DEL ULTIMO CONT LETTER PULSADO
		index_letter_to_place = i_button
		
	
	pass # Replace with function body.
	
func first_choose_n_letters(n):
	cont_chosen_letters.show()
	cont_chosen_letters.focus_mode = Control.FOCUS_CLICK
	n_chosen_letters = 0
	var cont_i
	var btn_i
	for i in range(1,n+1):
		print("i = ",i)
		cont_i = cont_chosen_letters.get_node("cont_letter" + str(i))
		cont_i.show()
		var i_letter = get_letter(i)
		i_letter.connect("letter_entered", self.manage_placing_letters.bind(n))
		
func get_button(i):
	return cont_chosen_letters.get_node("cont_letter" + str(i) + "/btn_letter" + str(i))
func get_letter(i):
	return cont_chosen_letters.get_node("cont_letter" + str(i) + "/Letter" + str(i))
	
func save_letter(letter,n):
	
	cont_letters = cont_letters + 1
	print("LETTER SAVED: ", letter)
	if  DataLoader.play_type == DataLoader.game_play_types.LETTER_TO_CHOOSE and get_button(index_letter_to_place).is_connected("pressed",on_btn_letter_n_pressed):
		print("desconecto la letra ya usada")
		cont_chosen_letters.get_node("cont_letter" + str(index_letter_to_place)).modulate.a = 0.5
		get_button(index_letter_to_place).disconnect("pressed",on_btn_letter_n_pressed)
		
	if cont_letters == n:
		#current_player.n_mainboard.disconnect("b_letter_entered", self.save_letter)
		await get_tree().create_timer(0.23).timeout
		current_player.set_editable_subboards(false)
		print("Tablero desactivado")
		await get_tree().create_timer(2).timeout
		for i in range(1,4):
			cont_chosen_letters.get_node("cont_letter" + str(i)).modulate.a = 1
		show_next_step("NextPlayer")
		
		current_player.n_mainboard.disconnect("letter_placed", self.save_letter)
		
		$Button2.show()
		go_back_to_game_view()
	DataLoader.play_type = DataLoader.game_play_types.SKIP
	
func read_n_letters(n):
	cont_letters = 0
	var i = 0
	
	current_player.n_mainboard.connect("letter_placed", self.save_letter.bind(n))
	pass
	
func handle_letter_placed(letter,n):
	
	n_placed_letters += 1
	if n_placed_letters == n:
		print("Letra colocada: ",letter)
		current_player.n_mainboard.disconnect("letter_placed", self.handle_letter_placed)
		show_next_step("NextPlayer")
		#await get_tree().create_timer(4).timeout
		go_back_to_game_view()
		#$Button2.show()
	
	
	
func _on_alph_dice_thrown():
	var result = alph_dice.result
	
	cont_letters = 0
	print("Ha salido la letra ", result)
	last_letter = result
	DataLoader.next_letter = result
	DataLoader.play_type = DataLoader.game_play_types.BRESK
	current_player.n_scoreboard.note_new_letter(result, current_player.last_index)
	current_player.update_index()
	show_next_step("4")
	alph_dice.dice_is_thrown = false
	current_player.n_mainboard.connect("letter_placed", self.save_letter.bind(1))
	if current_player.is_bot:
		DataLoader.play_type = DataLoader.game_play_types.SKIP # I disable that the user can do anyth
		bot_place_letters(1,false)
	
	pass # Replace with function body.



func _on_button_pressed():
	
	fill_results_table()
	show_results_screen()
	pass # Replace with function body.


func _on_results_list_icon_clicked(index, at_position, mouse_button_index):
	print("se ha pulsado el icono: ", index)
	var index_player
	
	results_screen.hide()
	back_to_results.show()
	
	var cont
	if index % 4 == 0 and index >= 4: #Icon clicked
		index_player = index / 4 - 1
		current_player = data_players[index_player]
		print("el jugador que quiero mostrar es: ", current_player.get_name())
		show_desired_player()
	pass # Replace with function body.


func _on_back_to_results_pressed():
	show_results_screen()
	pass # Replace with function body.

func show_desired_player():
	var cont
	grid.columns = 1
	grid.show()
	for p in data_players:
		cont = p.get_parent().get_parent()
		cont.modulate.a = 1
		if p == current_player:
			print("el jugador que quiero mostrar es: ", current_player.get_name())
			print("cont= ",cont.get_name())
			cont.show()
			cont.size = grid.size
			current_player.position.x = 0
			current_player.scale = focus_scale
			current_player.set_editable_subboards(false)
		else:
			cont.hide()
			
