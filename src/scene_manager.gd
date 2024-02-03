extends Node
class_name NSceneManager

# Here I will collect all the scenes in my game, and I add them with the Inspector Panel
@export var Scenes : Dictionary = {}
var current_scene = null


func _ready():
	var mainScene = ProjectSettings.get_setting("application/run/main_scene")
	current_scene = Scenes.find_key(mainScene)
	#var root = get_tree().root
	#current_scene = root.get_child(root.get_child_count() - 1)
	
	
# Description: Return the number of scenes in the collection
func GetSceneCount() -> int:
	return Scenes.size()
	 
# Description: Returns the alias of the current scene
func GetCurrentSceneAlias() -> String:
	return current_scene
	
# Description: Add a new scene to the scene collection
# Parameter sceneAlias: The alias used for finding the scene in the collection
# Parameter scenePath: The full path to the scene file in the file system
func AddScene(sceneAlias : String, scenePath : String) -> void:
	Scenes[sceneAlias] = scenePath

# Description: Remove an existing scene from the scene collection
# Parameter sceneAlias: The scene alias of the scene to remove from the collection
func RemoveScene(sceneAlias : String) -> void:
	Scenes.erase(sceneAlias)

# Description: Switch to the requested scene based on its alias
# Parameter sceneAlias: The scene alias of the scene to switch to
func SwitchScene(sceneAlias : String) -> void:
	get_tree().change_scene_to_file(Scenes[sceneAlias])

# Description: Restart the current scene
func RestartScene() -> void:
	get_tree().reload_current_scene()
	 
# Description: Quit the game
func QuitGame() -> void:
	get_tree().quit()
	
	
func switch_scene(res_path):
	call_deferred("_deferred_switch_scene", res_path)

func _deferred_switch_scene(res_path):
	current_scene.free()
	var s = load(res_path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
