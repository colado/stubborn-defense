extends Node3D

func _ready():
	var mesh = $Cube
	print("Size from glb: ", mesh.get_aabb().size)
