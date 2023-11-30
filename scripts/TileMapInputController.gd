extends Control
@onready var map_controller = $"../DMMapController"


@onready var grid_tile_size_input : SpinBox = $BoxContainer/TileSizes/GridSizeInput
@onready var image_tile_size_input : SpinBox = $BoxContainer/TileSizes/MapSizeInput
@onready var xoffset_input : SpinBox = $BoxContainer/Offsets/XOffsetInput
@onready var yoffset_input : SpinBox = $BoxContainer/Offsets/YOffsetInput

@onready var view_width_input : SpinBox = $BoxContainer/ViewGridDim/GridViewWidthInput
@onready var view_hight_input : SpinBox = $BoxContainer/ViewGridDim/GridViewHightInput
@onready var view_x_input : SpinBox = $BoxContainer/ViewGridPos/GridViewXInput
@onready var view_y_input : SpinBox = $BoxContainer/ViewGridPos/GridViewYInput


# Called when the node enters the scene tree for the first time.
func _ready():
	if map_controller:
		map_controller.map_data_initialized.connect(initalize_inputs)
		map_controller.map_inputs_changed.connect(initalize_inputs)
		map_controller.map_moved.connect(map_moved)
		
		grid_tile_size_input.value_changed.connect(map_controller.set_grid_tile_size)
		image_tile_size_input.value_changed.connect(map_controller.set_image_tile_size)
		xoffset_input.value_changed.connect(map_controller.set_image_offset_x)
		yoffset_input.value_changed.connect(map_controller.set_image_offset_y)
		
		view_width_input.value_changed.connect(map_controller.set_grid_view_width)
		view_hight_input.value_changed.connect(map_controller.set_grid_view_hight)
		view_x_input.value_changed.connect(map_controller.set_grid_view_pos_x)
		view_y_input.value_changed.connect(map_controller.set_grid_view_pos_y)
		
		initalize_inputs()
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func initalize_inputs():
	grid_tile_size_input.set_value_no_signal(map_controller.grid_tile_size)
	image_tile_size_input.set_value_no_signal(map_controller.image_tile_size)
	xoffset_input.set_value_no_signal(map_controller.image_offset.x)
	yoffset_input.set_value_no_signal(map_controller.image_offset.y)
	var width = float(float(floori(map_controller.view_grid_dimensions.x * 100)) / float(100))
	view_width_input.set_value_no_signal(width)
	var hight = float(float(floori(map_controller.view_grid_dimensions.y * 100)) / float(100))
	view_hight_input.set_value_no_signal(hight)
	view_x_input.set_value_no_signal(map_controller.view_grid_position.x)
	view_y_input.set_value_no_signal(map_controller.view_grid_position.y)
	
func map_moved():
	view_x_input.set_value_no_signal(map_controller.view_grid_position.x)
	view_y_input.set_value_no_signal(map_controller.view_grid_position.y)

func _input(ev):
	if ev is InputEventKey and ev.is_pressed():
		
		var move_vec = Vector2(0, 0)
		if Input.is_key_pressed(KEY_LEFT):
			move_vec.x -= 1
		if Input.is_key_pressed(KEY_RIGHT):
			move_vec.x += 1
		if Input.is_key_pressed(KEY_UP):
			clear_focus()
			move_vec.y -= 1
		if Input.is_key_pressed(KEY_DOWN):
			clear_focus()
			move_vec.y += 1
			
		if Input.is_key_pressed(KEY_CTRL):
			move_vec *= 5
		if Input.is_key_pressed(KEY_SHIFT):
			move_vec *= 10
		map_controller.move_view_preview(map_controller.view_grid_position + move_vec)
	
		if ev.keycode == KEY_ENTER:
			clear_focus()
			
func clear_focus():
		if grid_tile_size_input.get_line_edit().has_focus():
			grid_tile_size_input.get_line_edit().release_focus()
		if image_tile_size_input.get_line_edit().has_focus():
			image_tile_size_input.get_line_edit().release_focus()
		if xoffset_input.get_line_edit().has_focus():
			xoffset_input.get_line_edit().release_focus()
		if yoffset_input.get_line_edit().has_focus():
			yoffset_input.get_line_edit().release_focus()
			
		if view_width_input.get_line_edit().has_focus():
			view_width_input.get_line_edit().release_focus()
		if view_hight_input.get_line_edit().has_focus():
			view_hight_input.get_line_edit().release_focus()
		if view_x_input.get_line_edit().has_focus():
			view_x_input.get_line_edit().release_focus()
		if view_y_input.get_line_edit().has_focus():
			view_y_input.get_line_edit().release_focus()
			
		get_viewport().set_input_as_handled()

