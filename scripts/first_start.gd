extends Control

@onready var label: Label = $ColorRect/Label
@onready var animation_player: AnimationPlayer = $ColorRect/AnimationPlayer

var stage: int = 0
var updating: bool = false

func _ready():
    label.modulate.a = 0
    label.text = "Welcome to Dungeon SEO Solutions Inc.\n\nWe exist because the government enforced\nIndexing Dungeons for Trap Safety."
    animation_player.play("text_fade_in")

    # _update_stage()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("dash") and not updating and stage < 3:
        _update_stage()

func _update_stage():
    updating = true
    animation_player.play("text_fade_out")
    await animation_player.animation_finished
    stage += 1
    if stage == 1:
        label.text = "We have two crawler divisions:\n\nFirst, the drones, which flies first\nAnd maps the dungeon floor\n\nThey are not very good at triggering traps\nSince they fly and all."
    elif stage == 2:
        label.text = "Then, the walkers, that includes you\nWho marks the trap location\n\nThey are very good at stepping into traps\nYour job is to mark trap locations\nFor the safety of adventurers."
    elif stage == 3:
        $ColorRect/ContinueLabel.visible = false
        label.text = "Get ready, Dungeon Crawler."

    animation_player.play("text_fade_in")
    await animation_player.animation_finished
    
    updating = false

    if stage == 3:
        _transition_to_tutorial()

func _transition_to_tutorial():
    await get_tree().create_timer(1.0).timeout
    animation_player.play("text_fade_out")
    await animation_player.animation_finished
    get_tree().change_scene_to_file("res://scenes/tutorial.tscn")