extends Control


@onready var background : NinePatchRect = $NinePatchRect
@onready var title_line : LineEdit = $VBoxContainer/TitleContainer/TitleLineEdit
@onready var edit_button : TextureButton = $VBoxContainer/TitleContainer/EditButton
@onready var delt_button : TextureButton = $VBoxContainer/TitleContainer/DeleteButton
@onready var roll_button : TextureButton = $VBoxContainer/ResultsContainer/RollButton
@onready var results_line : LineEdit = $VBoxContainer/ResultsContainer/ResultsLine


@onready var advantage_label : Label = $VBoxContainer/HitContainer/AdvantageLabel
@onready var hit_result_label : Label = $VBoxContainer/HitContainer/ValueLabel
@onready var hit_mod_input : SpinBox = $VBoxContainer/HitContainer/ModInput
@onready var hit_mod_label : Label = $VBoxContainer/HitContainer/ModLabel

@onready var die_count_input : SpinBox = $VBoxContainer/DamageContainer/DiceCountInput
@onready var dice_size_input : SpinBox = $VBoxContainer/DamageContainer/DiceSizeInput
@onready var mod_value_input : SpinBox = $VBoxContainer/DamageContainer/ModInput
@onready var die_count_label : Label = $VBoxContainer/DamageContainer/DiceCountLabel
@onready var dice_size_label : Label = $VBoxContainer/DamageContainer/DiceSizeLabel
@onready var mod_value_label : Label = $VBoxContainer/DamageContainer/ModLabel
@onready var damage_result_label : Label = $VBoxContainer/DamageContainer/ValueLabel

var editing : bool = false
var rolling : bool = false
var roll_timer_max : float = 0.4
var roll_timer : float = 0

var advantage : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	roll_button.pressed.connect(on_roll)
	edit_button.pressed.connect(on_toggle_edit)
	update_edit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rolling:
		do_roll()
		roll_timer -= delta
		if roll_timer <= 0:
			rolling = false

func on_toggle_edit():
	editing = !editing
	update_edit()
	
func update_edit():
	if editing:
		hit_mod_input.value = int(hit_mod_label.text)
		die_count_input.value = int(die_count_label.text)
		dice_size_input.value = int(dice_size_label.text)
		mod_value_input.value = int(mod_value_label.text)
	else:
		hit_mod_label.text = str(hit_mod_input.value)
		die_count_label.text = str(die_count_input.value)
		dice_size_label.text = str(dice_size_input.value)
		mod_value_label.text = str(mod_value_input.value)
	hit_mod_input.visible = editing
	hit_mod_label.visible = !editing
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
	
func _input(ev):
	if ev is InputEventKey:
		if ev.keycode == KEY_SHIFT:
			var event : InputEventKey = ev as InputEventKey
			if event.is_pressed():
				advantage = 1
				advantage_label.text = '+Adv'
			if event.is_released():
				advantage = 0
				advantage_label.text = ""
		if ev.keycode == KEY_CTRL:
			var event : InputEventKey = ev as InputEventKey
			if event.is_pressed():
				advantage = -1
				advantage_label.text = '-Dis'
			if event.is_released():
				advantage = 0
				advantage_label.text = ""
	
func do_roll():
	var hit_mod = hit_mod_input.value
	var count = die_count_input.value
	var dice = dice_size_input.value
	var tot = 0
	var hit_roll = _roll(20)
	var other_roll = _roll(20)
	var hit_tot = hit_roll + hit_mod
	if advantage > 0:
		hit_tot = maxi(hit_roll, other_roll) + hit_mod
	if advantage < 0:
		hit_tot = mini(hit_roll, other_roll) + hit_mod
	hit_result_label.text = str(hit_tot)
	var results_text = ""
	if advantage == 0:
		results_text += "(" + str(hit_roll) + ") + " + str(hit_mod)
	else:
		results_text += "(" + str(hit_roll) + "/" + str(other_roll) + ") + " + str(hit_mod)
	results_text += " = " + str(hit_tot) + "   |   ("
	for n in count:
		if n != 0: results_text += "+"
		var roll = _roll(dice)
		tot += roll
		results_text += str(roll)
	var mod = mod_value_input.value
	tot += mod
	results_text += ") + " + str(mod)
	results_text += " = " + str(tot)
	damage_result_label.text = str(tot)
	results_line.text = results_text
	
func simulate_roll_val():
	var count = die_count_input.value
	var dice = dice_size_input.value
	var tot = 0
	for n in count:
		tot += _roll(dice)
	tot += mod_value_input.value
	return tot

func write_to_line()->String:
	var line = title_line.text + "|"
	line += str(die_count_input.value) + "|"
	line += str(dice_size_input.value) + "|"
	line += str(mod_value_input.value) + "|"
	return line
	
func read_from_line(line:String):
	var tokens = line.split("|")
	title_line.text = tokens[0]
	die_count_input.value = int(tokens[1]) 
	dice_size_input.value = int(tokens[2])
	mod_value_input.value = int(tokens[3])
