extends Control

@onready var dice = $TextureRect/dice_lbl
@onready var dice_options = ["0", "1", "2", "3", "BRESK"]
@onready var alphabet = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "Ñ", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
]
@onready var dice_is_thrown = false
@onready var wait_time = 0.4
@onready var result
# Called when the node enters the scene tree for the first time.

signal dice_thrown_sgnl(result)

func set_dice_options(options):
	dice_options = options
	
func _ready():
	set_dice_options(dice_options)
	roll_dice()
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
	dice_thrown_sgnl.emit(result)
			
func _process(delta):
	
	pass

	
func _on_button_pressed():
	wait_time = 0.1
	var timer = Timer.new()
	timer.set_wait_time(2)  # Cambiar la opción cada segundo
	timer.set_one_shot(false)
	timer.connect("timeout", _choose_option )
	add_child(timer)
	timer.start()
	
func _choose_option():
	dice_is_thrown = true
