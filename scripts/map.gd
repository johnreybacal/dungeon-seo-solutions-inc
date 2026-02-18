extends Node2D
class_name Map

enum MapCell {
    Ground, Wall, Trap
}

@onready var coordinates_label: Label = $CoordinatesLabel
@onready var ground_hint: Node2D = $Hint/Ground
@onready var wall_hint: Node2D = $Hint/Wall
@onready var trap_hint: Node2D = $Hint/Trap

var current_cell: MapCell = MapCell.Ground

var cell_coords = {
    MapCell.Ground: Vector2i(1, 0),
    MapCell.Wall: Vector2i(0, 1),
    MapCell.Trap: Vector2i(1, 1),
}

var is_mouse_down = false

var min_y = 2
var max_y = 21
var min_x = 0
var max_x = 40

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

func _ready() -> void:
    MapManager.map_ready.connect(_setup_map)
    _reset_hint_position()

func _setup_map():
    var cells = MapManager.player_map
    var y: int = 0
    for y_cells in cells:
        var x: int = 0
        for cell in y_cells:
            var tile: MapCell
            if cell == 0:
                tile = MapCell.Ground
            if cell == 1 or cell == 2:
                tile = MapCell.Wall
            
            if tile:
                tile_map_layer.set_cell(Vector2i(x, y), 0, cell_coords[tile])
            x += 1
        y += 1

    for i in range(-1, 24):
        tile_map_layer.set_cell(Vector2i(-1, i), 0, Vector2(-1, -1))
        tile_map_layer.set_cell(Vector2i(42, i), 0, Vector2(-1, -1))
    for i in range(-1, 42):
        tile_map_layer.set_cell(Vector2i(i, -1), 0, Vector2(-1, -1))
        tile_map_layer.set_cell(Vector2i(i, 24), 0, Vector2(-1, -1))

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("use_ground"):
        current_cell = MapCell.Ground
        _reset_hint_position()
    if event.is_action_pressed("use_wall"):
        current_cell = MapCell.Wall
        _reset_hint_position()
    if event.is_action_pressed("use_trap"):
        current_cell = MapCell.Trap
        _reset_hint_position()

    # https://www.youtube.com/watch?v=U_TGOgp5-pc
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            is_mouse_down = event.pressed
            if is_mouse_down:
                _draw_cell()

    if event is InputEventMouseMotion:
        if is_mouse_down:
            _draw_cell()
        var coords := tile_map_layer.local_to_map(get_local_mouse_position())
        var x = coords.x # - 1
        var y = coords.y # - 1
        if x >= min_x and x <= max_x and y >= min_y and y <= max_y:
            coordinates_label.text = str(coords.x) + ", " + str(coords.y)
            coordinates_label.visible = true
        else:
            coordinates_label.visible = false

func _reset_hint_position():
    ground_hint.position.y = -2 if current_cell == MapCell.Ground else 0
    wall_hint.position.y = -2 if current_cell == MapCell.Wall else 0
    trap_hint.position.y = -2 if current_cell == MapCell.Trap else 0


func _draw_cell():
    var coords := tile_map_layer.local_to_map(get_local_mouse_position())
    var x = coords.x
    var y = coords.y

    var cell_data = MapManager.map[y][x]
    if cell_data in [1, 2]:
        return
    # don't draw outside
    if x < min_x or x > max_x or y < min_y or y > max_y:
        return
    tile_map_layer.set_cell(coords, 0, cell_coords[current_cell])
    MapManager.update_player_map(Vector2i(x, y), current_cell)
