extends Control

@onready var dice = $TextureRect/dice_lbl
@onready var bresk = ["0", "1", "2", "3", "BRESK"]
@onready var alphabet = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "Ñ", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"
]
@onready var dice_options
@onready var dice_chosen
@onready var timer
@onready var dice_is_thrown = false
@onready var wait_time = 0.4
@onready var result
# Called when the node enters the scene tree for the first time.

signal bresk_dice_thrown(result)
signal alph_dice_thrown(result)

func set_bresk_dice():
	dice_options = bresk
	dice_chosen = "bresk"
func set_alphabet_dice():
	dice_options = alphabet
	dice_chosen = "alphabet"

func _ready():
	timer = Timer.new()
	dice_is_thrown = false
	pass

func roll_dice():
	var i = 0
	var option
	while !dice_is_thrown:
			option = dice_options[i]
			dice.text = "[center]%s[/center]" % option
			await get_tree().create_timer(wait_time).timeout
			i = (i + 1) % dice_options.size()
	result = option
	print("EL RESULTADO ES ", result)
	dice_is_thrown = false
	wait_time = 0.4
	if dice_chosen == "bresk":
		bresk_dice_thrown.emit(result)
	if dice_chosen == "alphabet":
		alph_dice_thrown.emit(result)
			
func _process(delta):
	
	pass

	
func _on_button_pressed():
	wait_time = 0.1
	
	timer.set_wait_time(2)  # Cambiar la opción cada segundo
	timer.set_one_shot(false)
	timer.connect("timeout", _choose_option )
	add_child(timer)
	timer.start()
	
func _choose_option():
	dice_is_thrown = true
	remove_child(timer) #Important
	timer.disconnect("timeout", _choose_option)
