extends PanelContainer
@export var texturerect: TextureRect
@export var richtext: RichTextLabel
var game: Global.Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if game != null:
		texturerect.texture = game.image_data
		richtext.text = "[b][u]"+game.title+"[/u][/b] \n [code]"+game.description+"[/code]"
