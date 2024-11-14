extends Control
@export var grid: FlowContainer
@export var container: PackedScene
@export var hub: VBoxContainer
@export var panel: Control
func _ready() -> void:
	for i in Global.games:
		var con = container.instantiate()
		con.game = i
		grid.add_child(con)
	for i in hub.get_children().size():
		hub.get_child(i).pressed.connect(_menu_pressed.bind(i))
		


func _menu_pressed(extra_arg_0: int) -> void:
	for i: int in hub.get_children().size():
		panel.get_child(i).visible = false
		hub.get_child(i).button_pressed = false
		
	panel.get_child(extra_arg_0).visible = true
	hub.get_child(extra_arg_0).button_pressed = true
