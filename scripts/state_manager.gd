extends Node

var is_player_alive := true
var level: int = 0

# Only false on start of tutorial
var can_open_map: bool = true

var is_map_open: bool = false
var is_menu_open: bool = false

var is_sfx_muted: bool = false
var is_bgm_muted: bool = false