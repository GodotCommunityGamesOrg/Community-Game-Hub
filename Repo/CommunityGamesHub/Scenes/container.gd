extends PanelContainer

@export var texturerect: TextureRect
@export var richtext: RichTextLabel
@export var install: Button
@export var progress_bar: ProgressBar
var game: Global.Game
var http: HTTPRequest
var installed: bool = false:
	set(value):
		installed = value
		if installed == true:
			install.text = "Play"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists("user://games/" + game.title + ".exe"):
		installed = true
		
	DirAccess.make_dir_absolute("user://games/")

	if game != null:
		texturerect.texture = game.image_data
		richtext.text = "[b][u]" + game.title + "[/u][/b] \n [code]" + game.description + "[/code]"
	else:
		push_error("Game data is missing.")

func download(link: String, path: String) -> void:
	if FileAccess.file_exists(path):  # Check if the file already exists.
		push_error("File already exists: " + path)
		return

	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_http_request_completed)
	http.request_completed.connect(func(_q, _w, _e, _r):
		http.queue_free()
	)
	http.set_download_file(path)

	var request = http.request_raw(link)
	if request != OK:
		push_error("HTTP request error for: " + link)

func _http_request_completed(result: int, _response_code: int, _headers: Array, _body) -> void:
	if result != OK:
		push_error("Download Failed.")
		return
	print("Download complete.")
	# You could handle post-download tasks here, like unpacking or launching the game.

func _on_button_pressed() -> void:
	if installed:
		var pid = OS.create_process("user://games/" + game.title + ".exe", [])
		return
	if game != null:
		download(game.game_url, "user://games/" + game.title + ".exe")
	else:
		push_error("No game data available.")
func _process(_delta: float) -> void:
	if http != null:
		install.visible = false
		progress_bar.visible = true
		var bodySize = http.get_body_size()
		var downloadedBytes = http.get_downloaded_bytes()
		progress_bar.value = downloadedBytes*100.0/bodySize
	else:
		install.visible = true
		progress_bar.visible = false
