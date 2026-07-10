extends Node

var selected_piece: PlayerPiece = null
var board = null

func select_piece(piece: PlayerPiece):
  selected_piece = piece