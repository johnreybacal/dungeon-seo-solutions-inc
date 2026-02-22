extends Control

@onready var label: Label = $ColorRect/Label
@onready var animation_player: AnimationPlayer = $ColorRect/AnimationPlayer


var updating: bool = false

func _ready():
    label.modulate.a = 0

    if StateManager.is_exited:
        label.text = "Dungeon Indexed!\n"
        label.text += "Reliability: " + str(snappedf(StateManager.recent_precision * 100, 2)) + "%\n"
        label.text += "Completeness: " + str(snappedf(StateManager.recent_recall * 100, 2)) + "%\n"
        label.text += "Quality: " + str(snappedf(StateManager.recent_quality * 100, 2)) + "%\n"
        if StateManager.recent_monster_death_count > 0:
            label.text += "Monsters eliminated: " + str(StateManager.recent_monster_death_count) + "\n"
            
    else:
        label.text = ["Hiring new crawlers...", "Job ad posted...", "Interviewing candidates...", "Training replacement..."].pick_random()
    animation_player.play("text_fade_in")

    # _update_stage()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("dash") and not updating:
        _transition_to_menu()

func _transition_to_menu():
    animation_player.play("text_fade_out")
    await animation_player.animation_finished
    get_tree().change_scene_to_file("res://scenes/menu.tscn")