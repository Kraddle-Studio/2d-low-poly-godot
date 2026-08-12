@tool

class_name LowPolyAsset2DEditor
extends HSplitContainer

var files: Array[LowPolyAsset2D];
var file_map: Dictionary[int, LowPolyAsset2D];

var current_file: LowPolyAsset2D;
var filter_string: String = "";

var editor_scene: LowPolyAsset2DEditorScene;


func _ready() -> void:
	%FileFilter.right_icon = EditorInterface.get_editor_theme().get_icon("FilenameFilter", "EditorIcons");
	%CollapseButton.icon = EditorInterface.get_editor_theme().get_icon("Forward", "EditorIcons");
	%PanModeButton.icon = EditorInterface.get_editor_theme().get_icon("ToolPan", "EditorIcons");
	%SelectModeButton.icon = EditorInterface.get_editor_theme().get_icon("ToolSelect", "EditorIcons");
	%CenterViewButton.icon = EditorInterface.get_editor_theme().get_icon("CenterView", "EditorIcons");
	
	self.editor_scene = LowPolyAsset2DEditorScene.new();
	%RenderViewport.add_child(self.editor_scene);
	
	%RenderViewportContainer.gui_input.connect(func (event: InputEvent):
		if self.editor_scene.handle_input(event):
			%RenderViewportContainer.accept_event();
	);


func open_file(file: LowPolyAsset2D):
	if not file in files:
		files.append(file);
	set_file(file);
	update_file_list();


func update_file_list():
	%FileList.clear();
	file_map.clear();
	
	for file in files:
		if filter_string != "" and not file.resource_path.contains(filter_string):
			continue;
		var index: int = %FileList.add_item(file.resource_path.get_file());
		%FileList.set_item_tooltip(index, file.resource_path);
		file_map.set(index, file);
		
		if file == self.current_file:
			%FileList.select(index);

func set_file(file: LowPolyAsset2D):
	current_file = file;
	editor_scene.set_file(file);


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


func _on_file_filter_text_changed(new_text: String) -> void:
	filter_string = new_text;
	update_file_list();


func _on_collapse_button_pressed() -> void:
	var collapsed: bool = not %FilesPanelContainer.is_visible_in_tree();
	
	%FilesPanelContainer.visible = collapsed;
	%CollapseButton.offset_transform_rotation = PI if collapsed else 0; 


func _on_center_view_button_pressed() -> void:
	self.editor_scene.center_camera(true);


func _on_select_mode_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		self.editor_scene.set_mode(LowPolyAsset2DEditorScene.Mode.Select);


func _on_pan_mode_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		self.editor_scene.set_mode(LowPolyAsset2DEditorScene.Mode.Pan);
