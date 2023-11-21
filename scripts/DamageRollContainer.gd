extends Control

@onready var background : NinePatchRect = $NinePatchRect
@onready var title_line : LineEdit = $VBoxContainer/HBoxContainer/TitleLineEdit
@onready var edit_button : TextureButton = $VBoxContainer/HBoxContainer/EditButton
@onready var delt_button : TextureButton = $VBoxContainer/HBoxContainer/DeleteButton
@onready var roll_button : TextureButton = $VBoxContainer/HBoxContainer3/RollButton
@onready var result_label : Label = $VBoxContainer/HBoxContainer2/ValueLabel
@onready var results_line : LineEdit = $VBoxContainer/HBoxContainer3/ResultsLine


@onready var die_count_input : SpinBox = $VBoxContainer/HBoxContainer2/DiceCountInput
@onready var dice_size_input : SpinBox = $VBoxContainer/HBoxContainer2/DiceSizeInput
@onready var mod_value_input : SpinBox = $VBoxContainer/HBoxContainer2/ModInput
@onready var die_count_label : Label = $VBoxContainer/HBoxContainer2/DiceCountLabel
@onready var dice_size_label : Label = $VBoxContainer/HBoxContainer2/DiceSizeLabel
@onready var mod_value_label : Label = $VBoxContainer/HBoxContainer2/ModLabel

var editing : bool = false
var rolling : bool = false
var roll_timer_max : float = 0.4
var roll_timer : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	roll_button.pressed.connect(on_roll)
	edit_button.pressed.connect(on_toggle_edit)
	update_edit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rolling:
		var count = die_count_input.value
		var dice = dice_size_input.value
		var tot = 0
		var results_text = "("
		for n in count:
			if n != 0: results_text += "+"
			var roll = _roll(dice)
			tot += roll
			results_text += str(roll)
		var mod = mod_value_input.value
		tot += mod
		results_text += ") + " + str(mod)
		result_label.text = str(tot)
		results_line.text = results_text
		
		roll_timer -= delta
		if roll_timer <= 0:
			rolling = false

func on_toggle_edit():
	editing = !editing
	update_edit()
	
func update_edit():
	if editing:
		die_count_input.value = int(die_count_label.text)
		dice_size_input.value = int(dice_size_label.text)
		mod_value_input.value = int(mod_value_label.text)
	else:
		die_count_label.text = str(die_count_input.value)
		dice_size_label.text = str(dice_size_input.value)
		mod_value_label.text = str(mod_value_input.value)
	die_count_input.visible = editing
	die_count_label.visible = !editing
	dice_size_input.visible = editing
	dice_size_label.visible = !editing
	mod_value_input.visible = editing
	mod_value_label.visible = !editing
	title_line.editable = editing

func on_roll():
	rolling = true
	roll_timer = roll_timer_max
	
func _roll(dice:int)->int:	
	if dice > 0:
		return (randi() % dice) + 1
	return 0
	
func simulate_roll_val():
	var count = die_count_input.value
	var dice = dice_size_input.value
	var tot = 0
	for n in count:
		tot += _roll(dice)
	tot += mod_value_input.value
	return tot

func write()->String:
	var line = title_line.text + "|"
	line += str(die_count_input.value) + "|"
	line += str(dice_size_input.value) + "|"
	line += str(mod_value_input.value) + "|"
	return line
	
func read(line:String):
	var tokens = line.split("|")
	title_line.text = tokens[0]
	die_count_input.value = int(tokens[1]) 
	dice_size_input.value = int(tokens[2])
	mod_value_input.value = int(tokens[3])
