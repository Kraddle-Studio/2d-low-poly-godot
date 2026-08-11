@tool
extends EditorPlugin

var dock: EditorDock;


func _enter_tree() -> void:
	const DockWindow := preload("res://addons/2dlp/window/2dlp_window.tscn");
	
	var window := DockWindow.instantiate();
	
	dock = EditorDock.new();
	dock.add_child(window);
	
	dock.name = "2D Low Poly Assets";
	dock.default_slot = EditorDock.DockSlot.DOCK_SLOT_BOTTOM;
	dock.available_layouts = EditorDock.DOCK_LAYOUT_HORIZONTAL | EditorDock.DOCK_LAYOUT_FLOATING;
	
	add_dock(dock);


func _exit_tree() -> void:
	if dock:
		remove_dock(dock);
		dock.queue_free();
