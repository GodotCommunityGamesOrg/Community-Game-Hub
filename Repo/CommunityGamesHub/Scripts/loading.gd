extends Control

# HTTPRequest node instance
@export_file("*.tscn") var next_scene: String
@export var anim: AnimationPlayer
@export var timer: Timer
@export var texture_r: TextureRect
var http: HTTPRequest
var urls = []
var games: Array[Global.Game] = []
var current_url_index = 0  # To track the current game URL being processed
var current_game_index = -1  # To track the current game being processed
var done: bool
# Function to start downloading the GameHub XML
func download_gamehub(link: String) -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_gamehub_request_completed)
	var request = http.request(link)
	if request != OK:
		push_error("HTTP request error: %d" % request)

# Callback when the GameHub XML request is completed
func _on_gamehub_request_completed(result: int, _response_code: int, _headers: Array, _body: PackedByteArray) -> void:
	http.queue_free()
	if result != OK:
		push_error("Download failed: %d" % result)
		return

	# Parse the GameHub XML and collect URLs
	var parser = XMLParser.new()
	parser.open_buffer(_body)
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "url":
			parser.read()  # Move to the text node inside <url>
			if parser.get_node_type() == XMLParser.NODE_TEXT:
				urls.append(parser.get_node_data())
	
	# Once URLs are collected, start downloading each game XML
	if urls.size() > 0:
		download_game_xml(urls[current_url_index])  # Start with the first URL

# Function to start downloading each game's XML
func download_game_xml(link: String) -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_game_request_completed)
	var request = http.request(link)
	if request != OK:
		push_error("HTTP request error: %d" % request)

# Callback when a game XML request is completed
func _on_game_request_completed(result: int, _response_code: int, _headers: Array, _body: PackedByteArray) -> void:
	http.queue_free()
	if result != OK:
		push_error("Download failed: %d" % result)
		return

	# Parse the Game XML content and add to games dictionary
	var parser = XMLParser.new()
	parser.open_buffer(_body)
	var current_game: Global.Game = Global.Game.new()
	
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			
			# Parse each expected field based on its node name
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

	# Store the parsed game data and set up for image download
	current_game_index = games.size()  # Track current game index
	games.append(current_game)  # Store parsed game data
	download_game_image(current_game.img)  # Download image for the game

# Function to download the game image
func download_game_image(img_url: String) -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_image_request_completed)
	var request = http.request(img_url)
	if request != OK:
		push_error("Image HTTP request error: %d" % request)

# Callback when the image download request is completed
func _on_image_request_completed(result: int, _response_code: int, _headers: Array, _body: PackedByteArray) -> void:
	http.queue_free()
	if result != OK:
		push_error("Image download failed: %d" % result)
		return

	# Save the image data to the game dictionary
	var im = Image.new()
	im.load_jpg_from_buffer(_body)
	var image:ImageTexture = ImageTexture.create_from_image(im)  # Load image from downloaded byte data
	games[current_game_index].image_data = image  # Store image in the game dictionary

	# Proceed to the next game XML download
	current_url_index += 1
	if current_url_index < urls.size():
		download_game_xml(urls[current_url_index])
	else:
		check_done()
func end():
	Global.games = games
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Global.change_scene(next_scene)
# Called when the node enters the scene tree
func _ready() -> void:
	download_gamehub("https://raw.githubusercontent.com/GodotCommunityGamesOrg/Community-Game-Hub/refs/heads/main/Games/Log.xml")
	timer.timeout.connect(check_done)

func check_done():
		if done:
			anim.play("end")
		else:
			done = true
