extends Control

var drag_element : Node
var dragging = false
var drag_start : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		var mouse_pos = self.get_local_mouse_position()
		# Inside Bounds
		if (mouse_pos.x >= 0 and mouse_pos.y >= 0
			and mouse_pos.x <= self.size.x 
			and mouse_pos.y <= self.size.y):
				
			print("Click: %s" % mouse_pos)
			
			# Drag Logic
			if drag_element:
				var drag_pos = drag_element.get_local_mouse_position()
				if (drag_pos.x >= 0 and drag_pos.y >= 0
					and drag_pos.x <= drag_element.size.x 
					and drag_pos.y <= drag_element.size.y):
						
					# Left Click
					if mouse_event.pressed:
						dragging = true
						drag_start = mouse_event.position
					else:
						dragging = false
		get_viewport().set_input_as_handled()
	if event is InputEventMouseMotion:
		if dragging:
			var mouse_event = event as InputEventMouseMotion
			var drag_dif = mouse_event.position - drag_start
			self.position += drag_dif
			drag_start = mouse_event.position
