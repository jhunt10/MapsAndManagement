extends GridContainer

const TILE_SIZE = 20

var buttons : Array = []
var selected_index : int = 0
var selected_co : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	load_terrains()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_terrains():
	var button_width = 60
	var image : Image = Image.load_from_file("res://tiles/terrain_tiles.png")
	var image_size = image.get_size()
	var rec : Rect2i = Rect2i(0,0,TILE_SIZE,TILE_SIZE)
	buttons.clear()
	for y in floori(image_size.y / TILE_SIZE):
		for x in floori(image_size.x / TILE_SIZE):
			var new_button : TextureButton = TextureButton.new()
			self.add_child(new_button)
			rec.position.x = TILE_SIZE * x
			rec.position.y = TILE_SIZE * y
			var new_image = image.get_region(rec)
			var texture = ImageTexture.create_from_image(new_image)
			var selected_texture = ImageTexture.create_from_image(outline_image(new_image))
			new_button.stretch_mode = TextureButton.STRETCH_SCALE
			new_button.texture_normal = texture
			new_button.texture_disabled = selected_texture
			new_button.size = Vector2i(button_width, button_width)
			new_button.custom_minimum_size = Vector2i(button_width, button_width)
			var atlas_co = Vector2i(x,y)
			new_button.pressed.connect(on_select.bind(buttons.size(), atlas_co))
			buttons.append(new_button)
			
func on_select(i, cos):
	selected_index = i
	selected_co = cos
	for n in buttons.size():
		buttons[n].disabled = n == i
			
func outline_image(image:Image)->Image:
	var new_image = image.duplicate()
	var color = Color.YELLOW
	for i in TILE_SIZE:
		new_image.fill_rect(Rect2i(0,0,TILE_SIZE,1), color)
		new_image.fill_rect(Rect2i(0,0,1,TILE_SIZE), color)
		new_image.fill_rect(Rect2i(0,0,TILE_SIZE,1), color)
		new_image.fill_rect(Rect2i(TILE_SIZE-1,0,1,TILE_SIZE), color)
		new_image.fill_rect(Rect2i(0,TILE_SIZE-1,TILE_SIZE,1), color)
	return new_image
