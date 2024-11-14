extends Control
class_name Loader
## Loader: A class responsible for downloading game data, including the game files and images, from a provided link.
##         It manages the download progress, handles HTTP requests, and launches the game once it's installed.
# --- Exported Properties ---
@export_file("*.tscn") var next_scene: String ## The path to the next scene to switch to.
@export var anim: AnimationPlayer ## AnimationPlayer to handle animations.
@export var timer: Timer ## Timer for scheduling actions.
@export var texture_r: TextureRect ## TextureRect to display downloaded images.

# --- Public Properties ---
var games: Array[Global.Game] = [] ## Stores game data objects parsed from XML files.
var current_url_index = 0 ## Tracks the index of the current game URL being processed.
var current_game_index = -1 ## Tracks the index of the current game being processed.
var done: bool ## Indicates if all downloads and processing are complete.

# --- Private Properties ---
var _http: HTTPRequest # HTTPRequest instance for handling HTTP requests.
var _urls = [] # Stores URLs collected from the GameHub XML file.

# --- Signals ---
# (None in this example)

# --- Built-in Callbacks ---
func _ready() -> void:
	download_gamehub("https://raw.githubusercontent.com/GodotCommunityGamesOrg/Community-Game-Hub/refs/heads/main/Games/Log.xml")
	timer.timeout.connect(check_done)

# --- Custom Methods ---
## Function to start downloading the GameHub XML
## [param link]: The URL to the GameHub XML file.
func download_gamehub(link: String) -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_gamehub_request_completed)
	var request = _http.request(link)
	if request != OK:
		push_error("HTTP request error: %d" % request)

# Callback when the GameHub XML request is completed
# Parses the GameHub XML to collect URLs of each game's XML file.
# [param result]: The result code of the HTTP request.
# [param _response_code]: The HTTP response code.
# [param _headers]: The headers of the HTTP response.
# [param _body]: The body of the HTTP response as PackedByteArray.
func _on_gamehub_request_completed(result: int, _response_code: int, _headers: Array, _body: PackedByteArray) -> void:
	_http.queue_free()
	if result != OK:
		push_error("Download failed: %d" % result)
		return

	var parser = XMLParser.new()
	parser.open_buffer(_body)
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "url":
			parser.read()
			if parser.get_node_type() == XMLParser.NODE_TEXT:
				_urls.append(parser.get_node_data())
	
	if _urls.size() > 0:
		download_game_xml(_urls[current_url_index]) # Start with the first URL

## Function to start downloading each game's XML
## [param link]: The URL to the game's XML file.
func download_game_xml(link: String) -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_game_request_completed)
	var request = _http.request(link)
	if request != OK:
		push_error("HTTP request error: %d" % request)

# Callback when a game XML request is completed
# Parses each game's XML content and creates a Game object.
# [param result]: The result code of the HTTP request.
# [param _response_code]: The HTTP response code.
# [param _headers]: The headers of the HTTP response.
# [param _body]: The body of the HTTP response as PackedByteArray.
func _on_game_request_completed(result: int, _response_code: int, _headers: Array, _body: PackedByteArray) -> void:
	_http.queue_free()
	if result != OK:
		push_error("Download failed: %d" % result)
		return

	var parser = XMLParser.new()
	parser.open_buffer(_body)
	var current_game: Global.Game = Global.Game.new()
	
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			if node_name == "name":
				parser.read()
				if parser.get_node_type() == XMLParser.NODE_TEXT:
					current_game.title = parser.get_node_data()
			elif node_name == "img":
				parser.read()
				if parser.get_node_type() == XMLParser.NODE_TEXT:
					current_game.img = parser.get_node_data()
			elif node_name == "description":
				parser.read()
				if parser.get_node_type() == XMLParser.NODE_TEXT:
					current_game.description = parser.get_node_data()
			elif node_name == "gameurl":
				parser.read()
				if parser.get_node_type() == XMLParser.NODE_TEXT:
					current_game.game_url = parser.get_node_data()
			elif node_name == "version":
				parser.read()
				if parser.get_node_type() == XMLParser.NODE_TEXT:
					current_game.version = parser.get_node_data()

	current_game_index = games.size()
	games.append(current_game)
	download_game_image(current_game.img) # Download image for the game

## Function to download the game image
## [param img_url]: The URL to the game's image file.
func download_game_image(img_url: String) -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_image_request_completed)
	var request = _http.request(img_url)
	if request != OK:
		push_error("Image HTTP request error: %d" % request)

# Callback when the image download request is completed
# Loads the image from the downloaded byte data and stores it in the game object.
# [param result]: The result code of the HTTP request.
# [param _response_code]: The HTTP response code.
# [param _headers]: The headers of the HTTP response.
# [param _body]: The body of the HTTP response as PackedByteArray.
func _on_image_request_completed(result: int, _response_code: int, _headers: Array, _body: PackedByteArray) -> void:
	_http.queue_free()
	if result != OK:
		push_error("Image download failed: %d" % result)
		return

	var im = Image.new()
	im.load_webp_from_buffer(_body)
	var image: ImageTexture = ImageTexture.create_from_image(im)
	games[current_game_index].image_data = image

	current_url_index += 1
	if current_url_index < _urls.size():
		download_game_xml(_urls[current_url_index])
	else:
		check_done()

## Ends the current process and loads the next scene
func end():
	Global.games = games
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Global.change_scene(next_scene)

## Checks if all downloads are completed and triggers the end animation if done.
func check_done():
	if done:
		anim.play("end")
	else:
		done = true
