extends Control

const NORTH : int = 0
const NORTH_EAST : int = 1
const EAST : int = 2
const SOUTH_EAST : int = 3
const SOUTH : int = 4
const SOUTH_WEST : int = 5
const WEST : int = 6
const NORTH_WEST : int = 7

const DIRECTIONS = [NORTH, NORTH_EAST, EAST, SOUTH_EAST, SOUTH, SOUTH_WEST, WEST, NORTH_WEST]

const PATH_LAYER = 1

@onready var dm_map_controller : Node = $"../../../../.."
@onready var dm_tile_map : TileMap = $".."
@onready var player_tile_map : TileMap = $"../../../../../../Window/PlayerMapController/FullFrame/TileMap"

var path_map : Dictionary = {}

var show_map : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	dm_map_controller.map_rescaled.connect(on_rescale)
	dm_tile_map.add_layer(PATH_LAYER)
	player_tile_map.add_layer(PATH_LAYER)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_rescale():
	self.queue_redraw()
	
func clear_all():
	path_map.clear()
	self.queue_redraw()
	
func create_connection(pos:Vector2i, dir:int, refresh:bool = false):
	var pos2 = translate_direction(pos, dir)
	var dir2 = reverse_direction(dir)
	if not path_map.has(pos):
		path_map[pos] = [0,0,0,0,0,0,0,0]
	path_map[pos][dir] = 1
	if not path_map.has(pos2):
		path_map[pos2] = [0,0,0,0,0,0,0,0]
	path_map[pos2][dir2] = 1
	if refresh:
		self.queue_redraw()

func break_connection(pos:Vector2i, dir:int, refresh:bool = false):
	var pos2 = translate_direction(pos, dir)
	var dir2 = reverse_direction(dir)
	if path_map.has(pos):
		path_map[pos][dir] = 0
	if path_map.has(pos2):
		path_map[pos2][dir2] = 0
	if refresh:
		self.queue_redraw()
	

func erase_point(pos:Vector2i):
	if not path_map.has(pos):
		return
	for dir in DIRECTIONS:
		if path_map[pos][dir] > 0:
			var pos2 = translate_direction(pos, dir)
			var dir2 = reverse_direction(dir)
			if path_map.has(pos2):
				path_map[pos2][dir2] = 0
	path_map.erase(pos)

func erase_range(range : Rect2i):
	for x in range.size.x:
		for y in range.size.y:
			var pos = Vector2i(range.position.x + x, range.position.y + y)
			erase_point(pos)
	self.queue_redraw()
	
func break_range(range : Rect2i):
	for x in range.size.x:
		for y in range.size.y:
			var pos = Vector2i(range.position.x + x, range.position.y + y)
			if not path_map.has(pos):
				continue
			for dir in DIRECTIONS:
				if path_map[pos][dir] == 0:
					continue
				var pos2 = translate_direction(pos, dir)
				if range.has_point(pos2):
					break_connection(pos, dir)
	self.queue_redraw()
	

func add_range_to_path(range : Rect2i, full_auto:bool = false):
	for x in range.size.x:
		for y in range.size.y:
			var pos = Vector2i(range.position.x + x, range.position.y + y)
			var arr = [0,0,0,0,0,0,0,0]
			if pos.y > range.position.y:
				create_connection(pos, NORTH)
				arr[NORTH] = 1
			if pos.x < range.position.x + range.size.x -1:
				create_connection(pos, EAST)
				arr[EAST] = 1
			if pos.y < range.position.y + range.size.y -1:
				create_connection(pos, SOUTH)
				arr[SOUTH] = 1
			if pos.x > range.position.x:
				create_connection(pos, WEST)
				arr[WEST] = 1
			if arr[NORTH] and arr[EAST]:
				create_connection(pos, NORTH_EAST)
			if arr[NORTH] and arr[WEST]:
				create_connection(pos, NORTH_WEST)
			if arr[SOUTH] and arr[EAST]:
				create_connection(pos, SOUTH_EAST)
			if arr[SOUTH] and arr[WEST]:
				create_connection(pos, SOUTH_WEST)
			if full_auto:
				for dir in DIRECTIONS:
					var pos2 = translate_direction(pos, dir)
					if path_map.has(pos2):
						create_connection(pos, dir)
	self.queue_redraw()


func _draw():
	print("Drawing Path Map")
	if show_map:
		print("For real")
		draw_path_map()
	else:
		print("Not Really")

func draw_path_map():
	print("Draw LineL: " + str(dm_map_controller.grid_tile_size))
	for x in dm_map_controller.grid_dimensions.x:
		for y in dm_map_controller.grid_dimensions.y:
			var pos = Vector2i(x, y)
			if not path_map.has(pos):
				continue
			for dir in DIRECTIONS:
				if path_map[pos][dir]:
					var pos2 = translate_direction(pos, dir)
					var dir2 = reverse_direction(dir)
					var valid_pair = path_map.has(pos2) and path_map[pos2][dir2] == 1
					draw_line_between_tiles(pos, pos2, valid_pair) 

func draw_line_between_tiles(pos1 : Vector2i, pos2 : Vector2i, valid:bool):
	var tile_size = dm_map_controller.grid_tile_size
	var half_tile = floori(tile_size / 2)
	var half_pos = Vector2(half_tile, half_tile)
	var p1 = (pos1 * tile_size) + half_pos 
	var p2 = (pos2 * tile_size) + half_pos 
	if valid:
		draw_line(p1, p2, Color.GREEN, 3.0)
	else:
		draw_line(p1, p2, Color.RED, 3.0)

func reverse_direction(dir:int)->int:
	var outval =(dir + 4) % 8
	return outval
	
func translate_direction(pos : Vector2i, dir : int) -> Vector2i:
	match dir:
		NORTH: return pos + Vector2i(0, -1)
		NORTH_EAST: return pos + Vector2i(1, -1)
		EAST: return pos + Vector2i(1, 0)
		SOUTH_EAST: return pos + Vector2i(1, 1)
		SOUTH: return pos + Vector2i(0, 1)
		SOUTH_WEST: return pos + Vector2i(-1, 1)
		WEST: return pos + Vector2i(-1, 0)
		NORTH_WEST: return pos + Vector2i(-1, -1)
	return pos


func save() -> Dictionary:
	var data = {
		"node_path": self.get_path(),
		"path_map" : path_map, 
	}
	return data
	
func load_data(save_path, data):
	path_map.clear()
	for x in dm_map_controller.grid_dimensions.x:
		for y in dm_map_controller.grid_dimensions.y:
			var pos = Vector2i(x,y)
			if data["path_map"].has(str(pos)):
#				set_cell_state(pos, data["map_data"][str(pos)])
				var arr = data["path_map"][str(pos)]
				path_map[pos] = arr
	self.size = dm_map_controller.grid_dimensions * dm_map_controller.grid_tile_size
	self.queue_redraw()
	
func draw_movement_range(pos, speed):
	dm_tile_map.clear_layer(PATH_LAYER)
	player_tile_map.clear_layer(PATH_LAYER)
	var area = search_path(pos, speed)
	for p in area:
		var speed_left = area[p]
		if p == pos:
			dm_tile_map.set_cell(PATH_LAYER,p,1,Vector2i(0,1))
			player_tile_map.set_cell(PATH_LAYER,p,1,Vector2i(0,1))
		elif speed_left > 0:
			dm_tile_map.set_cell(PATH_LAYER,p,1,Vector2i(1,0))
			player_tile_map.set_cell(PATH_LAYER,p,1,Vector2i(1,0))
		else:
			dm_tile_map.set_cell(PATH_LAYER,p,1,Vector2i(2,0))
			player_tile_map.set_cell(PATH_LAYER,p,1,Vector2i(2,0))

func clear_movement_range():
	dm_tile_map.clear_layer(PATH_LAYER)
	player_tile_map.clear_layer(PATH_LAYER)

func search_path(pos:Vector2i, speed:int) -> Dictionary:
	if not path_map.has(pos):
		return {}
		
	var searched : Dictionary = {}
	var to_check : Array = [pos]
	searched[pos] = speed
	while to_check.size() > 0:
		var check = to_check.pop_front()
		var cur_speed = searched[check]
		var connections = path_map[check]
		for dir in DIRECTIONS:
			if connections[dir] == 0:
				continue
			var next_pos = translate_direction(check, dir)
			# Outside of map
			if not path_map.has(next_pos):
				continue
			# Get Speed Left
			var next_speed = cur_speed - 5
			# Already found shorter path
			if searched.has(next_pos):
				if searched[next_pos] >= next_speed:
					continue
			# Record Path and add to be checked
			searched[next_pos] = next_speed
			if next_speed > 0:
				to_check.append(next_pos)
	return searched
