extends Control


@onready var background : NinePatchRect = $NinePatchRect
@onready var title_line : LineEdit = $VBoxContainer/TitleContainer/TitleLineEdit
@onready var edit_button : TextureButton = $VBoxContainer/TitleContainer/EditButton
@onready var add_button : TextureButton = $VBoxContainer/TitleContainer/AddButton
@onready var delt_button : TextureButton = $VBoxContainer/TitleContainer/DeleteButton
@onready var roll_button : TextureButton = $VBoxContainer/ResultsContainer/RollButton
@onready var results_line : LineEdit = $VBoxContainer/ResultsContainer/ResultsLine

@onready var roll_line_container : BoxContainer = $VBoxContainer/RollLinesContainer

var roll_line_prefab = preload("res://elements/roll_line_container.tscn")

var editing : bool = false
var rolling : bool = false
var roll_timer_max : float = 0.4
var roll_timer : float = 0

var advantage : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	roll_button.pressed.connect(on_roll)
	edit_button.pressed.connect(on_toggle_edit)
	add_button.pressed.connect(on_add)
	delt_button.pressed.connect(on_delete)
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

func on_add():
	create_new_roll_line("-1,8,5")
	background.calc_scale()
	self.custom_minimum_size = background.size
	
func update_edit():
	for child in roll_line_container.get_children():
		if child.has_method("set_editing"):
			child.set_editing(editing)
	title_line.editable = editing

func on_roll():
	rolling = true
	roll_timer = roll_timer_max
	
func _roll(dice:int)->int:	
	if dice > 0:
		return (randi() % dice) + 1
	return 0

func on_delete():
	self.queue_free()

func _input(ev):
	if ev is InputEventKey:
		if ev.keycode == KEY_SHIFT:
			var event : InputEventKey = ev as InputEventKey
			if event.is_pressed():
				advantage = 1
			if event.is_released():
				advantage = 0
		if ev.keycode == KEY_CTRL:
			var event : InputEventKey = ev as InputEventKey
			if event.is_pressed():
				advantage = -1
			if event.is_released():
				advantage = 0
		for child in roll_line_container.get_children():
			if child.has_method("set_advantage"):
				child.set_advantage(advantage)
	
func do_roll():
	var results_text = ""
	var first = true
	var crit = false
	for child in roll_line_container.get_children():
		if child.has_method("do_roll"):
			if first:
				first = false
				if child.is_attack_roll:
					var res = child.do_roll(crit)
					results_text += res[1]
					if res[2] > 0:
						crit = true
					continue
			else:
				results_text += " | "
			var res = child.do_roll(crit)
			results_text += res[1]
	results_line.text = results_text
	
func simulate_roll_val(count):
	for roll_line in roll_line_container.get_children():
		var tot : int = 0
		var min : int = 999
		var max : int = 0
		for n in count:
			if roll_line.has_method("do_roll"):
				var res = roll_line.do_roll(false)[0]
				if res > max:
					max = res
				if res < min:
					min = res
				tot += res
		var avg = float(tot) / float(count)
		avg = float(roundi(avg * 10)) / 10
		var line = str(min) + " / " + str(avg) + " / " + str(max)
		roll_line.detail_line.text = line
		roll_line.detail_line.visible = true
		roll_line.result_label.text = str(avg)

func write_to_line()->String:
	var line = title_line.text
	var sub_lines = ""
	for child in roll_line_container.get_children():
		if child.has_method("write_to_line"):
			sub_lines += "|" + child.write_to_line()
			
	line += str(sub_lines)
	return line
	
func read_from_line(line:String):
	var tokens = line.split("|")
	title_line.text = tokens[0]
	for n in tokens.size() - 1:
		create_new_roll_line(tokens[n+1])
	background.calc_scale()
	self.custom_minimum_size = background.size
	self.size = custom_minimum_size
	print("Box Size: " + str(self.size))

func create_new_roll_line(line_text):
	var new_roll_set = roll_line_prefab.instantiate()
	roll_line_container.add_child(new_roll_set)
	if line_text:
		new_roll_set.read_from_line(line_text)
	background.calc_scale()
	self.custom_minimum_size = background.size
	self.size = custom_minimum_size
	print("Box Size: " + str(self.size))
	
