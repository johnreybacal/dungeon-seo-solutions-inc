extends Node

var bullet_timer: float = 0

signal on_bullet_time_end()

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
    if bullet_timer > 0:
        bullet_timer -= delta
        if bullet_timer <= 0:
            Engine.time_scale = 1
            AudioManager.set_pitch_scale(1)
            on_bullet_time_end.emit()

func start_bullet_time():
    if StateManager.is_player_alive:
        bullet_timer = 0.075
        Engine.time_scale = 0.075
        AudioManager.set_pitch_scale(0.5)

func stop_bullet_time():
    bullet_timer = 0
    Engine.time_scale = 1
    AudioManager.set_pitch_scale(1)

func is_bullet_time():
    return bullet_timer > 0