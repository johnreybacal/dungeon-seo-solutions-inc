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

@onready var analytics: GridContainer = $MarginContainer/VBoxContainer/HBoxContainer/Analytics

func _ready() -> void:
    $SceneTransition.visible = true
    _refresh_menu()

    if StateManager.level > 0:
        _add_stat_row("", "Statistics")
        _add_stat_row("Dungeons Indexed:", StateManager.level)
        _add_stat_row("Average Reliability:", str(snappedf(StateManager.average_precision * 100, 2)) + "%")
        _add_stat_row("Average Completeness:", str(snappedf(StateManager.average_recall * 100, 2)) + "%")
        _add_stat_row("Average Quality:", str(snappedf(StateManager.average_quality * 100, 2)) + "%")


        if StateManager.player_death_count > 0:
            _add_stat_row("Crawler Casualty: ", StateManager.player_death_count)
        if StateManager.total_monster_death_count > 0:
            _add_stat_row("Monster Casualty: ", StateManager.total_monster_death_count)
        if StateManager.adv_death_unmarked > 0:
            _add_stat_row("Adventurers died\non Unmarked Traps: ", StateManager.adv_death_unmarked)
        if StateManager.adv_death_marked > 0:
            _add_stat_row("Adventurers died on\nMarked Traps (on purpose): ", StateManager.adv_death_marked)


func _add_stat_row(label: String, value: Variant):
    var l = Label.new()
    l.text = label
    l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    l.add_theme_font_size_override("font_size", 32)
    analytics.add_child.call_deferred(l)
    var v = Label.new()
    v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    v.add_theme_font_size_override("font_size", 32)
    v.text = str(value)
    analytics.add_child.call_deferred(v)

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
    var start_scene := StateManager.get_start_scene_path()
    transition.play("fade_in")
    await transition.animation_finished
    get_tree().change_scene_to_file(start_scene)

    
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
