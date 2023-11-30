class_name DmMapControler
extends Control

signal map_data_initialized
signal map_rescaled
signal map_moved
signal map_inputs_changed

const SNAP_VIEW_TO_GRID = false
const CENTER_VIEW_ON_TILE_CENTER = true

@onready var quick_image : TextureRect = $"../Window/QuickImage"

@onready var player_map_controller : Node = $"../Window/PlayerMapController"

@onready var map_scroll_container : ScrollContainer = $ScrollContainer
@onready var map_container : Control = $ScrollContainer/MapContainer
@onready var inner_container : Control = $ScrollContainer/MapContainer/InnerContailer

@onready var map_frame : Node2D = $ScrollContainer/MapContainer/InnerContailer/MapFrame
@onready var map_image : Sprite2D = $ScrollContainer/MapContainer/InnerContailer/MapFrame/MapImage
@onready var tile_grid : TileMap = $ScrollContainer/MapContainer/InnerContailer/TileMap
@onready var cutout_frame : Node2D = $ScrollContainer/MapContainer/InnerContailer/CutoutFrame
@onready var cutout_image : Sprite2D = $ScrollContainer/MapContainer/InnerContailer/CutoutFrame/CutoutImage
@onready var view_preview : NinePatchRect = $ScrollContainer/MapContainer/InnerContailer/ViewPreview
@onready var view_target_preview : NinePatchRect = $ScrollContainer/MapContainer/InnerContailer/ViewTargetPreview
@onready var shadow_map : TileMap = $ScrollContainer/MapContainer/InnerContailer/ShadowMap
@onready var path_map : Node = $ScrollContainer/MapContainer/InnerContailer/TileMap/PathMap

@export var image_tile_size : float 
@export var grid_tile_size : float 
@export var dm_display_tile_size : float 
@export var image_offset : Vector2
@export var grid_dimensions : Vector2i 
@export var view_grid_dimensions : Vector2
@export var view_grid_position: Vector2

var image_scale : float = 1

var need_rescale : bool = false

var player_tile_grid: TileMap = null:
	get:
		return player_map_controller.tile_grid
	set(value):
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	print("DM Map Ready")
	dm_display_tile_size = 20
	var image_size = map_image.texture.get_size()
	map_container.custom_minimum_size = image_size
	
#	shadow_map.material.set_shader_parameter("image", map_image.texture)
	get_viewport().files_dropped.connect(on_files_dropped)

func on_files_dropped(files):
	var file_path = files[0]
	if file_path.ends_with(".png") or file_path.ends_with(".jpg"):
		load_quick_image(file_path)
	
func load_quick_image(file_path):
	var image = Image.new()
	image.load(file_path)
	var image_size = image.get_size()
	quick_image.texture = ImageTexture.create_from_image(image)
	var scale_x = float(player_map_controller.window.size.x) / float(image_size.y)
	var scale_y = float(player_map_controller.window.size.y) / float(image_size.x)
	var use_scale = 1
#	if scale_x < 1 or scale_y < 1:
	use_scale = min(scale_x, scale_y)
#	else:
#		use_scale = 1#max(scale_x, scale_y)
	print("Scale X:%s Y:%s Use:%s" % [scale_x, scale_y, use_scale])
		
	var scaled_size = image_size * use_scale
	quick_image.size = image_size
	quick_image.scale = Vector2(use_scale, use_scale)
	print(quick_image.size)
#	else:
#		quick_image.size = scaled_size
#	quick_image.rotation_degrees
	quick_image.position = Vector2(
	 player_map_controller.window.size.x - ((player_map_controller.window.size.x - scaled_size.y) / 2),
	 (player_map_controller.window.size.y - scaled_size.x) / 2)
#	quick_image.position = Vector2.ZERO
#	quick_image.size = image.get_size()
	quick_image.visible = true

func clear_quick_image():
	quick_image.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_view_preview()
	if need_rescale:
		_scale_map()
		need_rescale = false
	
func save() -> Dictionary:
	print("DM Map Saved")
	var data = {
		"node_path": self.get_path(),
		"image_tile_size" : image_tile_size, 
		"grid_tile_size" : grid_tile_size, 
		"dm_display_tile_size" : dm_display_tile_size,
		"image_offset" : [image_offset.x,image_offset.y],
		"grid_dimensions" : [grid_dimensions.x,grid_dimensions.y],
		"view_grid_dimensions" : [view_grid_dimensions.x,view_grid_dimensions.y],
		"view_grid_position" : [view_grid_position.x,view_grid_position.y],
	}
	return data
	
func load_data(save_path, data):
	print("Loading DM Map: " + save_path+"map.png")
	# Load Textures
	var map_image_texture = load_external_tex(save_path+"map.png")
	map_image.texture = map_image_texture
	var cutout_image_texture = load_external_tex(save_path+"cutout.png")
	cutout_image.texture = cutout_image_texture
	
	if data.has("image_tile_size"):
		image_tile_size = data["image_tile_size"]
	if data.has("grid_tile_size"):
		grid_tile_size = data["grid_tile_size"]
	if data.has("dm_display_tile_size"):
		dm_display_tile_size = data["dm_display_tile_size"]
	if data.has("image_offset"):
		image_offset = Vector2(data["image_offset"][0], data["image_offset"][1])
	if data.has("grid_dimensions"):	
		grid_dimensions = Vector2i(data["grid_dimensions"][0], data["grid_dimensions"][1])
	if data.has("view_grid_dimensions"):
		view_grid_dimensions = Vector2(data["view_grid_dimensions"][0], data["view_grid_dimensions"][1])
	if data.has("view_grid_position"):
		view_grid_position = Vector2(data["view_grid_position"][0], data["view_grid_position"][1])
	
	
#	shadow_map.material.set_shader_parameter("image", map_image.texture)
	
	init_map()
	
func init_map():
	var image_size = map_image.texture.get_size()
	# Calculate map dimintions based off image size
	var image_grid_width = int(ceilf(image_size.x / image_tile_size)) 
	var image_grid_hight = int(ceilf(image_size.y / image_tile_size))
	grid_dimensions = Vector2i(image_grid_width, image_grid_hight)
	_build_grids()

	# Scale image to grid
	_scale_map()
	update_view_preview()
	map_data_initialized.emit()

func _scale_map():
	print("DM Map Controller Rescale Map")
	var image_to_tile_scale = grid_tile_size / image_tile_size
	map_frame.scale = Vector2(image_to_tile_scale, image_to_tile_scale)
	map_image.position = image_offset
	
	var grid_to_display_scale = dm_display_tile_size / grid_tile_size 
	var test = grid_dimensions * grid_tile_size * grid_to_display_scale
	map_container.custom_minimum_size = test
	map_container.update_minimum_size()
	inner_container.scale = Vector2(grid_to_display_scale, grid_to_display_scale)
	
	_sync_cutout()
	map_rescaled.emit()
	
func _sync_cutout():
	cutout_frame.scale = 	map_frame.scale
	cutout_frame.position = map_frame.position
	cutout_image.scale = 	map_image.scale
	cutout_image.position = map_image.position
	
	
func _build_grids():
	shadow_map.clear()
	tile_grid.clear()
	for x in grid_dimensions.x:
		for y in grid_dimensions.y:
			tile_grid.set_cell(0,Vector2i(x,y),0, Vector2i(0,0))
	
func on_map(pos:Vector2i):
	return (pos.x >= 0 and pos.y >= 0 and 
		pos.x < grid_dimensions.x and pos.y < grid_dimensions.y)
		
func move_view_preview(focus_pos:Vector2):
	view_grid_position = focus_pos
	update_view_preview()

func calc_view_center_offset(grid_dim, tile_size):
	var offset = grid_dim * 0.5 * tile_size
	if SNAP_VIEW_TO_GRID:
		offset = floor(grid_dim * 0.5) * tile_size	
	if CENTER_VIEW_ON_TILE_CENTER:
		offset -= Vector2(tile_size,tile_size) * 0.5
	return offset

func update_view_preview():
	view_preview.size = player_map_controller.view_grid_dimensions * grid_tile_size
	view_target_preview.size = view_grid_dimensions * grid_tile_size
	
	var preview_offset = calc_view_center_offset(view_grid_dimensions, grid_tile_size)
	view_target_preview.position = (view_grid_position * grid_tile_size) - preview_offset
	
	var view_offset = calc_view_center_offset(player_map_controller.view_grid_dimensions, grid_tile_size)
	view_preview.position = (player_map_controller.view_grid_position * grid_tile_size) - view_offset


func set_screen_size(vec:Vector2):
	var width_in_tiles = floori(vec.x / image_tile_size)
	var hight_in_tiles = floori(vec.y / image_tile_size)
	view_grid_dimensions = Vector2(width_in_tiles, hight_in_tiles)
	
	print(view_grid_dimensions)
	map_inputs_changed.emit()
	player_map_controller.sync_view(true)
	pass


func set_image_tile_size(val):
	self.image_tile_size= val
	need_rescale = true

func set_grid_tile_size(val):
	self.grid_tile_size = val
	need_rescale = true

func set_display_tile_size(val):
	self.dm_display_tile_size = val
	need_rescale = true

func set_image_offset(vec):
	self.image_offset = vec
	need_rescale = true

func set_grid_dimentions(vec):
	self.view_grid_dimensions = vec
	need_rescale = true

func set_image_offset_x(val):
	self.image_offset.x = val
	need_rescale = true

func set_image_offset_y(val):
	self.image_offset.y = val
	need_rescale = true
	
func set_grid_view_width(val):
	self.view_grid_dimensions.x = val
	update_view_preview()

func set_grid_view_hight(val):
	self.view_grid_dimensions.y = val
	var screen_ratio = float(player_map_controller.window.size.x) / float(player_map_controller.window.size.y)
	self.view_grid_dimensions.x = float(val) * screen_ratio
	map_inputs_changed.emit()
	update_view_preview()

func set_grid_view_pos_x(val):
	self.view_grid_position.x = int(val)
	update_view_preview()
	
func set_grid_view_pos_y(val):
	self.view_grid_position.y = int(val)
	update_view_preview()

func load_external_tex(path):
	var tex_file = FileAccess.open(path, FileAccess.READ)
	var bytes = tex_file.get_buffer(tex_file.get_length())
	var img = Image.new()
	var data = img.load_png_from_buffer(bytes)
	var imgtex = ImageTexture.create_from_image(img)
	tex_file.close()
	return imgtex
