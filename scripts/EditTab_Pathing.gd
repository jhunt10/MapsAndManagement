extends BoxContainer

const NORTH : int = 0
const NORTH_EAST : int = 1
const EAST : int = 2
const SOUTH_EAST : int = 3
const SOUTH : int = 4
const SOUTH_WEST : int = 5
const WEST : int = 6
const NORTH_WEST : int = 7

@onready var are_you_sure_box = $"../../../../AreYouSure"
@onready var dm_map_controller = $"../../../../DMMapController"
var path_map : Node 

@onready var show_path_check_box : CheckBox = $PathDrawButtons/BoxContainer3/ShowContainer/ShowPathCeckBox
@onready var square_draw_state_button : TextureButton = $PathDrawButtons/BoxContainer/DrawSquareButton
@onready var fullauto_draw_state_button : TextureButton = $PathDrawButtons/BoxContainer/DrawFullButton
@onready var line_draw_state_button : TextureButton = $PathDrawButtons/BoxContainer/DrawLineButton
@onready var break_draw_state_button : TextureButton = $PathDrawButtons/BoxContainer2/BreakButton
@onready var erase_draw_state_button : TextureButton = $PathDrawButtons/BoxContainer2/EraseButton
@onready var clear_button : TextureButton = $PathDrawButtons/BoxContainer2/ClearButton

@onready var movement_state_button : TextureButton = $PathDrawButtons/BoxContainer3/MoveRangeButton
@onready var movement_speed_input : SpinBox = $PathDrawButtons/BoxContainer3/MoveRangeInput

const DRAW_SQUARE = 0
const DRAW_FULLAUTO = 1
const DRAW_LINE = 2
const DRAW_ERASE = 3
const SHOW_MOVEMENT = 4
const DRAW_BREAK = 5

var draw_buttons : Array = []
var selected_draw_texture : Texture2D
var unselected_draw_texture : Texture2D
var draw_state : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	path_map = dm_map_controller.path_map
	draw_buttons = [square_draw_state_button, fullauto_draw_state_button, line_draw_state_button, 
					erase_draw_state_button, movement_state_button, break_draw_state_button]
	square_draw_state_button.button_down.connect(on_draw_button.bind(DRAW_SQUARE))
	fullauto_draw_state_button.button_down.connect(on_draw_button.bind(DRAW_FULLAUTO))
	line_draw_state_button.button_down.connect(on_draw_button.bind(DRAW_LINE))
	erase_draw_state_button.button_down.connect(on_draw_button.bind(DRAW_ERASE))
	movement_state_button.button_down.connect(on_draw_button.bind(SHOW_MOVEMENT))
	break_draw_state_button.button_down.connect(on_draw_button.bind(DRAW_BREAK))
	clear_button.pressed.connect(on_clear)
	show_path_check_box.toggled.connect(on_show_toggle_pressed)
	draw_buttons[draw_state].disabled = true
	
	on_draw_button(SHOW_MOVEMENT)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_clear():
	are_you_sure_box.bind_action("Erase all path data", confirm_clear)

func confirm_clear():
	path_map.clear_all()

func apply_line(start_pos:Vector2i, end_pos:Vector2i):
	if draw_state == DRAW_LINE:
		print("Draw Line p1:%s p2:%s" % [str(start_pos), str(end_pos)])
		if abs(start_pos.x - end_pos.x) <= 1 and abs(start_pos.y - end_pos.y) <= 1:
			var dir = get_dirrection(start_pos, end_pos)
			path_map.create_connection(start_pos, dir, true)
	if draw_state == SHOW_MOVEMENT:
		var speed = movement_speed_input.value
		path_map.draw_movement_range(end_pos, speed)
	

func apply_rec(drag_rect:Rect2i):
	if draw_state == DRAW_SQUARE:
		path_map.add_range_to_path(drag_rect)
	if draw_state == DRAW_FULLAUTO:
		path_map.add_range_to_path(drag_rect, true)
	if draw_state == DRAW_ERASE:
		path_map.erase_range(drag_rect)
	if draw_state == DRAW_BREAK:
		path_map.break_range(drag_rect)
	pass

func on_show_toggle_pressed(show):
	if show:
		print("Show Map")
		path_map.show_map = true
		path_map.queue_redraw()
	else:
		print("Hide Map")
		path_map.show_map = false
		path_map.queue_redraw()

func on_draw_button(index:int):
	draw_state = index
	for but in draw_buttons:
		but.disabled = false
	draw_buttons[index].disabled = true
	
func get_dirrection(pos1:Vector2, pos2:Vector2i):
	# North
	if pos1.y > pos2.y:
		if pos1.x < pos2.x:
			return NORTH_EAST
		elif pos1.x > pos2.x:
			return NORTH_WEST
		else:
			return NORTH
	# South
	if pos1.y < pos2.y:
		if pos1.x < pos2.x:
			return SOUTH_EAST
		elif pos1.x > pos2.x:
			return SOUTH_WEST
		else:
			return SOUTH
	else:
		if pos1.x < pos2.x:
			return EAST
		elif pos1.x > pos2.x:
			return WEST
	return -1
		
