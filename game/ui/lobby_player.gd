class_name UILobbyPlayer
extends MarginContainer

@onready var player_name: Label = %Name
@onready var ready_texture: TextureRect = %Ready

var player_id: int


func _ready() -> void:
	ready_texture.hide()


func setup(player: Statics.PlayerData) -> void:
	player_id = player.id
	name = str(player_id)
	_update(player)
	Game.player_updated.connect(_on_player_updated)


func _on_player_updated(id: int) -> void:
	if id == player_id:
		_update(Game.get_player(player_id))


func _update(player: Statics.PlayerData):
	_set_player_name(player.name)


func _set_player_name(value: String) -> void:
	player_name.text = value


func set_ready(value: bool) -> void:
	ready_texture.visible = value
