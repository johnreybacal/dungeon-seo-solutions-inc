extends Control

enum MenuState {
    Initial, Settings, Starting
}

var state := MenuState.Initial

@onready var initial: VBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer/Actions/Initial
@onready var settings: VBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer/Actions/Settings

@onready var bgm_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Actions/Settings/BGM
@onready var sfx_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Actions/Settings/SFX

@onready var transition: AnimationPlayer = $SceneTransition/AnimationPlayer

func _ready() -> void:
    $SceneTransition.visible = true
    _refresh_menu()

func _input(event):
    if state == MenuState.Initial:
        if event.is_action_pressed("menu_start"):
            state = MenuState.Starting
            _start()
            return
            
        if event.is_action_pressed("menu_settings"):
            state = MenuState.Settings
            _refresh_menu()
            return
    elif state == MenuState.Settings:
        if event.is_action_pressed("toggle_mute_bgm"):
            _toggle_bgm()
        if event.is_action_pressed("toggle_mute_sfx"):
            _toggle_sfx()
        if event.is_action_pressed("toggle_fullscreen"):
            _toggle_fullscreen()
        if event.is_action_pressed("menu_settings_back"):
            state = MenuState.Initial
            _refresh_menu()
            return

func _start():
    transition.play("fade_in")
    await transition.animation_finished
    get_tree().change_scene_to_file("res://scenes/level_template.tscn")

    
func _refresh_menu():
    initial.visible = state == MenuState.Initial
    settings.visible = state == MenuState.Settings

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