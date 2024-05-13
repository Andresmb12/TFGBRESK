extends Node

var vowels = ["A", "E", "I", "O", "U"]
var consonants = [ "B", "C", "D", "F", "G","H", "J", "K", "L", "M", 
"N", "P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z" ]
var space = "#"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func is_vowel(letter):
	OS.get_cache_dir()
	return letter in vowels
	
func is_consonant(letter):
	return letter in consonants
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
