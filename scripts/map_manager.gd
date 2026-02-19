extends Node

var map: Array
var player_map: Array
var player_map_initial: Array

var player_position: Vector2i
var enemy_positions: Array[Vector2i]

# 0 ground
# 1 wall
# 2 top wall
# 3 trap - anvil
# 8 enemy
# 9 player

signal map_updated(coords: Vector2i, value: int)
signal map_ready()

func generate_map(level: int):
    enemy_positions = []
    var level_map = MapData.LEVELS[level]
    map = level_map.duplicate_deep()
    player_map = level_map.duplicate_deep()
    player_map_initial = level_map.duplicate_deep()
    for y in range(len(player_map)):
        for x in range(len(player_map[y])):
            var cell = player_map[y][x]
            if cell == 9:
                player_position = Vector2i(x, y)
            if cell == 8:
                enemy_positions.append(Vector2i(x, y))
            elif cell == 2:
                player_map[y][x] = 1
                player_map_initial[y][x] = 1
            elif cell not in [0, 1, 2]:
                player_map[y][x] = 0
                player_map_initial[y][x] = 0

    map_ready.emit()
    # # Walker generator
    # map = template.duplicate_deep()
    # player_map = template.duplicate_deep()
    # for y in range(len(player_map)):
    #     for x in range(len(player_map[y])):
    #         if player_map[y][x] == 2:
    #             player_map[y][x] = 1

    # # Start position is 1, 2
    # var pos := Vector2i(3, 4)

    # var dir := Vector2i.DOWN # [Vector2i.DOWN, Vector2i.RIGHT].pick_random()

    # _generate_room_down(pos, dir)
    # _generate_traps()
    

func _generate_room_down(pos: Vector2i, _dir: Vector2i):
    print("Start at : ", pos, " : ", map[pos.y][pos.x])
    print(map[pos.y][pos.x])
    var up := _check_up(pos)
    var down := _check_down(pos)
    var left := _check_left(pos)
    var right := _check_right(pos)

    print("up: ", up)
    print("down: ", down)
    print("left: ", left)
    print("right: ", right)

    var door_position = randi_range(left + 1, right - 1)

    # Draw wall top
    for y in range(up - 1, down + 2):
        for x in range(left - 1, right + 2):
            var py = pos.y + y
            var px = pos.x + x
            # Up wall
            if y == up - 1:
                map[py][px] = 1
            # Down wall
            if y == down or y == down + 1:
                map[py][px] = 1
            # Left wall
            if x == left or x == left - 1:
                map[py][px] = 1

            if x == right or x == right + 1:
                map[py][px] = 1

            if x == door_position and (y == down or y == down + 1):
                map[py][px] = 0

    # Draw wall
    for x in range(left, right + 2):
        if map[pos.y + down + 2][pos.x + x] == 0 and x != door_position:
            map[pos.y + down + 2][pos.x + x] = 2
    

func _generate_traps():
    var limit = 20
    var current = 0

    while current < limit:
        var y = randi_range(5, 20)
        var x = randf_range(4, 40)

        if map[y][x] == 0:
            map[y][x] = 4
            current += 1
            
func _check_up(pos: Vector2i) -> int:
    print("check up:")
    var max_step = randi_range(-5, -10)
    for i in range(0, max_step, -1):
        print(map[pos.y - i][pos.x])
        if map[pos.y + i][pos.x] != 0:
            return i
    return max_step

func _check_down(pos: Vector2i) -> int:
    print("check down:")
    var max_step = randi_range(5, 10)
    for i in range(max_step):
        print(map[pos.y + i][pos.x])
        if map[pos.y + i][pos.x] != 0:
            return i
    return max_step

func _check_left(pos: Vector2i) -> int:
    print("check left:")
    var max_step = randi_range(-5, -15)
    for i in range(0, max_step, -1):
        # if pos.x - i < 0:
        #     return i - 1
        print(map[pos.y][pos.x - i])
        if map[pos.y][pos.x + i] != 0:
            return i
    return max_step

func _check_right(pos: Vector2i) -> int:
    print("check left:")
    var max_step = randi_range(5, 15)
    for i in range(max_step):
        print(map[pos.y][pos.x + i])
        if map[pos.y][pos.x + i] != 0:
            return i
    return max_step

func update_player_map(coords: Vector2i, value: int):
    player_map[coords.y][coords.x] = value
    map_updated.emit(coords, value)
