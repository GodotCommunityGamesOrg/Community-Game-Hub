extends Control
@export var grid: GridContainer
@export var container: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid.columns = floor(grid.size.x/300.0)
	for i in Global.games:
		var con = container.instantiate()
		con.game = i
		grid.add_child(con)
