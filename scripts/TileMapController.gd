extends Node2D

signal data_changed
signal map_moved

@onready var window : Window = $"../"
@onready var map_frame : Node2D = $"MapFrame"
@onready var map_image : Sprite2D = $"MapFrame/MapImage"
@onready var tile_grid : TileMap = $"TileMap"
@onready var cutout_frame : Node2D = $"CutoutFrame"
@onready var cutout_image : Sprite2D = $"CutoutFrame/CutoutImage"
@onready var shadow_map : TileMap = $ShadowCopyMap

@export var image_tile_size : float 
@export var grid_tile_size : float 
@export var dm_display_tile_size : float 

@export var image_offset : Vector2
@export var view_grid_dimensions : Vector2
@export var view_grid_position: Vector2

var scaled_grid_tile_size : float = 20
var rescale : bool = false

var MOVE_SPEED : float = 100
var moving : bool = false
var target_pos : Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	dm_display_tile_size = 20
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rescale:
		scale_map_image()
		data_changed.emit()
		rescale = false
	if moving:
		position = position.move_toward(target_pos, MOVE_SPEED * delta)
		if (abs(position.x - target_pos.x) < 1 and abs(position.y - target_pos.y) < 1):
			print("Move Done: " + str(position) + " : " + str(target_pos))
			position = target_pos
			moving = false
	pass
	
func save() -> Dictionary:
	var data = {
		"node_path": self.get_path(),
		"image_tile_size" : image_tile_size, 
		"grid_tile_size" : grid_tile_size, 
		"dm_display_tile_size" : dm_display_tile_size,
		"image_offset" : [image_offset.x,image_offset.y],
		"view_grid_dimensions" : [view_grid_dimensions.x,view_grid_dimensions.y],
		"view_grid_position" : [view_grid_position.x,view_grid_position.y],
	}
	return data
	
func load_data(save_path, data):
	var map_image_texture = load(save_path+"map.png")
	map_image.texture = map_image_texture
	
	var cutout_image_texture = load(save_path+"cutout.png")
	cutout_image.texture = cutout_image_texture
	
	image_tile_size = data["image_tile_size"]
	grid_tile_size = data["grid_tile_size"]
	image_offset = Vector2(data["image_offset"][0],data["image_offset"][1])
	view_grid_dimensions = Vector2(data["view_grid_dimensions"][0],data["view_grid_dimensions"][1])
	view_grid_position= Vector2(data["view_grid_position"][0],data["view_grid_position"][1])
	data_changed.emit()
	rescale = true

func move_map(vec:Vector2):
	move_to_center_on(view_grid_position + vec)

func move_to_center_on(vec:Vector2, force:bool = false):
	view_grid_position = vec
	var grid_center = floor(view_grid_dimensions * 0.5) * scaled_grid_tile_size
	var offset = (view_grid_position * scaled_grid_tile_size)
	target_pos = grid_center - offset
	moving = true
	MOVE_SPEED = position.distance_to(target_pos)
	if force:
		self.position = target_pos
		moving = false
	map_moved.emit()
	

func scale_map_image():
	print("Map Controller Rescale Map")
	var screen_ratio = float(window.size.x) / float(window.size.y)
	var image_size = map_image.texture.get_size()
	var map_tile_dimentions = Vector2i( 
		ceili(image_size.x / image_tile_size),
		ceili(image_size.y / image_tile_size)) 
	
	var grid_scale = window.size.y  / (grid_tile_size * view_grid_dimensions.y)
	tile_grid.scale = Vector2(grid_scale, grid_scale)
	shadow_map.scale = tile_grid.scale
	view_grid_dimensions.x = view_grid_dimensions.y * screen_ratio
	
	var image_scale = float(grid_tile_size) / float(image_tile_size) * grid_scale
	map_frame.scale = Vector2(image_scale, image_scale)
	map_frame.position = Vector2.ZERO
	map_image.position = image_offset
	
	cutout_frame.scale = map_frame.scale
	cutout_frame.position = map_frame.position
	cutout_image.position = map_image.position
	
	tile_grid.clear()
	var imgage_tile_width = int(ceil(image_size.x / image_tile_size))
	var imgage_tile_hight = int(ceil(image_size.y / image_tile_size))
	for x in imgage_tile_width:
		for y in imgage_tile_hight:
			tile_grid.set_cell(0,Vector2i(x,y), 0, Vector2i(0,0))
			
	scaled_grid_tile_size = grid_tile_size * grid_scale
	move_to_center_on(view_grid_position, true)
	
	
func set_image_tile_size(val):
	self.image_tile_size= val
	rescale = true
	
func set_grid_tile_size(val):
	self.grid_tile_size = val
	rescale = true
	
func set_image_offset(vec):
	self.image_offset = vec
	rescale = true
	
func set_grid_dimentions(vec):
	self.view_grid_dimensions = vec
	rescale = true
	
func set_image_offset_x(val):
	self.image_offset.x = val
	rescale = true
	
func set_image_offset_y(val):
	self.image_offset.y = val
	rescale = true

func set_grid_view_width(val):
	self.view_grid_dimensions.x = val
	rescale = true

func set_grid_view_hight(val):
	self.view_grid_dimensions.y = val
	rescale = true

func set_grid_view_pos_x(val):
	self.view_grid_position.x = int(val)
	
func set_grid_view_pos_y(val):
	self.view_grid_position.y = int(val)
