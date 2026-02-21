extends Node2D

@export var level: int
@onready var dungeon_tile_map: TileMapLayer = $DungeonTileMap
@onready var map_guide_tile_map: TileMapLayer = $MapGuideTileMap
@onready var camera: Camera2D = $Camera2D
@onready var hud: HUD = $HUD
@onready var y_sortable: Node2D = $YSortable
@onready var player: Player = $YSortable/Player

var enemy_scene = preload("res://scenes/enemy.tscn")
var anvil_trap_scene := preload("res://scenes/anvil_trap.tscn")

var traps: Array[Vector2i] = []
var trap_cooldowns: Dictionary[Vector2i, float]

func _ready() -> void:
    MapManager.map_ready.connect(_draw_dungeon)
    MapManager.map_updated.connect(_update_map_guide)
    MapManager.generate_map(level)

    player.triggered.connect(_on_tile_triggered)
    
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

    BulletTimeManager.on_bullet_time_end.connect(hud.show)

func _physics_process(delta: float) -> void:
    for key in trap_cooldowns.keys():
        if trap_cooldowns[key] > 0:
            trap_cooldowns[key] -= delta


    if not player.is_dying:
        camera.position = player.position
        var coords := dungeon_tile_map.local_to_map(player.position)
        hud.set_player_coordinates(coords)

    if BulletTimeManager.is_bullet_time():
        camera.zoom = camera.zoom.move_toward(Vector2(8, 8), delta * 100)
    else:
        camera.zoom = camera.zoom.move_toward(Vector2(4, 4), delta * 10)

func _draw_dungeon():
    dungeon_tile_map.clear()
    # 0 ground
    # 1 wall
    # 2 top wall
    # 3 trap - anvil
    # 8 enemy
    # 9 player
    var cells = MapManager.map
    var top_walls_coordinates: Array[Vector2i] = []
    var wall_coordinates: Array[Vector2i] = []
    var ground_coordinates: Array[Vector2i] = []
    # var ground_redraw_coordinates: Array[Vector2i] = []

    var y: int = 0
    for y_cells in cells:
        var x: int = 0
        for cell in y_cells:
            var coords = Vector2i(x, y)
            ground_coordinates.append(coords)
            if cell == 1:
                top_walls_coordinates.append(coords)
            if cell == 2:
                wall_coordinates.append(coords)
            if cell == 3:
                traps.append(coords)
                trap_cooldowns[coords] = 0
            x += 1
        y += 1
    
    # Draw ground first
    dungeon_tile_map.set_cells_terrain_connect(ground_coordinates, 0, 1, true)
    # Draw walls
    # Draw top walls (will fix walls)
    dungeon_tile_map.set_cells_terrain_connect(wall_coordinates, 0, 2, true)
    dungeon_tile_map.set_cells_terrain_connect(top_walls_coordinates, 0, 0, true)
    # Redraw for correct rendering
    dungeon_tile_map.set_cells_terrain_connect(wall_coordinates, 0, 2, true)
    # dungeon_tile_map.set_cells_terrain_path(ground_redraw_coordinates, 0, 1, true)
    # dungeon_tile_map.set_cells_terrain_connect(top_walls_coordinates, 0, 0, true)
    # dungeon_tile_map.set_cells_terrain_connect(wall_coordinates, 0, 2, true)

    # redraw ground to correct terrain
    # dungeon_tile_map.set_cells_terrain_path(ground_redraw_coordinates, 0, 1, true)

    player.position = dungeon_tile_map.map_to_local(MapManager.player_position)
    for enemy_position in MapManager.enemy_positions:
        var enemy: Enemy = enemy_scene.instantiate()
        enemy.position = dungeon_tile_map.map_to_local(enemy_position)
        y_sortable.add_child.call_deferred(enemy)

    print("traps at: ", traps)

func _update_map_guide(coords: Vector2i, value: int):
    var tile_coords := Vector2i(-1, -1)
    if value == 2:
        tile_coords = Vector2i(2, 0)
    if value == 1 and MapManager.player_map_initial[coords.y][coords.x] != 1:
        tile_coords = Vector2i(1, 0)
    map_guide_tile_map.set_cell(coords, 0, tile_coords)

func _on_tile_triggered():
    var coords := dungeon_tile_map.local_to_map(player.position)
    var trap_position := dungeon_tile_map.map_to_local(coords)
    if coords in traps:
        print("trap, ", coords)
        if trap_cooldowns[coords] > 0:
            # Retrigger / Trap cooldown
            return
        trap_cooldowns[coords] = 2
        var anvil: AnvilTrap = anvil_trap_scene.instantiate()
        anvil.position = trap_position
        anvil.player_hit.connect(_on_player_hit)
        y_sortable.add_child.call_deferred(anvil)
        BulletTimeManager.start_bullet_time()
        hud.hide_hud()

func _on_player_hit(source_position: Vector2):
    player.hit(source_position)