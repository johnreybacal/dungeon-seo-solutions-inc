extends CharacterBody2D
class_name Player

var move_speed = 100

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer

signal triggered()

func _physics_process(_delta: float) -> void:
    _handle_input()
    _handle_animation()

func _handle_input():
    var move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    velocity = move_vector.normalized() * move_speed

    move_and_slide()

func _handle_animation():
    if velocity.x > 0:
        sprite_2d.flip_h = false
    elif velocity.x < 0:
        sprite_2d.flip_h = true

    if velocity == Vector2.ZERO:
        animation_player.play("RESET")
    else:
        animation_player.play("walk")

func _on_trigger_area_body_entered(_body: Node2D) -> void:
    triggered.emit()
