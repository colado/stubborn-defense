@tool
extends Node3D

const TILE = preload("res://assets/iron-tile025.glb")

func _ready():
	for child in get_children():
		child.queue_free()
	for row in 8:
		for col in 8:
			var tile = TILE.instantiate()
			tile.position = Vector3(col, 0.3, row)
			add_child(tile)
