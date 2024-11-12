extends Control

# HTTPRequest node instance
var http: HTTPRequest

# Download function
func download(link: String) -> void:
	http = HTTPRequest.new()
	add_child(http)
	# Connect the request_completed signal
	http.request_completed.connect(_http_request_completed)
	
	# Make the HTTP request
	var request = http.request(link)
	if request != OK:
		push_error("HTTP request error: %d" % request)

# Callback for when the HTTP request is completed
func _http_request_completed(result: int, _response_code: int, _headers: Array, _body: PackedByteArray) -> void:
	# Check if the request was successful
	if result != OK:
		push_error("Download failed: %d" % result)
		return

	# Initialize XMLParser to parse the downloaded content
	var parser = XMLParser.new()
	parser.open_buffer(_body)
	
	# Store all URLs in an array
	var urls = []
	
	# Parse the XML content
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			
			# Check if the node is a 'url' element and capture its content
			if node_name == "url":
				parser.read()  # Move to the text node inside <url>
				if parser.get_node_type() == XMLParser.NODE_TEXT:
					urls.append(parser.get_node_data())
	
	# Print all collected URLs
	print("Collected URLs:", urls)

	# Clean up the HTTPRequest node after use
	http.queue_free()

# Called when the node enters the scene tree
func _ready() -> void:
	download("https://raw.githubusercontent.com/GodotCommunityGamesOrg/Community-Game-Hub/refs/heads/main/Games/Log.xml")
