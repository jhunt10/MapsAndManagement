extends TileMap

const SHADOW_LAYER = 0
const SELECT_LAYER = 1

const NULL_CELL = -1
const REVEALED_CELL = 0
const SHADOW_CELL = 1
const TO_REVEAL_CELL = 2

@onready var dm_map_controller = $"../../../.."
@onready var copy_map : TileMap = $"../../../../../Window/PlayerMapController/FullFrame/ShadowCopyMap"

var map_data : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_layer(SELECT_LAYER)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_map(pos:Vector2i):
	return (pos.x >= 0 and pos.y >= 0 and 
		pos.x < dm_map_controller.grid_dimensions.x and pos.y < dm_map_controller.grid_dimensions.y)
	
func select_cell(pos:Vector2i):
	self.set_cell(SELECT_LAYER, pos, 1, Vector2i(0,0))

func select_range(rect:Rect2i):
	clear_selected()
	for x in rect.size.x:
		for y in rect.size.y:
			self.set_cell(
				SELECT_LAYER, 
				Vector2i(rect.position.x + x, rect.position.y + y), 
				1, Vector2i(0,0))

func clear_selected():
	self.clear_layer(SELECT_LAYER)

func fill_shadow():
	print("Fill Shadow: " + str(dm_map_controller.grid_dimensions))
	self.clear()
	for x in dm_map_controller.grid_dimensions.x:
		for y in dm_map_controller.grid_dimensions.y:
			var pos = Vector2i(x,y)
			set_cell_state(pos, SHADOW_CELL)
	build_fog_terrain_path()

func set_range_state(rect:Rect2i, state:int):
	for x in rect.size.x:
		for y in rect.size.y:
			var pos = Vector2i(rect.position.x + x, rect.position.y + y)
			set_cell_state(pos, state)

func apply_state():
	for x in dm_map_controller.grid_dimensions.x:
		for y in dm_map_controller.grid_dimensions.y:
			var pos = Vector2i(x,y)
			if map_data.has(pos):
				var state = map_data[pos]
				if state == TO_REVEAL_CELL:
					set_cell_state(pos, REVEALED_CELL)
				else:
					set_cell_state(pos, state)
	build_fog_terrain_path()
	
func build_fog_terrain_path():
	var shadow_arr = []
	for x in dm_map_controller.grid_dimensions.x:
		for y in dm_map_controller.grid_dimensions.y:
			var pos = Vector2i(x,y)
			if map_data.has(pos) and map_data[pos] == SHADOW_CELL:
				shadow_arr.append(pos)
	
	self.set_cells_terrain_connect(0, shadow_arr, 0, 0)
	copy_map.set_cells_terrain_connect(0, shadow_arr, 0, 0)
				
	
			
func set_cell_state(pos:Vector2i, state:int):
	match state:
		NULL_CELL:
			self.set_cell(SHADOW_LAYER, pos)
			copy_map.set_cell(SHADOW_LAYER, pos)
			map_data.erase(pos)
		REVEALED_CELL:
			self.set_cell(SHADOW_LAYER, pos)
			copy_map.set_cell(SHADOW_LAYER, pos)
			map_data[pos] = state
		SHADOW_CELL:
			self.set_cell(SHADOW_LAYER, pos, 0, Vector2i(0,0))
			map_data[pos] = state
		TO_REVEAL_CELL:	
			self.set_cell(SHADOW_LAYER, pos, 0, Vector2i(1,0))
			map_data[pos] = state
		

func save() -> Dictionary:
	var data = {
		"node_path": self.get_path(),
		"map_data" : map_data, 
	}
	return data
	
func load_data(save_path, data):
	self.clear()
	copy_map.clear()
	print("Shadow Map Loaded")
	map_data.clear()
	for x in dm_map_controller.grid_dimensions.x:
		for y in dm_map_controller.grid_dimensions.y:
			var pos = Vector2i(x,y)
			if data["map_data"].has(str(pos)):
				set_cell_state(pos, data["map_data"][str(pos)])
	build_fog_terrain_path()


