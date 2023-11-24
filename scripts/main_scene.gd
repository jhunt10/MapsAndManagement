extends Node2D

@onready var window : Window = $Window

@onready var data_controller : Node = $DataController

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Main Ready")
	load_config()
	
	data_controller.load_map("/demo_map")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func load_config():
	print("---------------------Loading Configs---------------------")
	var config_path = "./config.json"
	if not FileAccess.file_exists(config_path):
		print("No config File Found.")
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var data_file = FileAccess.open(config_path, FileAccess.READ)
	while data_file.get_position() < data_file.get_length():
		var json_string = data_file.get_line()
		print(json_string)
		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()
		
		var nodes = get_tree().get_nodes_in_group("Configable")
		print("%s Configable Nodes Found" % [nodes.size()])
		for node in nodes:
#			# Check the node is an instanced scene so it can be instanced again during load.
#			if node.scene_file_path.is_empty():
#				print("persistent node '%s' is not an instanced scene, skipped" % node.name)
#				continue
			
		# Check the node has a save function.
			if !node.has_method("load_config"):
				print("persistent node '%s' is missing a load_config() function, skipped" % node.name)
				continue
			print("Loading config for: " + node.name)
			node.load_config(node_data)
	print("---------------------Config Loading Done---------------------")

