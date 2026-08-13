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


class Edge extends Resource:
	@export var a: int;
	@export var b: int;

	func equals(other: Edge) -> bool:
		return a == other.a and b == other.b;


class Polygon extends Resource:
	@export var points: Array[int];
	@export var color: Color;

	func equals(other: Polygon) -> bool:
		return points == other.points;


@export var edges: Array[Edge];
@export var polygons: Array[Polygon];


func try_append_edge(a: int, b: int) -> bool:
	var new_edge := Edge.new();
	new_edge.a = a;
	new_edge.b = b;
	
	for edge in edges:
		if edge == new_edge:
			return false;
	
	edges.append(new_edge);
	return true;


func try_append_polygon(points: Array[int], color: Color) -> bool:
	var new_polygon := Polygon.new();
	new_polygon.points = points.duplicate();
	new_polygon.color = color;
	
	for polygon in polygons:
		if polygon == new_polygon:
			return false;
	
	polygons.append(new_polygon);
	return true;
