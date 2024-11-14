extends PanelContainer
class_name GameCard
## GameCard: A UI component representing an individual game card in the game grid.
##           Displays basic game information such as title, image, and description,
##           and provides a button to either install or launch the game.

# --- Exported Properties ---
@export var texturerect: TextureRect  ## Display area for the game's image
@export var richtext: RichTextLabel  ## Label to show the game's description
@export var install: Button  ## Button to install or play the game
@export var progress_bar: ProgressBar  ## Shows download progress for the game

# --- Public Properties ---
var game: Global.Game  ## Current game data
var installed: bool = false:  ## Tracks if the game is installed
	set(value):
		installed = value
		if installed:
			install.text = "Play"
		else:
			install.text = "Install"

# --- Private Properties ---
var _http: HTTPRequest  # HTTPRequest node to handle downloads
var _pid  # Process ID for the running game, if launched

# --- Built-in Callbacks ---
func _ready() -> void:
	# Check if the game is already installed by looking for the .exe file
	if FileAccess.file_exists("user://games/" + game.title + ".exe"):
		installed = true

	# Ensure the directory for games exists
	DirAccess.make_dir_absolute("user://games/")

	# Set up the display with game details if available
	if game != null:
		texturerect.texture = game.image_data
		richtext.text = "[b][u]" + game.title + "[/u][/b] \n [code]" + game.description + "[/code]"
	else:
		push_error("Game data is missing.")

func _process(_delta: float) -> void:
	if _http != null:
		install.visible = false
		progress_bar.visible = true
		var bodySize = _http.get_body_size()
		var downloadedBytes = _http.get_downloaded_bytes()
		progress_bar.value = downloadedBytes * 100.0 / bodySize
	else:
		install.visible = true
		progress_bar.visible = false

# --- Custom Methods ---

## Starts the download of the game
## [param link]: The URL to download the game from
## [param path]: The path to save the downloaded file
func download(link: String, path: String) -> void:
	if FileAccess.file_exists(path):
		push_error("File already exists: " + path)
		return

	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_http_request_completed)
	_http.request_completed.connect(func(_q, _w, _e, _r):
		_http.queue_free()
	)
	_http.set_download_file(path)

	var request = _http.request_raw(link)
	if request != OK:
		push_error("HTTP request error for: " + link)

## Handles the HTTP request completion for downloading
## [param result]: The result of the download operation
## [param _response_code]: The HTTP response code
## [param _headers]: The response headers
## [param _body]: The body of the response (if any)
func _http_request_completed(result: int, _response_code: int, _headers: Array, _body) -> void:
	if result != OK:
		push_error("Download Failed.")
		return
	print("Download complete.")
	# Optional: Handle post-download tasks here, like unpacking or launching the game.

## Called when the install/play button is pressed
func _on_button_pressed() -> void:
	if installed:
		# Launch the game if it is already installed
		_pid = OS.create_process("user://games/" + game.title + ".exe", [])
		return

	# Start downloading the game if it is not installed
	if game != null:
		download(game.game_url, "user://games/" + game.title + ".exe")
	else:
		push_error("No game data available.")
