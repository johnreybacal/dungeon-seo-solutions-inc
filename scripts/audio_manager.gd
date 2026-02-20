extends Node

var bgm_pitch_shift: AudioEffectPitchShift
var sfx_pitch_shift: AudioEffectPitchShift

var bgm_bus: int = AudioServer.get_bus_index("BGM")
var sfx_bus: int = AudioServer.get_bus_index("SFX")
var sfx_slowable_bus: int = AudioServer.get_bus_index("SFX Slowable")

var is_bgm_muted = false
var is_sfx_muted = false

var bgm_streams: Array[AudioStream] = [
    preload("res://assets/bgm/Troubadeck 26 Sorcerer's Spell.ogg"),
    preload("res://assets/bgm/Troubadeck 30 Bandit's Ballad.ogg"),
    preload("res://assets/bgm/Troubadeck 41 Firecat.ogg")
]
var current_bgm_stream: AudioStream

var bgm: AudioStreamPlayer

var target_pitch_scale: float = 1
var current_pitch_scale: float = 1

func _ready() -> void:
    sfx_pitch_shift = AudioServer.get_bus_effect(sfx_slowable_bus, 0)
    bgm_pitch_shift = AudioServer.get_bus_effect(bgm_bus, 0)
    bgm = AudioStreamPlayer.new()
    _setup_bgm.call_deferred()

func _process(_delta: float) -> void:
    current_pitch_scale = lerp(current_pitch_scale, target_pitch_scale, .05)
    sfx_pitch_shift.pitch_scale = current_pitch_scale
    bgm_pitch_shift.pitch_scale = current_pitch_scale
    

func set_pitch_scale(pitch_scale: float):
    target_pitch_scale = pitch_scale

    
func toggle_bgm():
    is_bgm_muted = not is_bgm_muted
    AudioServer.set_bus_mute(bgm_bus, is_bgm_muted)

func toggle_sfx():
    is_sfx_muted = not is_sfx_muted
    AudioServer.set_bus_mute(sfx_bus, is_sfx_muted)
    AudioServer.set_bus_mute(sfx_slowable_bus, is_sfx_muted)

func _setup_bgm():
    bgm.finished.connect(_play_bgm)
    bgm.bus = "BGM"
    bgm.pitch_scale = 2
    bgm.volume_db = -5
    add_child(bgm)
    _play_bgm()

func _play_bgm():
    var available_streams: Array[AudioStream] = bgm_streams.duplicate()
    if current_bgm_stream:
        available_streams = available_streams.filter(func(x: AudioStream): return x != current_bgm_stream)

    current_bgm_stream = available_streams.pick_random()
    bgm.stream = current_bgm_stream
    bgm.play()
