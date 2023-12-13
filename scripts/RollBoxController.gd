extends "res://scripts/DragWindow.gd"

@onready var save_input : LineEdit = $BoxContainer/ControllerBoxContainer/SaveLoadContainer/SaveNameInput
@onready var save_button : TextureButton = $BoxContainer/ControllerBoxContainer/SaveLoadContainer/SaveButton
@onready var save_flag : Node = $BoxContainer/ControllerBoxContainer/SaveLoadContainer/SaveButton/SaveFlag

@onready var roll_count_input : SpinBox = $BoxContainer/ControllerBoxContainer/MinAvgMaxContainer/SpinBox
@onready var roll_button : TextureButton = $BoxContainer/ControllerBoxContainer/MinAvgMaxContainer/RollButton2
@onready var rolls_container : Control = $BoxContainer/ControllerBoxContainer/RollSetsContainer

@onready var results_line : LineEdit = $BoxContainer/ControllerBoxContainer/ResultsLineEdit
@onready var add_button : TextureButton = $BoxContainer/ControllerBoxContainer/MinAvgMaxContainer/AddButton

@onready var _drag_element : Node = $BoxContainer/ControllerBoxContainer/HBoxContainer/Label

var roll_set_container = preload("res://elements/roll_set_container.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.drag_element = _drag_element
	roll_button.pressed.connect(on_roll)
	save_button.pressed.connect(on_save)
	add_button.pressed.connect(on_add)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
						
				
			
			
	
func on_roll():
	for child in rolls_container.get_children():
		run_rolls(child)
	pass
	
func on_add():
	create_new_roll_set("New Roll|1,8,5")
	
func run_rolls(attack_roller):
	var total : int = 0
	var count : int = 0
	var min : int = 999
	var max : int = 0
	var to_do : int = roll_count_input.value
	for child in rolls_container.get_children():
		child.simulate_roll_val(to_do)
#	for n in to_do:
#		var roll = attack_roller.simulate_roll_val()
#		total += roll
#		count += 1
#		if roll < min:
#			min = roll
#		if roll > max:
#			max = roll
#
#	var avg : float = float(total) / float(count)
#	avg = roundf(avg * 10) / 10
#	attack_roller.results_line.text = str(min) + " / " + str(avg) + " / " + str(max)
	

func on_save():
	var save_file_path = save_input.text
	print("Saving Roll Sets: " + save_file_path)
	var file_access = FileAccess.open(save_file_path, FileAccess.WRITE)
	
	for child in rolls_container.get_children():
		if child.has_method("write_to_line"):
			var line = child.write_to_line()
			print("Saving: " + line)
			file_access.store_line(line)
	save_flag.show_self()
	
func load_roll_sets(full_path):
	print("Loading Roll Sets: " + full_path)
	if not FileAccess.file_exists(full_path):
		print("Roll Sets Data Not Found: " + full_path)
		return # Error! We don't have a save to load.
	save_input.text = full_path
	for child in rolls_container.get_children():
		child.queue_free()
	self.visible = true
	var file_access = FileAccess.open(full_path, FileAccess.READ)
	while file_access.get_position() < file_access.get_length():
		var line_string = file_access.get_line()
		create_new_roll_set(line_string)
		
func create_new_roll_set(line_string):
	var new_roll = roll_set_container.instantiate()
	rolls_container.add_child(new_roll)
	new_roll.read_from_line(line_string)
	
