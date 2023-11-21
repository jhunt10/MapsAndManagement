extends Node2D

signal data_changed
signal map_moved

@onready var dm_map_controller = $"../../DMMapController"

@onready var window : Window = $"../"
@onready var map_frame : Node2D = $"FullFrame/MapFrame"
@onready var map_image : Sprite2D = $"FullFrame/MapFrame/MapImage"
@onready var tile_grid : TileMap = $"FullFrame/TileMap"
@onready var cutout_frame : Node2D = $"FullFrame/CutoutFrame"
@onready var cutout_image : Sprite2D = $"FullFrame/CutoutFrame/CutoutImage"
@onready var shadow_grid : TileMap = $FullFrame/ShadowCopyMap
@onready var full_frame : Control = $FullFrame

#@export var image_tile_size : float 
#@export var grid_tile_size : float 
#@export var image_offset : Vector2
#@export var map_gid_dimentions : Vector2i 
#@export var view_grid_dimensions : Vector2
#@export var view_grid_position: Vector2

var view_grid_position : Vector2 = Vector2.ZERO
var view_grid_dimensions : Vector2 = Vector2.ZERO

var scaled_grid_tile_size : float = 20
#var rescale : bool = false

const SPEED_MOD : float = 2

var moving : bool = false
var move_speed : float = 1
var target_view_position : Vector2 = Vector2.ZERO

var scaleing : bool = false
var scale_speed : float = 1
var target_grid_tile_size : float = 0
var target_grid_dimensions : Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	dm_map_controller.map_data_initialized.connect(init_map)
#	dm_map_controller.map_rescaled.connect(scale_map)
	pass # Replace with function body.

func read_map_data():
	if not dm_map_controller:
		print("No DmMapController on PlayerMap")
		return
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if scaleing:
		var scale_step = scale_speed * delta
		print("Last Scale Dim: " + str(view_grid_dimensions))
		view_grid_dimensions = view_grid_dimensions.move_toward(target_grid_dimensions, scale_step)
		print("Last Scale Dim: " + str(view_grid_dimensions))
		if (abs(view_grid_dimensions.x - target_grid_dimensions.x) < scale_step 
		and abs(view_grid_dimensions.y - target_grid_dimensions.y) < scale_step):
			print("Scale Done: " + str(view_grid_dimensions) + " : " + str(target_grid_dimensions))
			view_grid_dimensions = target_grid_dimensions
			scaleing = false
		scale_map()
	if moving:
		var move_step = move_speed * delta
		view_grid_position = view_grid_position.move_toward(target_view_position, move_step)
		if (abs(view_grid_position.x - target_view_position.x) < move_step 
		and abs(view_grid_position.y - target_view_position.y) < move_step):
			print("Move Done: " + str(view_grid_position) + " : " + str(target_view_position))
			view_grid_position = target_view_position
			moving = false
		update_view_position()
	
	pass
	
func init_map():
	map_image.texture = dm_map_controller.map_image.texture
	cutout_image.texture = dm_map_controller.cutout_image.texture
	
	view_grid_dimensions = dm_map_controller.view_grid_dimensions
	var grid_scale = window.size.y  / (dm_map_controller.grid_tile_size * dm_map_controller.view_grid_dimensions.y)
	scaled_grid_tile_size = grid_scale * dm_map_controller.grid_tile_size
	target_grid_tile_size = scaled_grid_tile_size
	
	scale_map()
	_build_grids()
	sync_view(true)
	
func _build_grids():
	print("Player Map Build Grid")
	tile_grid.clear()
	for x in dm_map_controller.grid_dimensions.x:
		for y in dm_map_controller.grid_dimensions.y:
			tile_grid.set_cell(0,Vector2i(x,y),0, Vector2i(0,0))
#			shadow_grid.set_cell(0,Vector2i(x,y),0, Vector2i(0,0))
	
func sync_view(force:bool = false):
	print("Player Map Sync View: Force=" + str(force))
	
	if (dm_map_controller.view_grid_dimensions.x != view_grid_dimensions.x or 
		dm_map_controller.view_grid_dimensions.y != view_grid_dimensions.y):
		scaleing = true
		# Calculate screen tile size
		target_grid_dimensions = dm_map_controller.view_grid_dimensions
		scale_speed = view_grid_dimensions.distance_to(target_grid_dimensions) * SPEED_MOD
		if force:
			view_grid_dimensions = dm_map_controller.view_grid_dimensions
			scale_map()
			scaleing = false
	
	var screen_offet = dm_map_controller.calc_view_center_offset(view_grid_dimensions, scaled_grid_tile_size)
	var scaled_pos = scaled_grid_tile_size * dm_map_controller.view_grid_position

	target_view_position = dm_map_controller.view_grid_position
	move_speed = view_grid_position.distance_to(target_view_position) * SPEED_MOD
	moving = true
	if force:
		view_grid_position = target_view_position
		update_view_position()
		moving = false
		
func zoom_to_full_map():
	# wider than tall
	if dm_map_controller.grid_dimensions.x > dm_map_controller.grid_dimensions.y:
		var ratio = float(window.size.x) / float(window.size.y)
		target_grid_dimensions = Vector2(dm_map_controller.grid_dimensions.x, dm_map_controller.grid_dimensions.x / ratio)
		var center_pos = floor(target_grid_dimensions / 2)
		var y_offset = (target_grid_dimensions.y - dm_map_controller.grid_dimensions.y) / 2
		target_view_position = center_pos - Vector2(0, y_offset)
	else:
		target_grid_dimensions = dm_map_controller.grid_dimensions
		target_view_position = floor(target_grid_dimensions / 2)
	
	scale_speed = view_grid_dimensions.distance_to(target_grid_dimensions) * SPEED_MOD
	move_speed = view_grid_position.distance_to(target_view_position) * SPEED_MOD
	scaleing = true
	moving = true
		
#func move_to_center_on(vec:Vector2, force:bool = false):
##	dm_map_controller.v = vec
##	var screen_center_offset = floor(dm_map_controller.view_grid_dimensions * 0.5) * scaled_grid_tile_size
##	var scaled_pos = scaled_grid_tile_size * vec
##	target_pos = grid_center - offset
##	moving = true
##	MOVE_SPEED = position.distance_to(target_pos)
##	if force:
##		self.position = target_pos
##		moving = false
##	map_moved.emit()
	
func update_view_position():
	var screen_offet = dm_map_controller.calc_view_center_offset(view_grid_dimensions, scaled_grid_tile_size)
	var scaled_pos = scaled_grid_tile_size * view_grid_position
	self.position = screen_offet - scaled_pos
		
func scale_map():
	print("Player Map Rescaled")
	var screen_ratio = float(window.size.x) / float(window.size.y)
	var image_to_tile_scale = dm_map_controller.grid_tile_size / dm_map_controller.image_tile_size
	map_frame.scale = Vector2(image_to_tile_scale, image_to_tile_scale)
	map_image.position = dm_map_controller.image_offset
	
	scaled_grid_tile_size = float(window.size.y)  / float(view_grid_dimensions.y)
	var frame_scale = scaled_grid_tile_size / dm_map_controller.grid_tile_size
	full_frame.scale = Vector2(frame_scale,frame_scale)
	
	update_view_position()
	_sync_images()
	_sync_grids()
	
func _sync_images():
	cutout_frame.scale = 	map_frame.scale
	cutout_frame.position = map_frame.position
	cutout_image.scale = 	map_image.scale
	cutout_image.position = map_image.position
	
func _sync_grids():
	shadow_grid.scale = 	tile_grid.scale
	shadow_grid.position = tile_grid.position
	shadow_grid.scale = 	tile_grid.scale
	shadow_grid.position = tile_grid.position

#func scale_map_image():
#	print("Map Controller Rescale Map")
#	var screen_ratio = float(window.size.x) / float(window.size.y)
#	var image_size = map_image.texture.get_size()
#	var map_tile_dimentions = Vector2i( 
#		ceili(image_size.x / image_tile_size),
#		ceili(image_size.y / image_tile_size)) 
#
#	var grid_scale = window.size.y  / (grid_tile_size * view_grid_dimensions.y)
#	tile_grid.scale = Vector2(grid_scale, grid_scale)
#	shadow_map.scale = tile_grid.scale
#	view_grid_dimensions.x = view_grid_dimensions.y * screen_ratio
#
#	var image_scale = float(grid_tile_size) / float(image_tile_size) * grid_scale
#	map_frame.scale = Vector2(image_scale, image_scale)
#	map_frame.position = Vector2.ZERO
#	map_image.position = image_offset
#
#	cutout_frame.scale = map_frame.scale
#	cutout_frame.position = map_frame.position
#	cutout_image.position = map_image.position
#
#	tile_grid.clear()
#	var imgage_tile_width = int(ceil(image_size.x / image_tile_size))
#	var imgage_tile_hight = int(ceil(image_size.y / image_tile_size))
#	for x in imgage_tile_width:
#		for y in imgage_tile_hight:
#			tile_grid.set_cell(0,Vector2i(x,y), 0, Vector2i(0,0))
#
#	scaled_grid_tile_size = grid_tile_size * grid_scale
#	move_to_center_on(view_grid_position, true)
	
	
