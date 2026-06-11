extends Node3D

func _ready():
	var board = $"board-frame"
	# Find the first MeshInstance3D anywhere in the children
	var mesh = board.find_child("*", true, false) 
	for child in board.find_children("*", "MeshInstance3D", true, false):
		print("Found mesh: ", child.name)
		print("Size: ", child.get_aabb().size)
