@tool

class_name LowPolyAsset2D
extends Resource

@export var width: int = 512;
@export var height: int = 512;

var size: Vector2:
	get:
		return Vector2(width, height);

@export
var points: PackedVector2Array;


@export var edges: Array[LowPolyAsset2DEdge];
@export var polygons: Array[LowPolyAsset2DPolygon];

@export_group("SVG Export")
@export_custom(PropertyHint.PROPERTY_HINT_SAVE_FILE, "*.svg") var svg_export_path: String = "";
@export_tool_button("Export SVG", "Save") var export_svg_action: Callable = export_svg_to_configured_path;


func try_append_edge(a: int, b: int) -> bool:
	var new_edge := LowPolyAsset2DEdge.new();
	new_edge.a = a;
	new_edge.b = b;
	
	for edge in edges:
		if edge.equals(new_edge):
			return false;
	
	edges.append(new_edge);
	return true;


func try_append_polygon(points: Array[int], color: Color) -> bool:
	var new_polygon := LowPolyAsset2DPolygon.new();
	new_polygon.points = points.duplicate();
	new_polygon.color = color;
	
	for polygon in polygons:
		if polygon.equals(new_polygon):
			return false;
	
	polygons.append(new_polygon);
	return true;


func export_svg(path: String) -> Error:
	var svg := PackedStringArray([
		"<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
		"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\">" % [width, height, width, height],
	]);

	for polygon in polygons:
		var polygon_points := PackedStringArray();
		for point_index in polygon.points:
			var point := points[point_index];
			polygon_points.append("%f,%f" % [point.x, point.y]);
		var opacity := "%.6f" % polygon.color.a;
		svg.append("<polygon points=\"%s\" fill=\"#%s\" fill-opacity=\"%s\"/>" % [" ".join(polygon_points), polygon.color.to_html(false), opacity]);

	svg.append("</svg>");
	var file := FileAccess.open(path, FileAccess.WRITE);
	if file == null:
		return FileAccess.get_open_error();
	file.store_string("\n".join(svg));
	file.close();
	return OK;


func export_svg_to_configured_path() -> void:
	if svg_export_path.is_empty():
		push_error("Set an SVG export path before exporting.");
		return;
	var error := export_svg(svg_export_path);
	if error != OK:
		push_error("Unable to export SVG: %s" % error_string(error));


func remove_point(index: int) -> void:
	for edge_index in range(edges.size() - 1, -1, -1):
		var edge := edges[edge_index];
		if edge.a == index or edge.b == index:
			edges.remove_at(edge_index);

	for polygon_index in range(polygons.size() - 1, -1, -1):
		if index in polygons[polygon_index].points:
			polygons.remove_at(polygon_index);

	for edge in edges:
		if edge.a > index:
			edge.a -= 1;
		if edge.b > index:
			edge.b -= 1;

	for polygon in polygons:
		for point_index in range(polygon.points.size()):
			if polygon.points[point_index] > index:
				polygon.points[point_index] -= 1;

	points.remove_at(index);
