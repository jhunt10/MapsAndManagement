extends Control

const ITEM_INDEX = 0
const ITEM_ROLLS = 1
const ITEM_WEIGHT = 2
const ITEM_NAME = 3
const ITEM_URL = 4
const ITEM_BUTTONS = 5

@onready var exit_button : TextureButton = $BoxContainer/TopBar/ExitButton
@onready var tree : Tree = $BoxContainer/TreeContainer/Tree

@onready var save_button : TextureButton = $BoxContainer/BoxContainer/SaveButton
@onready var save_path_input : LineEdit = $BoxContainer/BoxContainer/SavePathInput
@onready var save_flag : Node = $BoxContainer/BoxContainer/SaveButton/SaveFlag

@onready var input_container : BoxContainer = $BoxContainer/InputWapper/InputsContainer
@onready var name_input : LineEdit = $BoxContainer/InputWapper/InputsContainer/NameInput
@onready var url_input : LineEdit = $BoxContainer/InputWapper/InputsContainer/UrlInput
@onready var weight_input : SpinBox = $BoxContainer/InputWapper/InputsContainer/WeightInput
@onready var edit_confirm_button : TextureButton = $BoxContainer/InputWapper/InputsContainer/EditConfirmButton
@onready var edit_confirm_label : Label = $BoxContainer/InputWapper/InputsContainer/EditConfirmButton/Label
@onready var edit_delete_button : TextureButton = $BoxContainer/InputWapper/InputsContainer/EditDeleteButton

@onready var total_value_label : Label = $BoxContainer/RollBox/TotalBox/Control/TotalValue
@onready var roll_value_label : Label = $BoxContainer/RollBox/RollBox/Control/RollValue
@onready var roll_button : TextureButton = $BoxContainer/RollBox/RollButton
@onready var roll_result_line : LineEdit = $BoxContainer/RollBox/LineEdit

var edit_texture : Texture2D
var add_texture : Texture2D
var open_texture : Texture2D
var loot_items : Array = []

var editing_item : TreeItem
var full_edit : bool = false
const roll_time_length : float = 0.4
const roll_time_step : float = 0.04
var rolling : bool = false
var roll_time_total : float = 0
var roll_time_sub_total : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	exit_button.pressed.connect(on_exit)
	tree.item_selected.connect(on_item_select)
	edit_texture = load("res://icons/edit_button.png")
	add_texture = load("res://icons/add_button.png")
	open_texture = load("res://icons/open_button.png")
	tree.button_clicked.connect(on_button_clicked)
	edit_confirm_button.pressed.connect(on_edit_confirm)
	edit_delete_button.pressed.connect(on_edit_delete)
	save_button.pressed.connect(on_save)
	roll_button.pressed.connect(on_roll)
	input_container.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rolling:
		roll_time_total += delta
		roll_time_sub_total += delta
		if roll_time_sub_total > roll_time_step:
			roll_time_sub_total = 0
			var max = int(total_value_label.text)
			var roll = 0
			if max > 0:
				roll = randi() % max + 1
			roll_value_label.text = str(roll)
			resolve_roll(roll)
		if roll_time_total > roll_time_length:
			roll_for_real()
			rolling = false
			roll_time_total = 0
			roll_time_sub_total = 0
			roll_button.disabled = false
	pass
	
func on_exit():
	self.visible = false
	
func on_roll():
	rolling = true
	roll_button.disabled = true

func resolve_roll(roll:int):
	var parent = tree.get_selected()
	if not parent:
		return
	var tot = 0
	for child in parent.get_children():
		var weight = int(child.get_text(ITEM_WEIGHT))
		tot += weight
		if tot >= roll:
			roll_result_line.text = child.get_text(ITEM_NAME)
			return
			
func roll_for_real():
	var parent = tree.get_selected()
	if not parent:
		return
	var roll = _roll_for_child(parent)
	var rolled_item = _get_child_by_roll(parent, roll)
	roll_value_label.text = str(roll)
	if rolled_item and rolled_item.get_children().size() > 0:
		rolled_item = _rec_resolve_roll(rolled_item)
	if rolled_item:
		roll_result_line.text = rolled_item.get_text(ITEM_NAME)
	else:
		roll_result_line.text = "--- NO RESULT ---"

func _rec_resolve_roll(item:TreeItem):
	var roll = _roll_for_child(item)
	var rolled_item = _get_child_by_roll(item, roll)
	if rolled_item:
		roll_value_label.text = roll_value_label.text + "/" + str(roll)
		if rolled_item.get_children().size() > 0:
			rolled_item = _rec_resolve_roll(rolled_item)
	return rolled_item

func _roll_for_child(item:TreeItem)->int:
	var max = 20#_get_children_weight(item)
	var roll = 0
	if max > 0:
		roll = randi() % max + 1
	return roll

func _get_children_weight(item:TreeItem)->int:
	var total = 0
	for child in item.get_children():
		var text = child.get_text(ITEM_WEIGHT)
		var weight = int(text)
		total += weight
	return total

func _get_child_by_roll(item:TreeItem, roll:int)->TreeItem:
	for child in item.get_children():
		var vals = child.get_text(ITEM_ROLLS).split("-")
		var min = int(vals[0])
		var max = min
		if vals.size() > 1:
			max = int(vals[1])
		if min <= roll and  roll <= max:
			return child
	return null
	
	
func cal_roll_range(parent:TreeItem):
	var total_weight = _get_children_weight(parent)
	var child_count = parent.get_child_count()
	
	
	var dice : float = 20
	var dices = [4,6,8,10,12,20]
	for d in dices:
		if d > child_count and total_weight % d == 0:
			total_value_label.text = str(d)
			dice = float(d)
			break
	var tot : float = 1
	var done : float =  0
	var last_min : int = 1
	var cur_val : int = 0
	for child in parent.get_children():
		if child.get_child_count() > 0:
			cal_roll_range(child)
		var weight = child.get_text(ITEM_WEIGHT)
		var perc = float(weight)/float(total_weight)
		print("cal child: "+str(child) + " | " + str(perc) + " | " + str(cur_val) )
#		while (cur_val / dice < done + perc):# and not (cur_val+1) / dice == done + perc):
#			print("Cur:%s Dice:%s Done:%s Perc:%s" % [cur_val, dice, done, perc])
#			cur_val += 1
#		done += perc
		cur_val = floori(cur_val + (dice * perc))
		if last_min == cur_val:
			child.set_text(ITEM_ROLLS, str(cur_val))
		else:
			child.set_text(ITEM_ROLLS, str(last_min) + "-" + str(cur_val))
		last_min = cur_val + 1
		
		
	
func on_name_input(val:String):
	pass

func on_url_input(val:String):
	pass

func on_weight_input(val:int):
	pass
	
func on_edit_confirm():
	if editing_item:
		editing_item.set_text(ITEM_NAME, name_input.text)
		editing_item.set_text(ITEM_URL, url_input.text)
		editing_item.set_text(ITEM_WEIGHT, str(weight_input.value))
	input_container.visible = false
	cal_roll_range(tree.get_root())
	
func on_edit_delete():
	if editing_item:
		var p = editing_item.get_parent()
		p.remove_child(editing_item)
		editing_item = null
	input_container.visible = false
	
func on_item_select():
	var selected : TreeItem = tree.get_selected()
	var selected_column = tree.get_selected_column()
	print("Item Selected Col: " + str(selected_column))
	
	var total = 0
	var count = 0
	for child in selected.get_children():
		var text = child.get_text(ITEM_WEIGHT)
		var weight = int(text)
		total += weight
		count += 1
	var dice = [4,6,8,10,12,20]
	for d in dice:
		if d > count and total % d == 0:
			total_value_label.text = str(d)
			return

func on_button_clicked (item:TreeItem,column:int,id:int,mouse_button_index:int):
	editing_item = item
	var index = editing_item.get_text(ITEM_INDEX)
	var name = editing_item.get_text(ITEM_NAME)
	var weight = editing_item.get_text(ITEM_WEIGHT)
	var url = editing_item.get_text(ITEM_URL)
	print(id)
	var is_root = item == tree.get_root()
		
	if id == 0 and not is_root:
		OS.shell_open(url)
	elif id == 1 and not is_root:
		name_input.text = name
		url_input.text = url
		weight_input.set_value_no_signal(int(weight))
		editing_item.select(0)
		edit_confirm_label.text = "Save"
		input_container.visible = true
	elif id == 0 and is_root:
		var root = tree.get_root()
		if full_edit:
			full_edit = false
			tree.select_mode = tree.SELECT_ROW
			root.set_text(ITEM_BUTTONS, "")
			root.set_button(ITEM_BUTTONS, 0, edit_texture)
		else:
			full_edit = true
			tree.select_mode = tree.SELECT_SINGLE
			root.set_text(ITEM_BUTTONS, "Save")
			root.set_button(ITEM_BUTTONS, 0, open_texture)
			cal_roll_range(tree.get_root())
	elif id == 2 or is_root:
		var new_item = tree.create_item(editing_item)
		var new_index = index + "." + str(item.get_child_count())
		var new_name = name + " - "
		if editing_item == tree.get_root():
			new_index = str(item.get_child_count()-1)
			new_name = ""
		new_item.set_text(ITEM_INDEX, new_index)
		new_item.set_text(ITEM_NAME, new_name)
		weight_input.set_value_no_signal(1)
		name_input.text = name + " - "
		new_item.add_button(ITEM_BUTTONS, open_texture)
		new_item.add_button(ITEM_BUTTONS, edit_texture)
		new_item.add_button(ITEM_BUTTONS, add_texture)
		edit_confirm_label.text = "Save"
		new_item.select(0)
		editing_item = new_item
		input_container.visible = true
		
	
func on_save():
	var save_file_path = save_path_input.text
	print("Saving Loot Table: " + save_file_path)
	var file_access = FileAccess.open(save_file_path, FileAccess.WRITE)
	
	var treeRoot : TreeItem = tree.get_root()
	for treeRootChild in list_items():
		var index = treeRootChild.get_text(ITEM_INDEX)
		var weight = treeRootChild.get_text(ITEM_WEIGHT)
		var rolls = treeRootChild.get_text(ITEM_ROLLS)
		var name = treeRootChild.get_text(ITEM_NAME)
		var url = treeRootChild.get_text(ITEM_URL)
		var line = index + "|" + weight + "|" + weight + "|" + name + "|" + url
		print("Saving: " + line)
		file_access.store_line(line)
	save_flag.show_self()
	
func load_loot_table(full_path):
	print("Loading Loot Table: " + full_path)
	if not FileAccess.file_exists(full_path):
		print("Loot Table Data Not Found: " + full_path)
		return # Error! We don't have a save to load.
	save_path_input.text = full_path
	self.visible = true
	tree.clear()
#	tree.hide_root = true
	var root : TreeItem = tree.create_item()
	root.select(0)
	root.set_text(ITEM_INDEX, "Index")
	root.set_text(ITEM_WEIGHT, "Weight")
	root.set_text(ITEM_NAME, "Name")
	root.set_text(ITEM_URL, "Url")
	root.add_button(ITEM_BUTTONS, edit_texture)
	root.add_button(ITEM_BUTTONS, add_texture)
	
#	var new_index = 1
	var parent_stack = [root]
	var index_stack = ["i"]
	var last_index = "x"
	var last_item = root
	var file_access = FileAccess.open(full_path, FileAccess.READ)
	while file_access.get_position() < file_access.get_length():
		var line_string = file_access.get_line()
		var tokens = line_string.split("|")
		var line_index : String = "i" + tokens[0]
		
		if line_index.begins_with(last_index):
			parent_stack.push_front(last_item)
			index_stack.push_front(last_index)
		
		while index_stack.size() > 1 and not line_index.begins_with(index_stack.front()):
			parent_stack[0].collapsed = true
			index_stack.pop_front()
			parent_stack.pop_front()
			
		var item : TreeItem = tree.create_item(parent_stack[0])
		
		for i in tokens.size():
			item.set_text(i, tokens[i])
		item.set_editable(ITEM_WEIGHT, true)
		item.add_button(ITEM_BUTTONS, open_texture)
		item.add_button(ITEM_BUTTONS, edit_texture)
		item.add_button(ITEM_BUTTONS, add_texture)
#		new_index = new_index + 1
		item.set_icon_max_width(ITEM_URL, 0)
		last_index = line_index
		last_item = item
	
	total_value_label.text = str(20)
	cal_roll_range(root)
	input_container.visible = false

func list_items():
	var out_list = []
	var root : TreeItem = tree.get_root()
	_rec_list_items(root, out_list)
	return out_list
	
	
func _rec_list_items(item:TreeItem, list:Array):
	for child in item.get_children():
		list.append(child)
		var gran_kids = child.get_children()
		if gran_kids.size() > 0:
			_rec_list_items(child, list)
	
	
	
	
