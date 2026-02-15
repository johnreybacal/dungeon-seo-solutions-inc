extends CanvasLayer
class_name HUD

var is_shown = false

@onready var animation_player: AnimationPlayer = $MapContainer/AnimationPlayer
@onready var player_coordinates_label: Label = $PlayerCoordinatesLabel
@onready var map_hint_label: Label = $MapHintLabel

func toggle_map():
    is_shown = !is_shown
    map_hint_label.visible = !is_shown
    animation_player.play("show" if is_shown else "hide")
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_shown else Input.MOUSE_MODE_HIDDEN

func hide_hud():
    visible = false
    is_shown = false
    animation_player.play("RESET")

func set_player_coordinates(coords: Vector2i):
    player_coordinates_label.text = str(coords.x) + ", " + str(coords.y)