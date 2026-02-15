extends Area2D
class_name AnvilTrap

signal player_hit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "fall":
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        player_hit.emit()
