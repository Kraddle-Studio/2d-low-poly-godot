@tool

class_name LowPolyAsset2DEditorScene;
extends Node;


enum Mode { Select, Pan }
	
var camera_node: Camera2D;
var reference_rect_node: ReferenceRect;

var file: LowPolyAsset2D;
var mode: Mode = Mode.Select;

var panning := false;
var panning_prev_pos: Vector2;


func _ready() -> void:
	self.camera_node = Camera2D.new();
	add_child(self.camera_node);
	
	self.reference_rect_node = ReferenceRect.new();
	add_child(self.reference_rect_node);
	self.reference_rect_node.visible = false;


func set_file(file: LowPolyAsset2D) -> void:
	if file == self.file:
		return;
	
	var auto_zoom = self.file == null;
	self.file = file;
	clean_scene();
	
	if self.file == null:
		self.reference_rect_node.visible = false;
		return;
	
	# Set up reference rect
	self.reference_rect_node.visible = true;
	self.reference_rect_node.size = self.file.size;
	
	center_camera(auto_zoom);


func clean_scene() -> void:
	pass


func center_camera(auto_zoom: bool) -> void:
	if self.file == null:
		return;
	
	camera_node.position = reference_rect_node.position + reference_rect_node.size / 2;
	
	if auto_zoom:
		var viewport_rect := get_viewport().get_visible_rect();
		var zoom_factor = 0.98 * min(
			viewport_rect.size.x / reference_rect_node.size.x,  
			viewport_rect.size.y / reference_rect_node.size.y);
		camera_node.zoom = Vector2(zoom_factor, zoom_factor);


func set_mode(mode: Mode) -> void:
	self.mode = mode;
		

func left_mouse_panning_allowed() -> bool:
	return mode == Mode.Pan;


func right_mouse_panning_allowed() -> bool:
	return mode == Mode.Select or mode == Mode.Pan;


func _process(delta: float) -> void:
	if file == null:
		return;
	
	self.reference_rect_node.size = self.file.size;
	
	if panning:
		var pan_down: bool = (
			Input.is_action_pressed(LowPoly2DAssetsConstants.PAN_LEFT_CLICK_ACTION) 
				and left_mouse_panning_allowed()
			or Input.is_action_pressed(LowPoly2DAssetsConstants.PAN_RIGHT_CLICK_ACTION) 
				and right_mouse_panning_allowed()
		);
		if pan_down:
			var new_pos := camera_node.get_local_mouse_position();
			camera_node.position -= new_pos - self.panning_prev_pos;
			self.panning_prev_pos = new_pos;
		else:
			panning = false;
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW);
	else:
		var pan_pressed: bool = (
			Input.is_action_just_pressed(LowPoly2DAssetsConstants.PAN_LEFT_CLICK_ACTION)
				and left_mouse_panning_allowed()
			or Input.is_action_just_pressed(LowPoly2DAssetsConstants.PAN_RIGHT_CLICK_ACTION) 
				and right_mouse_panning_allowed()
		);
		
		if Input.is_action_just_pressed(LowPoly2DAssetsConstants.PAN_LEFT_CLICK_ACTION):
			print("Left mouse button pressed");
		if pan_pressed:
			print("Pan pressed");
		
		if pan_pressed and get_viewport().get_visible_rect().has_point(get_viewport().get_mouse_position()):
			panning = true;
			self.panning_prev_pos = camera_node.get_local_mouse_position();
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_DRAG);
		