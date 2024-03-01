extends TextureRect

@onready var dice = $TextureRect/dice_lbl
@onready var dice_options = ["1", "2", "3", "BRESK"]
# Called when the node enters the scene tree for the first time.
func _ready():
	while true:
		for c in dice_options:
			if c == "BRESK":
				dice.text = c
			else:
				dice.text = "[center]%s[/center]" % c
			await get_tree().create_timer(0.25).timeout 
			pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
