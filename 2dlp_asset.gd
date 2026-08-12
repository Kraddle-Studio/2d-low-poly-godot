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
