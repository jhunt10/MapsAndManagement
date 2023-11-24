extends BoxContainer

const TERAIN_TILE_SET_ID = 2

var dm_terrain_layer : int = -1
var player_terrain_layer : int = -1

@onready var dm_map_controller = $"../../../../DMMapController"
@onready var terrain_options = $DrawButtons/ScrollContainer/TerrainOptionController

@onready var draw_button : TextureButton = $DrawButtons/ButtonsContainer/AddButton
@onready var erase_button : TextureButton = $DrawButtons/ButtonsContainer/EraseButton

var drawing : bool = false
var zone_data : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	draw_button.button_down.connect(on_draw_button)
	erase_button.button_down.connect(on_erase_button)
	on_draw_button()
	pass # Replace with function body.

func on_draw_button():
	draw_button.disabled = true
	erase_button.disabled = false
	drawing = true
	pass

func on_erase_button():
	draw_button.disabled = false
	erase_button.disabled = true
	drawing = false
	pass
	
func init():
	if dm_terrain_layer < 0:
		dm_map_controller.tile_grid.add_layer(-1)
		dm_terrain_layer = dm_map_controller.tile_grid.get_layers_count() - 1
	if player_terrain_layer < 0:
		dm_map_controller.player_tile_grid.add_layer(-1)
		player_terrain_layer = dm_map_controller.player_tile_grid.get_layers_count() - 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func apply_rec(drag_rect:Rect2i):
	for x in drag_rect.size.x:
		for y in drag_rect.size.y:
			var pos = Vector2i(x + drag_rect.position.x, y + drag_rect.position.y)
			if drawing:
				set_zone_tile(pos, terrain_options.selected_co)
			else:
				clear_zone(pos)
	pass
	
func clear_zone(pos):
	if dm_terrain_layer < 0:
		init()
	zone_data.erase(pos)
	dm_map_controller.tile_grid.set_cell(dm_terrain_layer, pos)
	dm_map_controller.player_tile_grid.set_cell(player_terrain_layer, pos)
	
func set_zone_tile(pos, terrain_co):
	if dm_terrain_layer < 0:
		init()
	zone_data[pos] = terrain_co
	dm_map_controller.tile_grid.set_cell(dm_terrain_layer, pos, TERAIN_TILE_SET_ID, terrain_co)
	dm_map_controller.player_tile_grid.set_cell(player_terrain_layer, pos, TERAIN_TILE_SET_ID, terrain_co)

func save() -> Dictionary:
	var data = {
		"node_path": self.get_path(),
		"zone_data" : zone_data, 
	}
	return data
	
func load_data(save_path, data):
	zone_data.clear()
	var load_zone_data = data["zone_data"]
	for key in load_zone_data:
		var pos : Vector2i = str_to_vec2i(key)
		var val : Vector2i = str_to_vec2i(load_zone_data[key])
		zone_data[key] = val
		set_zone_tile(pos, val)
	self.queue_redraw()
	
func str_to_vec2i(str:String) -> Vector2i:
	var tokens = str.trim_prefix("(").trim_suffix(")").split(",")
	if tokens.size() != 2:
		print("Can't parse " + str + " as Vect2i")
		return Vector2i.ZERO
	return Vector2i(int(tokens[0]), int(tokens[1]))
