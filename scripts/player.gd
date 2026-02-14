extends CharacterBody2D

var move_speed = 100

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer

func _physics_process(delta: float) -> void:
    var move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    velocity = move_vector.normalized() * move_speed

    if move_vector.x > 0:
        sprite_2d.flip_h = false
    elif move_vector.x < 0:
        sprite_2d.flip_h = true

    if move_vector != Vector2.ZERO:
        animation_player.play("walk")
    else:
        animation_player.play("RESET")

    move_and_slide()