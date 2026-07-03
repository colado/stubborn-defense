@tool
extends Node3D

# TODO: Add the mapping of tiles to chess coordinates. Measure each tile and simply add the length of the side to the 
# current location of the red king

func _ready() -> void:
    for tile in get_children():
        if tile is Tile:
            tile.clicked.connect(_on_tile_clicked)


func _on_tile_clicked(tile: Tile, coord: String) -> void:
    print("Clicked: ", coord)
    # your game logic here
	
