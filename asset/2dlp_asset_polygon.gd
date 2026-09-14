@tool

class_name LowPolyAsset2DPolygon
extends Resource


@export var points: Array[int];
@export var color: Color;

func equals(other: LowPolyAsset2DPolygon) -> bool:
	return points == other.points;