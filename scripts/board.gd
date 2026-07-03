@tool
extends Node3D

var board_coordinates: Dictionary[String, Vector3] = {}

func _ready() -> void:
    for tile in get_children():
        if tile is Tile:
            tile.clicked.connect(_on_tile_clicked)

    populate_board_coordinates()

func _on_tile_clicked(tile: Tile, coord: String) -> void:
    print("Clicked: ", coord)
    # your game logic here

func populate_board_coordinates() -> void:
    var start_x := -0.87
    var start_y := 0.28
    var start_z := 0.878
    var step := 0.25

    var letters := ["a", "b", "c", "d", "e", "f", "g", "h"]

    var z := start_z
    for row in range(letters.size()): # a, b, c, ... h
        var x := start_x
        for col in range(1, 9): # 1 to 8
            var coord := "%s%d" % [letters[row], col]
            board_coordinates[coord] = Vector3(x, start_y, z)
            x += step
        z -= step

    print(board_coordinates["b3"])
