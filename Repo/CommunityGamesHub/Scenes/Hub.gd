extends Control
@export var grid: GridContainer
@export var container: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in Global.games:
		var con = container.instantiate()
		con.game = i
		grid.add_child(con)
