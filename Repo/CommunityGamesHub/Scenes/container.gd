extends PanelContainer
var game: Global.Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if game != null:
		$VBoxContainer/TextureRect.texture = game.image_data
		$VBoxContainer/RichTextLabel.text = "[b][u]"+game.title+"[/u][/b] \n [code]"+game.description+"[/code]"
