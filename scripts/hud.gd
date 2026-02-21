extends CanvasLayer
class_name HUD

var is_map_shown = false
var is_menu_shown = false

@onready var map_animation_player: AnimationPlayer = $MapContainer/AnimationPlayer
@onready var player_coordinates_label: Label = $PlayerCoordinatesLabel
@onready var map_hint_label: Label = $MapHintLabel

@onready var menu_animation_player: AnimationPlayer = $MenuContainer/AnimationPlayer
@onready var bgm_label: Label = $MenuContainer/SettingsBackdrop/Bgm
@onready var sfx_label: Label = $MenuContainer/SettingsBackdrop/Sfx

@onready var transition: AnimationPlayer = $SceneTransition/AnimationPlayer

func _ready() -> void:
    $SceneTransition.visible = true
    _set_bgm_label()
    _set_sfx_label()

func _input(event: InputEvent) -> void:
    var can_toggle_ui = not BulletTimeManager.is_bullet_time() and StateManager.is_player_alive
    if not can_toggle_ui:
        return
    if event.is_action_pressed("toggle_map") and StateManager.can_open_map:
        _toggle_map()
        if is_menu_shown:
            _toggle_menu()
    if event.is_action_pressed("toggle_menu"):
        _toggle_menu()
        if is_map_shown:
            _toggle_map()

    if is_menu_shown:
        if event.is_action_pressed("exit_dungeon"):
            _toggle_menu()
            _exit_dungeon()
        if event.is_action_pressed("toggle_mute_bgm"):
            _toggle_bgm()
        if event.is_action_pressed("toggle_mute_sfx"):
            _toggle_sfx()
        if event.is_action_pressed("toggle_fullscreen"):
            _toggle_fullscreen()

func _toggle_map():
    is_map_shown = !is_map_shown
    map_hint_label.visible = !is_map_shown
    map_animation_player.play("show" if is_map_shown else "hide")
    StateManager.is_map_open = is_map_shown

func _toggle_menu():
    is_menu_shown = !is_menu_shown
    StateManager.is_menu_open = is_menu_shown
    menu_animation_player.play("show" if is_menu_shown else "hide")

func _toggle_bgm():
    AudioManager.toggle_bgm()
    _set_bgm_label()

func _toggle_fullscreen():
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _set_bgm_label():
    var label = "1: "
    label += "Unmute" if AudioManager.is_bgm_muted else "Mute"
    label += " BGM"
    bgm_label.text = label

func _toggle_sfx():
    AudioManager.toggle_sfx()
    _set_sfx_label()

func _set_sfx_label():
    var label = "2: "
    label += "Unmute" if AudioManager.is_sfx_muted else "Mute"
    label += " SFX"
    sfx_label.text = label

func _exit_dungeon():
    transition.play("fade_in")
    await transition.animation_finished
    get_tree().change_scene_to_file("res://scenes/menu.tscn")


func hide_hud():
    visible = false
    is_map_shown = false
    is_menu_shown = false
    map_animation_player.play("RESET")
    menu_animation_player.play("RESET")

func set_player_coordinates(coords: Vector2i):
    player_coordinates_label.text = str(coords.x) + ", " + str(coords.y)
