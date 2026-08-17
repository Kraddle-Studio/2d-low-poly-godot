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
