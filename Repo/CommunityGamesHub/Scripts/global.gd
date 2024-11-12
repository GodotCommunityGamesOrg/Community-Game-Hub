extends Node
var games: Array[Game] = []
@onready var root = get_tree().root
@onready var current_scene = root.get_child(root.get_child_count()-1)
func change_scene(path: String):
	current_scene.queue_free()
	var new_scene = ResourceLoader.load(path)
	current_scene = new_scene.instantiate()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

class Game:
	var title: String
	var img: String
	var image_data: Texture
	var description: String
	var game_url: String
	var version: String
	
