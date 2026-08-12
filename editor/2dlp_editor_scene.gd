@tool

class_name LowPolyAsset2DEditorScene;
extends Node2D;


enum Mode { Select, Pan }
	
var camera_node: Camera2D;
var reference_rect_node: ReferenceRect;

var file: LowPolyAsset2D;
var mode: Mode = Mode.Select;

var panning := false;
var panning_prev_pos: Vector2;

var show_points: bool = true;


func _ready() -> void:
	self.camera_node = Camera2D.new();
	add_child(self.camera_node);
	
	self.reference_rect_node = ReferenceRect.new();
	add_child(self.reference_rect_node);
	self.reference_rect_node.visible = false;
	
	var button := Button.new();
	button.text = "Test";
	add_child(button);


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
	queue_redraw();


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
	
	queue_redraw();
	
	self.reference_rect_node.size = self.file.size;
	
	var mouse_inside := get_viewport().get_visible_rect().has_point(get_viewport().get_mouse_position());
	
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
		
		if pan_pressed and mouse_inside:
			panning = true;
			self.panning_prev_pos = camera_node.get_local_mouse_position();
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_DRAG);
	
	var zoom_input := Input.get_axis(LowPoly2DAssetsConstants.ZOOM_OUT_ACTION, LowPoly2DAssetsConstants.ZOOM_IN_ACTION);
	if zoom_input != 0 and mouse_inside:
		var zoom_factor := 1.0 + zoom_input * LowPoly2DAssetsConstants.ZOOM_SPEED * delta;
		zoom(zoom_factor);
		

func handle_input(event: InputEvent) -> bool:
		
	if self.file == null:
		return false;

	var mouse_inside := get_viewport().get_visible_rect().has_point(get_viewport().get_mouse_position());
	if not mouse_inside:
		return false;

	if event is InputEventMagnifyGesture:
		zoom(event.factor);
		return true;
	
	return false;


func zoom(factor: float) -> void:
	var zoom := clamp(camera_node.zoom.x * factor, 0.02, 50.0);
	var mouse_pos_before_zoom := camera_node.get_local_mouse_position();
	camera_node.zoom = Vector2(zoom, zoom);
	var mouse_pos_after_zoom := camera_node.get_local_mouse_position();
	
	# Shift camera position to keep mouse position the same
	camera_node.position += mouse_pos_before_zoom - mouse_pos_after_zoom;
	

func _draw() -> void:
	if file == null:
		return;
	
	if show_points:
		for i in range(file.points.size()):
			var point := file.points[i];
			print("Draw");
			draw_circle(point, 1, Color.WHITE, true);
			draw_arc(point, 6, 0, TAU, 32, Color.WHITE, 1, true);
