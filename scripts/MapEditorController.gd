extends Control

const DmMapController = preload("res://scripts/DMMapController.gd")

@onready var dm_map_controller : DmMapController = $"../DMMapController"
@onready var display_tile_size_input : SpinBox = $Box/TabContainer/View/DisplayGridInput
@onready var shadow_alpha_input : SpinBox = $Box/TabContainer/View/ShadowAlphaInput

@onready var tab_controller : TabContainer = $Box/TabContainer
@onready var apply_button : TextureButton = $Box/ApplyButton
@onready var fullscreen_button : TextureButton = $Box/BoxContainer/FullScreen
@onready var clearimage_button : TextureButton = $Box/BoxContainer/ClearImage


var dm_shadow_map : Node

var mouse_was_down : bool = false
var mouse_down_pos : Vector2 = Vector2.ZERO
var mouse_last_tile : Vector2i = Vector2i.ZERO
var mouse_down_tile : Vector2i = Vector2i.ZERO


var dragging : bool = false
var drag_start_pos : Vector2i = Vector2.ZERO
var drag_rect : Rect2i = Rect2i(0,0,0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	dm_map_controller.map_data_initialized.connect(initalize_inputs)
	dm_map_controller.map_inputs_changed.connect(initalize_inputs)
	display_tile_size_input.value_changed.connect(dm_map_controller.set_display_tile_size)
	shadow_alpha_input.value_changed.connect(on_shadow_alpha_change)
	apply_button.button_down.connect(on_apply)
	clearimage_button.pressed.connect(on_clear_image)
	fullscreen_button.button_down.connect(on_full_screen)
	pass # Replace with function body.

func on_shadow_alpha_change(val):
	var new_val = float(val) / 100
	print("Set Alpha: " + str(dm_map_controller.shadow_map.self_modulate.a) + " : " + str(new_val))
	dm_map_controller.shadow_map.self_modulate.a = new_val
	dm_map_controller.shadow_map.force_update()
	
func on_clear_image():
	dm_map_controller.clear_quick_image()
	dm_map_controller.path_map.clear_movement_range()
	
func on_apply():
	dm_map_controller.path_map.clear_movement_range()
	dm_map_controller.shadow_map.apply_state()
	dm_map_controller.player_map_controller.sync_view()

func on_full_screen():
	dm_map_controller.player_map_controller.zoom_to_full_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func initalize_inputs():
	display_tile_size_input.set_value_no_signal(dm_map_controller.dm_display_tile_size)

func _input(event):
	if event is InputEventMouse:
		var mouse_tile_pos = dm_map_controller.tile_grid.get_local_mouse_position()
		var mouse_over_tile = dm_map_controller.tile_grid.local_to_map(mouse_tile_pos)
		if not dm_map_controller.on_map(mouse_over_tile):
			return
		if dragging:
			drag_rect = Rect2i(
				mini(mouse_over_tile.x, mouse_down_tile.x), 
				mini(mouse_over_tile.y, mouse_down_tile.y), 
				abs(mouse_over_tile.x - mouse_down_tile.x) + 1, 
				abs(mouse_over_tile.y - mouse_down_tile.y) + 1)
		# Mouse Button Event
		if event is InputEventMouseButton:
				
						
			# Left Click
			var mouse_event = event as InputEventMouseButton
			if event.button_index == 2:
				dm_map_controller.move_view_preview(mouse_over_tile)
					
			# Right click
			if mouse_event.button_index == 1:
	#			print("Mouse Click/Unclick at: ", mouse_over_tile)
				if mouse_event.pressed:
					if not mouse_was_down:
						dragging = true
						drag_start_pos = mouse_over_tile
						mouse_down_pos = event.position
						mouse_down_tile = mouse_over_tile
						mouse_last_tile = mouse_over_tile
						dm_map_controller.shadow_map.select_cell(mouse_down_tile)
						mouse_was_down = true
				# Released
				else:
					dm_map_controller.shadow_map.clear_selected()
					var tab : Control = tab_controller.get_current_tab_control()
					if tab.has_method("apply_line"):
						tab.apply_line(drag_start_pos, mouse_over_tile)
					if tab.has_method("apply_rec"):
						tab.apply_rec(drag_rect)
					dragging = false
					
				mouse_was_down = event.pressed
		# Mouse Moved
		if event is InputEventMouseMotion:
			if dragging:
				if mouse_last_tile.x != mouse_over_tile.x or mouse_last_tile.y != mouse_over_tile.y:
					dm_map_controller.shadow_map.select_range(drag_rect)
			mouse_last_tile = mouse_over_tile
