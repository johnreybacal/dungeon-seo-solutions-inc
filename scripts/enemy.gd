extends CharacterBody2D
class_name Enemy

@export var vision_renderer: Polygon2D
@export var alert_color: Color
@onready var vision_cone: Node2D = $VisionCone
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE
@onready var original_position = position
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

@onready var weapon: Node2D = $Sprite2D/Weapon
@onready var weapon_sprite: Sprite2D = $Sprite2D/Weapon/Sprite2D
@onready var weapon_animation_player: AnimationPlayer = $Sprite2D/Weapon/Sprite2D/AnimationPlayer

@onready var hit_sfx: AudioStreamPlayer = $SFX/Hit
@onready var swing_sfx: AudioStreamPlayer = $SFX/Swing

var move_speed: float = 100

var return_timer = 0
var retarget_timer = .25
var target: Node2D
var target_in_sight: bool = false
var target_in_range: bool = false

var attack_cooldown: float
var attack_duration: float
var attack_direction: int

var patrol_rotation = deg_to_rad(30)

var is_dying := false
var dying_rotation: float

var rad_360 = deg_to_rad(360)


func _ready() -> void:
    vision_cone.rotation = deg_to_rad(randi_range(0, 360))
    patrol_rotation *= 1 if randi_range(0, 1) == 1 else -1
    _set_attack_area_collider_disabled(true)
    _set_attack_hit_area_collider_disabled.call_deferred(true)

    # Make sure to not await during _ready.
    actor_setup.call_deferred()

func actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame

    # Now that the navigation map is no longer empty, set the movement target.
    set_movement_target(original_position)

func set_movement_target(movement_target: Vector2):
    if movement_target == original_position:
        navigation_agent.target_desired_distance = 2
    else:
        navigation_agent.target_desired_distance = 10
    navigation_agent.target_position = movement_target

func _physics_process(delta: float) -> void:
    # Dying
    if is_dying:
        velocity += get_gravity() * (delta / 2)
        rotate(dying_rotation * delta)
        move_and_slide()
        if position.y > 500:
            queue_free()
        return

    if attack_duration > 0:
        # Is attacking
        weapon.rotate(rad_360 * delta * attack_direction * 5)
        attack_duration -= delta
        if attack_duration <= 0:
            _set_attack_hit_area_collider_disabled.call_deferred(true)
    else:
        weapon.rotation = vision_cone.rotation + rad_360

    if attack_cooldown > 0:
        # Attack cooldown
        attack_cooldown -= delta
    elif target_in_range:
        # Can attack
        _set_attack_hit_area_collider_disabled.call_deferred(false)
        attack_direction = 1 if position.x < target.position.x else -1
        attack_duration = .2
        attack_cooldown = 1
        BulletTimeManager.start_bullet_time()
        swing_sfx.play()

    if target_in_sight:
        # Look at player
        vision_cone.look_at(target.position)
        if retarget_timer > 0:
            # Update navigation
            retarget_timer -= delta
            if retarget_timer <= 0:
                retarget_timer = .1
                set_movement_target(target.position)
    else:
        # Lost sight of target
        if return_timer > 0:
            return_timer -= delta
            # Keep looking at target
            vision_cone.look_at(target.position)
            if return_timer <= 0:
                weapon.rotation = 0
                target = null
                # Go back to original position
                set_movement_target(original_position)
        elif position.distance_to(original_position) < 5:
            # patrol vision cone
            vision_cone.rotate(patrol_rotation * delta)
        else:
            # going back to original position, look where its going
            vision_cone.rotation = lerp(vision_cone.rotation, velocity.angle(), .1)

    if navigation_agent.is_navigation_finished() or attack_duration > 0:
        animation_player.play("RESET")
        return

    var next_path_position: Vector2 = navigation_agent.get_next_path_position()

    var speed = move_speed if target_in_sight else move_speed * .5
    velocity = global_position.direction_to(next_path_position) * speed
    
    animation_player.play("walk")
    
    move_and_slide()

func _on_vision_cone_area_body_entered(body: Node2D) -> void:
    if body is Player:
        target = body
        target_in_sight = true
        body.add_chaser(self )
        set_movement_target(body.position)
        vision_renderer.color = alert_color
        weapon_animation_player.play("draw")
        _set_attack_area_collider_disabled.call_deferred(false)

func _on_vision_cone_area_body_exited(body: Node2D) -> void:
    if body is Player:
        set_movement_target(body.position)
        body.remove_chaser(self )
        target_in_sight = false
        return_timer = 5
        vision_renderer.color = original_color
        weapon_animation_player.play("sheathe")
        attack_duration = 0
        _set_attack_area_collider_disabled.call_deferred(true)


func die(source_position: Vector2):
    vision_cone.queue_free()
    z_index += 10
    var x = randf_range(0, -100 if source_position.x > position.x else 100)
    velocity = Vector2(x, -200)
    dying_rotation = deg_to_rad(-720) if x < 0 else deg_to_rad(720)
    collision_layer = 0
    collision_mask = 0
    is_dying = true
    animation_player.play("RESET")
    _set_attack_area_collider_disabled.call_deferred(true)
    _set_attack_hit_area_collider_disabled.call_deferred(true)

func _on_attack_area_body_entered(body: Node2D) -> void:
    if body is Player:
        target_in_range = true

func _on_attack_area_body_exited(body: Node2D) -> void:
    if body is Player:
        target_in_range = false

func _on_attack_hit_area_body_entered(body: Node2D) -> void:
    if body is Player:
        body.hit(position)
        hit_sfx.play()

func _set_attack_area_collider_disabled(disabled: bool):
    $AttackArea/CollisionShape2D.disabled = disabled

func _set_attack_hit_area_collider_disabled(disabled: bool):
    $Sprite2D/Weapon/Sprite2D/AttackHitArea/CollisionShape2D.disabled = disabled
