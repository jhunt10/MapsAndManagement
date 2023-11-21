@tool
extends NinePatchRect

@export var ScaleTo : Control
@export var PushScale : Control
@export var padding : int
@export var force_update : int

var last_target_size : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ScaleTo:
		if force_update or last_target_size.x != ScaleTo.size.x or last_target_size.y != ScaleTo.size.y:
			calc_scale()
			force_update = 0

func calc_scale():
	if ScaleTo:
		var target_size = ScaleTo.size
#		target_size.x = self.patch_margin_left + ScaleTo.size.x + self.patch_margin_right
#		target_size.y = self.patch_margin_top + ScaleTo.size.y + self.patch_margin_bottom
		target_size.x = padding + ScaleTo.size.x + padding
		target_size.y = padding + ScaleTo.size.y + padding
		self.size = target_size
		last_target_size = ScaleTo.size
	if PushScale:
		PushScale.custom_minimum_size = self.size
		PushScale.size = self.size
