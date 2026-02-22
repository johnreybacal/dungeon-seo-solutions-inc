extends Control

@onready var statistics: GridContainer = $ColorRect/MarginContainer/VBoxContainer/Statistics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var micro5_font := preload("res://assets/fonts/Micro5-Regular.ttf")

func _ready():
    _add_stat_row("Average Reliability:", str(snappedf(StateManager.average_precision * 100, 2)) + "%")
    _add_stat_row("Average Completeness:", str(snappedf(StateManager.average_recall * 100, 2)) + "%")
    _add_stat_row("Average Quality:", str(snappedf(StateManager.average_quality * 100, 2)) + "%")
    _add_stat_row("Crawler Casualty: ", StateManager.player_death_count)
    _add_stat_row("Monster Casualty: ", StateManager.total_monster_death_count)
    _add_stat_row("Adventurer Trap Casualty: ", str(StateManager.adv_death_unmarked) + " out of " + str(StateManager.adv + StateManager.adv_death_marked))
    _add_stat_row("Adventurer Trap Casualty\n(on purpose): ", StateManager.adv_death_marked)


func _add_stat_row(label: String, value: Variant):
    var container = VBoxContainer.new()
    var l = Label.new()
    l.text = label
    # l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    l.add_theme_font_size_override("font_size", 32)
    # l.add_theme_font_override("font", micro5_font)
    var v = Label.new()
    # v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    v.add_theme_font_size_override("font_size", 48)
    v.add_theme_font_override("font", micro5_font)
    v.text = str(value)

    container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    container.add_child(l)
    container.add_child(v)
    statistics.add_child.call_deferred(container)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("dash"):
        _transition_to_menu()

func _transition_to_menu():
    StateManager.reset()
    animation_player.play("fade_out")
    await animation_player.animation_finished
    get_tree().change_scene_to_file("res://scenes/menu.tscn")
