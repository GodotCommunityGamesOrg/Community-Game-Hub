extends Node
var http: HTTPRequest
func download(link, path):
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_http_request_completed)
	http.set_download_file(path)
	var request = http.request_raw(link)
	if request != OK:
		push_error("Http request error")

func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Download Failed")
	remove_child(http)
	print("Ready")

func _ready():
	download("", "Logo.exe")
