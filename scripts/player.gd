extends CharacterBody2D
class_name Player

var move_speed: float = 100
var is_dying := false
var dying_rotation: float
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var chasers: Array[int]
var vanish_timer = 0
var is_hidden = false

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
        # can only hide when not detected
        if len(chasers) > 0:
            animation_player.play("RESET")
        elif not is_hidden:
            animation_player.play("hide")

    else:
        collision_layer = 7
        is_hidden = false
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


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "hide":
        print("hidden")
        is_hidden = true
        collision_layer = 0

func add_chaser(node: Node2D):
    chasers.append(node.get_instance_id())

func remove_chaser(node: Node2D):
    var instance_id = node.get_instance_id()
    chasers = chasers.filter(func(id: int): return id != instance_id)
