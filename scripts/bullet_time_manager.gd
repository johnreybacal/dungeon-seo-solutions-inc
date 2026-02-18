extends Node

var audio_pitch_shift: AudioEffectPitchShift
var bullet_timer: float = 0
var is_player_alive := true

signal on_bullet_time_end()

func _ready() -> void:
    audio_pitch_shift = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 0)
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
    if bullet_timer > 0:
        bullet_timer -= delta
        if bullet_timer <= 0:
            Engine.time_scale = 1
            audio_pitch_shift.pitch_scale = 1
            on_bullet_time_end.emit()

func start_bullet_time():
    if is_player_alive:
        bullet_timer = 0.075
        Engine.time_scale = 0.075
        audio_pitch_shift.pitch_scale = 0.5

func stop_bullet_time(p_is_player_alive = true):
    bullet_timer = 0
    Engine.time_scale = 1
    audio_pitch_shift.pitch_scale = 1
    is_player_alive = p_is_player_alive

func is_bullet_time():
    return bullet_timer > 0