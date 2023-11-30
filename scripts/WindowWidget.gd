extends GridContainer

@export var screen_index : int

@onready var window : Window = $"../../Window"
@onready var player_map = $"../../Window/PlayerMapController"
@onready var dm_map = $"../../DMMapController"

@onready var left_button : TextureButton = $LeftButton
@onready var right_button : TextureButton =  $RightButton
@onready var index_lable : Label = $IndexLabel

var screen_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_count = DisplayServer.get_screen_count()
	
	window.set_current_screen(screen_index)
	left_button.pressed.connect(_change_screen_index.bind( -1))
	right_button.pressed.connect(_change_screen_index.bind(1))
	index_lable.text = "Screen:\n" + str(screen_index + 1) + " / " + str(screen_count)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _change_screen_index(v:int):
#	if v > screen_index:
#		player_map.get_window().size = Vector2i(600,800)
#	else:
#		player_map.get_window().size = Vector2i(700,500)
		
	screen_index = screen_index + v
	if screen_index < 0:
		screen_index = 0
	if screen_index >= screen_count:
		screen_index = screen_count - 1
		
	window.set_current_screen(screen_index)
	
#	var screen_size = DisplayServer.window_get_size(screen_index)
	var screen_size = player_map.get_window().size
	var text = "Screen: " + str(screen_index + 1) + " / " + str(screen_count) 
#	text += "\n Size: " + str(screen_size)
#	text += "\n" + str(player_map.view_grid_dimensions * player_map.scaled_grid_tile_size)
	index_lable.text = text
	dm_map.set_screen_size(screen_size)
