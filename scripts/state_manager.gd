extends Node

var is_player_alive := true
var level: int = 0

# Only false on start of tutorial
var can_open_map: bool = true

var is_exited: bool = false
var is_map_open: bool = false
var is_menu_open: bool = false

var player_death_count: int = 0
var total_monster_death_count: int = 0
var recent_monster_death_count: int = 0

var sum_precision: float = 0
var sum_recall: float = 0
var sum_quality: float = 0

var average_precision: float = 0
var average_recall: float = 0
var average_quality: float = 0

var recent_precision: float = 0
var recent_recall: float = 0
var recent_quality: float = 0

var adv_death_unmarked: int = 0
var adv_death_marked: int = 0

func exit_dungeon():
    is_exited = true

    var map = MapData.LEVELS[level]
    var player_map = MapManager.player_map
    var trap_count: int = 0
    var trap_marked_count: int = 0
    var trap_mismarked_count: int = 0

    # map 3 trap
    # player map 2 trap
    for y in range(len(map)):
        for x in range(len(map[y])):
            if map[y][x] == 3:
                trap_count += 1
                if player_map[y][x] == 2:
                    trap_marked_count += 1
            else:
                if player_map[y][x] == 2:
                    trap_mismarked_count += 1

    print("trap_count: ", trap_count)
    print("trap_marked_count: ", trap_marked_count)
    print("trap_mismarked_count: ", trap_mismarked_count)

    var total_actual_positives: float = trap_count
    var tp: float = trap_marked_count
    var fp: float = trap_mismarked_count
    var fn: float = total_actual_positives - tp

    # Trap marker accuracy
    var precision = tp / (tp + fp) if (tp + fp) > 0 else 0.0
    # Number of traps correctly marked
    var recall = tp / (tp + fn) if (tp + fn) > 0 else 0.0

    var quality = (2 * (precision * recall) / (precision + recall)) if precision + recall > 0 else 0.0

    print("precision: ", precision)
    print("recall: ", recall)
    print("quality: ", quality)

    level += 1

    recent_precision = precision
    recent_recall = recall
    recent_quality = quality

    sum_precision += precision
    average_precision = sum_precision / level

    sum_recall += recall
    average_recall = sum_recall / level

    sum_quality += quality
    average_quality = sum_quality / level

    var adv_count = randi_range(10, 50) * level
    adv_death_unmarked += floor(adv_count * (1 - average_quality))
    for i in range(level):
        adv_death_marked += [0, 0, 0, 0, 0, 0, 1, 1, 2].pick_random()

    total_monster_death_count += recent_monster_death_count

func get_start_scene_path() -> String:
    if level == 0:
        return "res://scenes/first_start.tscn"
    else:
        return "res://scenes/level_template.tscn"

func get_exit_scene_path() -> String:
    if level < len(MapData.LEVELS):
        return "res://scenes/menu.tscn"
    else:
        # End scene
        return "res://scenes/menu.tscn"
