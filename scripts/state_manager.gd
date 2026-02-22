extends Node

var is_player_alive := true
var level: int = 0

# Only false on start of tutorial
var can_open_map: bool = true

var is_map_open: bool = false
var is_menu_open: bool = false

func get_start_scene_path() -> String:
    if level == 0:
        return "res://scenes/first_start.tscn"
    else:
        return "res://scenes/level_template.tscn"

func get_exit_scene_path() -> String:
    if level < len(MapData.LEVELS):
        level += 1
        return "res://scenes/menu.tscn"
    else:
        # End scene
        return "res://scenes/menu.tscn"