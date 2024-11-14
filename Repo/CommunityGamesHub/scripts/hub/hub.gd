extends Control
class_name Hub
## Hub: A UI container that manages the main navigation buttons and panels.
##       It displays different sections of the interface (e.g., game details, settings) 
##       and handles user input to switch between these sections.
# --- Exported Properties ---
@export var grid: FlowContainer  ## Container for displaying the game's list
@export var game_card: PackedScene  ## Scene to instantiate for each game
@export var hub: VBoxContainer  ## Container for menu buttons
@export var panel: Control  ## Container for displaying the panels associated with menu buttons

# --- Built-in Callbacks ---
func _ready() -> void:
	# Populate the grid with game instances from Global.games
	for game in Global.games:
		var con = game_card.instantiate()
		con.game = game
		grid.add_child(con)
	
	# Connect each button in hub to _menu_pressed with its index as an argument
	for i in hub.get_children().size():
		hub.get_child(i).pressed.connect(_menu_pressed.bind(i))

# --- Custom Methods ---
## Handles menu button presses to show the selected panel
## [param extra_arg_0]: The index of the pressed button
func _menu_pressed(extra_arg_0: int) -> void:
	# Hide all panels and reset button states
	for i in hub.get_children().size():
		panel.get_child(i).visible = false
		hub.get_child(i).button_pressed = false
	
	# Show the panel and activate the button for the selected index
	panel.get_child(extra_arg_0).visible = true
	hub.get_child(extra_arg_0).button_pressed = true
