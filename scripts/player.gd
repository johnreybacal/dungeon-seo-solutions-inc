extends CharacterBody2D
class_name Player

var move_speed: float = 100
var is_dying := false
var dying_rotation: float
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal triggered()

func _physics_process(delta: float) -> void:
    if is_dying:
        velocity += get_gravity() * (delta / 2)
        rotate(dying_rotation)
        move_and_slide()
        return

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
    if is_dying:
        return
    triggered.emit()

func die(source_position: Vector2):
    z_index += 10
    var x = randf_range(0, -100 if source_position.x > position.x else 100)
    velocity = Vector2(x, -200)
    dying_rotation = deg_to_rad(-10) if x < 0 else deg_to_rad(10)
    collision_layer = 0
    collision_mask = 0
    is_dying = true
    animation_player.play("RESET")
