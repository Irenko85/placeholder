extends Node3D

@export var player_scene: PackedScene
@onready var players: Node3D = $Players

@onready var player_a: Marker3D = $Spawn/PlayerA
@onready var player_b: Marker3D = $Spawn/PlayerB

func  _ready() -> void:
	for player_data in Game.players:
		var player = player_scene.instantiate()
		players.add_child(player)
		player.setup(player_data)

		if len(players.get_children()) == 1:
			player.global_position = player_a.global_position
		if len(players.get_children()) == 2:
			player.global_position = player_b.global_position
