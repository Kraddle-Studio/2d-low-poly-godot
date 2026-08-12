@tool

class_name LowPolyAsset2DEditorScene;
extends Node;


var camera_node: Camera2D;
var reference_rect_node: ReferenceRect;

var file: LowPolyAsset2D;


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
	camera_node.position = reference_rect_node.position + reference_rect_node.size / 2;
	
	if auto_zoom:
		var viewport_rect := get_viewport().get_visible_rect();
		var zoom_factor = 0.98 * min(
			viewport_rect.size.x / reference_rect_node.size.x,  
			viewport_rect.size.y / reference_rect_node.size.y);
		camera_node.zoom = Vector2(zoom_factor, zoom_factor);


func _update(delta: float) -> void:
	if file == null:
		return;
	
	self.reference_rect_node.size = self.file.size;