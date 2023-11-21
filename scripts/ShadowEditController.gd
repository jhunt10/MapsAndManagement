extends BoxContainer

const NULL_CELL = -1
const REVEALED_CELL = 0
const SHADOW_CELL = 1
const TO_REVEAL_CELL = 2

@onready var dm_map_controller = $"../../../../DMMapController"

@onready var reveal_draw_state_button : TextureButton = $BoxContainer2/RevealButton
@onready var shadow_draw_state_button : TextureButton = $BoxContainer2/ShadowButton
@onready var shadow_all_button : TextureButton = $ButtonsContainer2/ShadowAll
@onready var reveal_all_button : TextureButton = $ButtonsContainer2/RevealAllButton

var draw_buttons = [reveal_draw_state_button, shadow_draw_state_button]
var selected_draw_texture : Texture2D
var unselected_draw_texture : Texture2D
var draw_state : int = TO_REVEAL_CELL

# Called when the node enters the scene tree for the first time.
func _ready():
	selected_draw_texture = reveal_draw_state_button.texture_normal
	unselected_draw_texture = shadow_draw_state_button.texture_normal
	reveal_draw_state_button.button_down.connect(on_draw_reveal)
	shadow_draw_state_button.button_down.connect(on_draw_shadow)
	
	shadow_all_button.button_down.connect(on_shadow_all)
	reveal_all_button.button_down.connect(on_reveal_all)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func apply_rec(drag_rect:Rect2i):
	dm_map_controller.shadow_map.set_range_state(drag_rect, draw_state)
	pass
	

func on_shadow_all():
	dm_map_controller.shadow_map.fill_shadow()
	pass
	

func on_reveal_all():
	pass
	
func on_draw_reveal():
	draw_state = TO_REVEAL_CELL
	reveal_draw_state_button.disabled = true
	shadow_draw_state_button.disabled = false
	
func on_draw_shadow():
	draw_state = SHADOW_CELL
	reveal_draw_state_button.disabled = false
	shadow_draw_state_button.disabled = true
