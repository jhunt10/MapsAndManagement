extends Control

var source_path = "./data"

@onready var tree : Tree = $BoxContainer/Tree
@onready var dm_map = $"../DMMapController"
@onready var loot_table_controller : Node = $"../LootTableController"
@onready var dice_sim_controller : Node = $"../RollBoxController"

@onready var save_flag : Node = $BoxContainer/SaveLoad/SaveButton/SaveFlag
@onready var save_button : TextureButton = $BoxContainer/SaveLoad/SaveButton
@onready var reload_button : TextureButton = $BoxContainer/SaveLoad/LoadButton
@onready var save_name_input : LineEdit = $BoxContainer/SaveLoad/SaveNameInput

@export var file_icon : Texture2D
@export var loot_icon : Texture2D
@export var dice_icon : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	build_tree()
	tree.item_selected.connect(on_item_selected)
	save_button.pressed.connect(save_map_settings)
	reload_button.pressed.connect(reload_map_settings)
	save_name_input.text = "\\demo_map.map"
	
func save_map_settings():
	var main_node = $".."
	var map_name = save_name_input.text.trim_prefix("\\").trim_prefix("/").trim_suffix(".map")
	save_map(map_name)
	print("Map Settings Saved")
	save_flag.show_self()
	
func reload_map_settings():
	build_tree()
#	var main_node = $".."
#	if main_node.save_controller:
#		main_node.save_controller.load_map(save_name_input.text)
#		print("Map Settings Loaded")
#	else:
#		print("TileMapInput: No Save Controller")



func on_item_selected():
	loot_table_controller.visible = false
	dice_sim_controller.visible = false
	var selected : TreeItem = tree.get_selected()
	var rel_file_path = rebuild_path(selected)
	var full_file_path = selected.get_tooltip_text(0)
	if rel_file_path.ends_with(".map"):
		save_name_input.text = rel_file_path
		load_map(rel_file_path.trim_suffix(".map"))
	if rel_file_path.ends_with(".png") or rel_file_path.ends_with(".jpg"):
		dm_map.load_quick_image(full_file_path)
	if rel_file_path.ends_with(".loot"):
		loot_table_controller.load_loot_table(full_file_path)
	if rel_file_path.ends_with(".rolls"):
		dice_sim_controller.load_roll_sets(full_file_path)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func scan_files(path):
	print("Scanning: "+path)
	var out_list = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var sub_path = dir.get_next()
		while sub_path != "":
			var full_path = path + "\\" + sub_path
			if dir.current_is_dir():
				if is_map_dir(full_path):
					out_list.append({'name':sub_path, 'full_path':full_path, 'is_map': true})
				else:
					var children = scan_files(full_path)
					out_list.append({'name':sub_path, 'full_path':full_path, 'children': children, 'is_map': false})
			else:
				out_list.append({'name':sub_path, 'full_path':full_path, 'is_map': false})
			sub_path = dir.get_next()
	return out_list

func is_map_dir(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path + "\\" + file_name
			if file_name == "save.json":
				return true
			file_name = dir.get_next()
	return false
	

func build_tree():
	tree.clear()
	var root = tree.create_item()
	tree.hide_root = true
	var list = scan_files(source_path)
	var current_partent = root
	_rec_build_tree(list, current_partent)
	

func _rec_build_tree(list, parent):
	for l in list:
		var item : TreeItem =  tree.create_item(parent)
		var text = l['name']
		if l['is_map']:
			text = text + ".map"
		item.set_text(0, text)
		item.set_tooltip_text(0, l['full_path'])
		if l.has('children'):
			_rec_build_tree(l['children'], item)
			item.collapsed = true
		else:
			var icon = get_icon(l)
			item.set_icon(0, icon)
			item.set_icon_max_width(0, 40)
		
func rebuild_path(item:TreeItem):
	var out_str = item.get_text(0)
	var parent = item.get_parent()
	while parent:
		out_str = parent.get_text(0) + "\\" + out_str
		parent = parent.get_parent()
	return out_str

func get_icon(file_data):
#	{'name':sub_path, 'full_path':full_path, 'children': children, 'is_map': false}
	if file_data.has('children'):
		return file_icon
		
	var file_path : String = file_data['full_path']
	if file_data['is_map']:
		file_path = file_data['full_path'] + "\\map.png"
	if file_path.ends_with(".loot"):
		return loot_icon
	if file_path.ends_with(".rolls"):
		return dice_icon
	if not file_path.ends_with(".png") and not file_path.ends_with(".jpg"):
		return file_icon
	
	var image = Image.new()
	image.load(file_path)
	return ImageTexture.create_from_image(image)
		
		
	
func save_map(save_path):
	print("Saving Map: " + save_path)
	var full_save_path = source_path + "\\" + save_path + "\\save.json"
	print("Full Save Path: " + full_save_path)
	var save_game = FileAccess.open( full_save_path, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Saveable")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
#		if node.scene_file_path.is_empty():
#			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
#			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_game.store_line(json_string)

func load_map(save_path):
	var save_data_path = source_path  + save_path + "\\save.json"
	print("Loading: " + save_data_path)
	if not FileAccess.file_exists(save_data_path):
		print("Save Data Not Found: " + save_data_path)
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open(save_data_path, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		var loading_node = get_node(node_data["node_path"])
		if loading_node and loading_node.has_method("load_data"):
			loading_node.load_data(source_path + save_path + "\\", node_data)
		else:
			print("No load_data method found on " + node_data["node_path"])

func load_config(data:Dictionary):
	if data.has("data_path"):
		source_path = data["data_path"]
		build_tree()
	print("Save Controller Confg Loaded")
