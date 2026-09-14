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
