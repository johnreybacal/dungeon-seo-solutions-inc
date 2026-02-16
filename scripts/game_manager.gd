extends Node2D

@onready var dungeon_tile_map: TileMapLayer = $DungeonTileMap
@onready var map_guide_tile_map: TileMapLayer = $MapGuideTileMap
@onready var player: Player = $Player
@onready var camera: Camera2D = $Camera2D
@onready var hud: HUD = $HUD

var anvil_trap := preload("res://scenes/anvil_trap.tscn")

var traps: Array[Vector2i] = []
var trap_cooldowns: Dictionary[Vector2i, float]
var bullet_timer: float = 0

var audio_pitch_shift: AudioEffectPitchShift

var vertical_points: PackedVector2Array;
var horizontal_points: PackedVector2Array;

func _ready() -> void:
    _draw_dungeon()
    player.triggered.connect(_on_tile_triggered)
    audio_pitch_shift = AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 0)
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

    MapManager.map_updated.connect(_redraw_map_guide)
    _redraw_map_guide()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_map") and bullet_timer <= 0 and not player.is_dying:
        hud.toggle_map()


func _physics_process(delta: float) -> void:
    for key in trap_cooldowns.keys():
        if trap_cooldowns[key] > 0:
            trap_cooldowns[key] -= delta


    if not player.is_dying:
        camera.position = player.position
        var coords := dungeon_tile_map.local_to_map(player.position)
        hud.set_player_coordinates(coords)

    if bullet_timer > 0:
        Engine.time_scale = 0.05
        audio_pitch_shift.pitch_scale = 0.05
        bullet_timer -= delta
        camera.zoom = camera.zoom.move_toward(Vector2(8, 8), delta * 100)
        if bullet_timer <= 0:
            Engine.time_scale = 1
            audio_pitch_shift.pitch_scale = 1
            hud.show()
    else:
        camera.zoom = camera.zoom.move_toward(Vector2(4, 4), delta * 10)

func _draw_dungeon():
    dungeon_tile_map.clear()

    # 0: ground
    # 1: top wall
    # 2: wall
    # 3: healing well?
    # 4 and beyond: traps
    MapManager.generate_map()
    var cells = MapManager.map
    print(cells)
    var top_walls_coordinates: Array[Vector2i] = []
    var wall_coordinates: Array[Vector2i] = []
    var ground_coordinates: Array[Vector2i] = []

    var y: int = 0
    for y_cells in cells:
        var x: int = 0
        for cell in y_cells:
            var coords = Vector2i(x, y)
            ground_coordinates.append(coords)
            # if cell == 0:
            if cell == 1:
                top_walls_coordinates.append(coords)
            if cell == 2:
                wall_coordinates.append(coords)
            if cell > 3:
                traps.append(coords)
                trap_cooldowns[coords] = 0
            x += 1
        y += 1
    
    # Draw ground first
    dungeon_tile_map.set_cells_terrain_connect(ground_coordinates, 0, 1, true)
    # Draw walls
    dungeon_tile_map.set_cells_terrain_connect(wall_coordinates, 0, 2, true)
    # Draw top walls (will fix walls)
    dungeon_tile_map.set_cells_terrain_connect(top_walls_coordinates, 0, 0, true)

    player.position = dungeon_tile_map.map_to_local(Vector2i(1, 1))

    print("traps at: ", traps)

func _redraw_map_guide():
    print("_redraw_map_guide")
    var cells = MapManager.player_map
    var y: int = 0
    for y_cells in cells:
        var x: int = 0
        for cell in y_cells:
            var tile_coords := Vector2i(-1, -1)
            if cell == 1:
                tile_coords = Vector2i(1, 0)
            if cell == 2:
                tile_coords = Vector2i(2, 0)
            if cell == 3:
                tile_coords = Vector2i(0, 0)

            if tile_coords:
                map_guide_tile_map.set_cell(Vector2i(x, y), 0, tile_coords)
            x += 1
        y += 1

func _on_tile_triggered():
    var coords := dungeon_tile_map.local_to_map(player.position)
    var trap_position := dungeon_tile_map.map_to_local(coords)
    if coords in traps:
        print("trap, ", coords)
        if trap_cooldowns[coords] > 0:
            # Retrigger / Trap cooldown
            return
        trap_cooldowns[coords] = 2
        var anvil: AnvilTrap = anvil_trap.instantiate()
        anvil.position = trap_position
        anvil.player_hit.connect(_on_player_hit)
        add_child.call_deferred(anvil)
        bullet_timer = .1
        hud.hide_hud()

func _on_player_hit(source_position: Vector2):
    print("player hit")
    player.die(source_position)
