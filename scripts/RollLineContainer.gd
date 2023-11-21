extends Control


@onready var die_count_input : SpinBox = $HBoxContainer/DiceCountInput
@onready var dice_size_input : SpinBox = $HBoxContainer/DiceSizeInput
@onready var d_label 		 : Label   = $HBoxContainer/dLabel
@onready var mod_value_input : SpinBox = $HBoxContainer/ModInput
@onready var die_count_label : Label   = $HBoxContainer/DiceCountLabel
@onready var dice_size_label : Label   = $HBoxContainer/DiceSizeLabel
@onready var mod_value_label : Label   = $HBoxContainer/ModLabel
@onready var result_label : Label      = $HBoxContainer/ValueLabel

@onready var detail_line : LineEdit = $DetailLineEdit

var is_attack_roll : bool = false
var advantage_state : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _roll(dice:int)->int:	
	if dice > 0:
		return (randi() % dice) + 1
	return 0
	
func do_roll(crit:bool):
	var count = die_count_input.value
	var dice = dice_size_input.value
	var tot = _roll(dice)
	var line = "(" + str(tot)
	var is_crit = 0
	if is_attack_roll:
		var other_roll = 0
		if advantage_state > 0:
			other_roll = _roll(dice)
			tot = maxi(tot, other_roll)
		if advantage_state < 0:
			other_roll = _roll(dice)
			tot = mini(tot, other_roll)
		if advantage_state != 0:
			line += "/" + str(other_roll)
		if tot == 20:
			is_crit = 1
		if tot == 1:
			is_crit = -1
	else:
		for n in count -1:
			var other_roll = _roll(dice)
			line += "+" + str(other_roll)
			tot +=other_roll
	line += ")"
	
	if crit:
		line += " + {"
		for n in count:
			line += "+" + str(dice)
			tot += dice
		line += "}"
	
	if mod_value_input.value > 0:
		line += " + " + str(mod_value_input.value)
	if mod_value_input.value < 0:
		line += " - " + str(mod_value_input.value)
	tot += mod_value_input.value
	result_label.text = str(tot)
	if is_crit != 0 or crit:
		result_label.self_modulate = Color.RED
	else:
		result_label.self_modulate = Color.WHITE
	
	if is_attack_roll:
		line += " = " + str(tot)
	else:
		var half = maxi(floori(tot/2),1)
		line += " = " + str(tot) + " [" + str(half) + "]"
	return [tot, line, is_crit]

func write_to_line()->String:
	var line = ""
	line += str(die_count_input.value) + ","
	line += str(dice_size_input.value) + ","
	line += str(mod_value_input.value) + ","
	return line
	
func read_from_line(line:String):
	var tokens = line.split(",")
	if line.begins_with("-1"):
		is_attack_roll = true
	die_count_input.value = int(tokens[0]) 
	dice_size_input.value = int(tokens[1])
	mod_value_input.value = int(tokens[2])
	result_label.text = "0"
	set_editing(false)
		
func set_editing(editing:bool):
	die_count_input.visible = editing
	dice_size_input.visible = editing
	mod_value_input.visible = editing
	die_count_label.visible = !editing
	dice_size_label.visible = !editing
	mod_value_label.visible = !editing
	die_count_label.text = str(die_count_input.value)
	dice_size_label.text = str(dice_size_input.value)
	mod_value_label.text = str(mod_value_input.value)
	is_attack_roll = die_count_input.value < 0
	if is_attack_roll:
		if not editing:
			die_count_label.visible = false
		d_label.text = ""
		dice_size_label.text = "d" + dice_size_label.text
	else:
		d_label.text = "d"
	detail_line.visible = editing
	detail_line.editable= editing

func set_advantage(adv_state : int):
	if not is_attack_roll:
		advantage_state = 0
		return
	advantage_state = adv_state
	if advantage_state > 0:
		d_label.text = "+Adv "
	if advantage_state == 0:
		d_label.text = ""
	if advantage_state < 0:
		d_label.text = "-Dis "
		
