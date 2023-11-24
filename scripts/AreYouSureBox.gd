extends Control

@onready var var_text_label : Label = $BoxContainer/VarTextLabel
@onready var yes_button : TextureButton = $BoxContainer/HBoxContainer/YesButton
@onready var no_button : TextureButton = $BoxContainer/HBoxContainer/NoButton

var yes_action : Callable 

# Called when the node enters the scene tree for the first time.
func _ready():
	yes_button.pressed.connect(on_yes)
	no_button.pressed.connect(on_no)
	self.visible = false

func on_yes():
	if yes_action:
		yes_action.call()
	on_no()

func on_no():
	yes_action = do_nothing
	self.visible = false
	
func do_nothing():
	pass

func bind_action(message:String, action:Callable):
	var_text_label.text = message + "?"
	yes_action = action
	self.visible = true
	
