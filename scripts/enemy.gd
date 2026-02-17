extends CharacterBody2D
class_name Enemy

@export var vision_renderer: Polygon2D
@export var alert_color: Color
@onready var vision_cone: Node2D = $VisionCone
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE
@onready var original_position = position
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var move_speed: float = 50
var return_timer = 0
var retarget_timer = .25
var target: Node2D
var target_in_sight: bool

var patrol_rotation = deg_to_rad(30)

func _ready() -> void:
    vision_cone.rotation = deg_to_rad(randi_range(0, 360))
    patrol_rotation *= 1 if randi_range(0, 1) == 1 else -1

    # https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_2d.html
    # These values need to be adjusted for the actor's speed
    # and the navigation layout.
    navigation_agent.path_desired_distance = 4.0
    navigation_agent.target_desired_distance = 4.0

    # Make sure to not await during _ready.
    actor_setup.call_deferred()

func actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame

    # Now that the navigation map is no longer empty, set the movement target.
    set_movement_target(original_position)

func set_movement_target(movement_target: Vector2):
    navigation_agent.target_position = movement_target

func _physics_process(delta: float) -> void:
    if target_in_sight:
        vision_cone.look_at(target.position)
        if retarget_timer > 0:
            retarget_timer -= delta
            if retarget_timer <= 0:
                retarget_timer = .25
                set_movement_target(target.position)
    else:
        if return_timer > 0:
            return_timer -= delta
            vision_cone.look_at(target.position)
            if return_timer <= 0:
                target = null
                set_movement_target(original_position)
        else:
            vision_cone.rotate(patrol_rotation * delta)

    if navigation_agent.is_navigation_finished():
        animation_player.play("RESET")
        return

    var next_path_position: Vector2 = navigation_agent.get_next_path_position()

    velocity = global_position.direction_to(next_path_position) * move_speed
    animation_player.play("walk")
    
    move_and_slide()

func _on_vision_cone_area_body_entered(body: Node2D) -> void:
    if body is Player:
        target = body
        target_in_sight = true
        body.add_chaser(self )
        set_movement_target(body.position)
        vision_renderer.color = alert_color

func _on_vision_cone_area_body_exited(body: Node2D) -> void:
    if body is Player:
        set_movement_target(body.position)
        body.remove_chaser(self )
        target_in_sight = false
        return_timer = 3
        vision_renderer.color = original_color
