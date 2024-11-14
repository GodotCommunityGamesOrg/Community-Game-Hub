extends Node
class_name global
## This class manages game scenes and allows switching between them. 
## It also defines a `Game` class to represent game data.

# --- Exported Properties ---
# (None for this example)

# --- Public Properties ---
var games: Array[Game] = [] ## List of game objects containing data for each game.

# --- Private Properties ---
@onready var root = get_tree().root ## Reference to the root node of the scene tree.
@onready var current_scene = root.get_child(root.get_child_count() - 1) ## Currently active scene.

# --- Enum ---
# (None for this example)

# --- Signals ---
# (None for this example)

# --- Built-in Callbacks ---
# No built-in callbacks such as `_ready()` are used in this example.

# --- Custom Methods ---
## Changes the current scene to a new scene specified by `path`.
## [param path]: The file path of the scene to load.
func change_scene(path: String):
	# Free the current scene to clear it from memory.
	current_scene.queue_free()
	
	# Load the new scene resource from the specified path.
	var new_scene = ResourceLoader.load(path)
	
	# Instantiate the new scene and assign it as the current scene.
	current_scene = new_scene.instantiate()
	
	# Add the new scene to the root node of the scene tree.
	get_tree().get_root().add_child(current_scene)
	
	# Set the newly added scene as the active (current) scene.
	get_tree().set_current_scene(current_scene)

# --- Inner Class ---
## Represents a game with basic information.
class Game:
	# --- Properties ---
	## The title of the game.
	var title: String
	
	## The http path to the game's image.
	var img: String
	
	## The texture data for the game's image.
	var image_data: Texture
	
	## A brief description of the game.
	var description: String
	
	## A URL linking to the game.
	var game_url: String
	
	## The current version of the game.
	var version: String
