@tool

class_name LowPolyAsset2DEditor
extends HSplitContainer

var files: Array[LowPolyAsset2D];
var file_map: Dictionary[int, LowPolyAsset2D];

var current_file: LowPolyAsset2D;


func open_file(file: LowPolyAsset2D):
	print(file, files);
	if not file in files:
		print("Will add file", file.resource_path.get_file());
		files.append(file);
		var index: int = %FileList.add_item(file.resource_path.get_file());
		%FileList.select(index);
		file_map.set(index, file);
	set_file(file);


func set_file(file: LowPolyAsset2D):
	current_file = file;


func _on_file_list_item_selected(index: int) -> void:
	if file_map.has(index):
		set_file(file_map[index]);


func _on_file_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		var context_menu := PopupMenu.new();
		
		context_menu.add_item("Close", 0);
		
		context_menu.id_pressed.connect(func(id): _on_file_list_context(id, index));
		context_menu.popup_hide.connect(context_menu.queue_free);
		
		%FileList.add_child(context_menu);
		
		var menu_position: Vector2 = at_position + %FileList.get_screen_position();
		context_menu.position = menu_position;
		context_menu.popup();


func _on_file_list_context(id: int, index: int) -> void:
	match id:
		0:
			if file_map.has(index):
				%FileList.remove_item(index);
				var file := file_map[index];
				if current_file == file:
					set_file(null);
				files.erase(file);