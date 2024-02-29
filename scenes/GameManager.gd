extends Control

#Members
@onready var current_player
@onready var grid = $GridContainer
@onready var viewport1 = $GridContainer/svpcontainer1/SubViewport1
@onready var lbl_turn = $lbl_game_turn
@onready var player4 = $GridContainer/svpcontainer4/SubViewport4/MainScenePlayer4
@onready var nplayers = DataLoader.nplayers
@onready var turn : int = 1

var PlayersBoards: Dictionary
var Scores: Array

func update_game():
    $Button.show()
    $Button2.hide()
    for i in range(1,nplayers+1):
        var p_container = get_node("GridContainer/svpcontainer" + str(i))
        if i != turn: #Difuminamos los tableros que no es su turno aun
            p_container.modulate.a = 0.5
        else:
            p_container.modulate.a = 1
        var player  = get_node("GridContainer/svpcontainer" + str(i) + "/SubViewport" + str(i) + "/MainScenePlayer" + str(i))
        player.set_player_name(DataLoader.all_players[i-1])
        PlayersBoards[DataLoader.all_players[i-1]] = player
        p_container.show()
        var scale : float = float(grid.columns) / float(nplayers)
        player.scale = Vector2(0.47, 0.47)
        
    print(PlayersBoards)
    lbl_turn.text = ("[center][color=WHITE][b]ES TURNO DE %s[/b][/color][/center]" % PlayersBoards.keys()[turn-1])
    
func _ready():
    grid.columns = 2
    nplayers=4
    for i in range(1,5):
        var p_container = get_node("GridContainer/svpcontainer" + str(i))
        p_container.hide()
    update_game()
    
    
    var zoom_size = grid.get_child_count()/2
    #$GridContainer/svpcontainer4/SubViewport4/MainScenePlayer4/Camera2D.zoom = Vector2(5,5)
    #await get_tree().create_timer(2).timeout 


func _on_button_pressed():
    $Button2.show()
    var root = get_tree().root
    grid.columns = 1
    for i in range(1,5):
        var cont = $GridContainer.get_node("svpcontainer" + str(i))
        print("es el turno de ",turn)
        if(i == turn):
            cont.size = grid.size
            current_player = cont.get_node("SubViewport" + str(i) + "/MainScenePlayer" + str(i))
            current_player.scale = Vector2(0.85,0.85)
        else:
            cont.hide()
    
    $Button.hide()
    
    
    print("Camara activada")
    pass # Replace with function body.


func _on_button_2_pressed():
    grid.columns = 2
    turn = turn % nplayers + 1
    update_game()
    
    pass # Replace with function body.
