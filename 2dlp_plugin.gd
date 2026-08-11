@tool
extends EditorPlugin

var dock: EditorDock;
var editor: LowPolyAsset2DEditor;
var current_asset: LowPolyAsset2D;


func _enter_tree() -> void:
	const EditorWindow := preload("res://addons/2dlp/editor/2dlp_window.tscn");
	
	editor = EditorWindow.instantiate();
	
	dock = EditorDock.new();
	dock.add_child(editor);
	
	dock.name = "2D Low Poly Assets";
	dock.default_slot = EditorDock.DockSlot.DOCK_SLOT_BOTTOM;
	dock.available_layouts = EditorDock.DOCK_LAYOUT_HORIZONTAL | EditorDock.DOCK_LAYOUT_FLOATING;
	
	add_dock(dock);


func _exit_tree() -> void:
	if dock:
		remove_dock(dock);
		dock.queue_free();


func _handles(object: Object) -> bool:
	return object is LowPolyAsset2D;


func _edit(object: Object) -> void:
	if object is LowPolyAsset2D:
		self.current_asset = object;
		editor.open_file(object);
		dock.make_visible();
	else:
		self.current_asset = null;
