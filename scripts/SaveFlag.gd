extends TextureRect

@onready var timer : Timer = $Timer
@export var show_time : float 

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(on_time_end)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_time_end():
	self.visible = false

func show_self():
	self.visible = true
	timer.start(show_time)
