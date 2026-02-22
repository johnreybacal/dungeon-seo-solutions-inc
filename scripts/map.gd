extends Node2D
class_name Map

enum MapCell {
    Ground, Wall, Trap
}
# Ground = DELETE
# Only trap will be drawn for now

@onready var coordinates_label: Label = $CoordinatesLabel
@onready var left_mouse_hint: Node2D = $Hint/LeftMouse
@onready var right_mouse_hint: Node2D = $Hint/RightMouse
@onready var cursor: Sprite2D = $Cursor
@onready var draw_sfx: AudioStreamPlayer = $DrawSfx

var current_cell: MapCell = MapCell.Ground

var cell_coords = {
    MapCell.Ground: Vector2i(1, 0),
    MapCell.Wall: Vector2i(0, 1),
    MapCell.Trap: Vector2i(1, 1),
}

# var is_mouse_down = false
var is_mouse_left = false
var is_mouse_right = false

var min_y = 2
var max_y = 22
var min_x = 1
var max_x = 40

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

func _ready() -> void:
    MapManager.map_ready.connect(_setup_map)
    # _reset_hint_position()

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
    if not StateManager.is_map_open:
        return
    # https://www.youtube.com/watch?v=U_TGOgp5-pc
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            is_mouse_left = event.pressed
            if is_mouse_left:
                _draw_cell()
            _shake_mouse_hint()
            
        elif event.button_index == MOUSE_BUTTON_RIGHT:
            is_mouse_right = event.pressed
            if is_mouse_right:
                _draw_cell()
            _shake_mouse_hint()


    if event is InputEventMouseMotion:
        var mouse_position := get_local_mouse_position()
        cursor.position = mouse_position
        if is_mouse_left or is_mouse_right:
            _draw_cell()
        var coords := tile_map_layer.local_to_map(mouse_position)
        var x = coords.x # - 1
        var y = coords.y # - 1
        if x > min_x and x < max_x and y > min_y and y < max_y:
            coordinates_label.text = str(coords.x) + ", " + str(coords.y)
            coordinates_label.visible = true
            _shake_mouse_hint()
        else:
            coordinates_label.visible = false
            

func _shake_mouse_hint():
    if is_mouse_left:
        left_mouse_hint.skew = deg_to_rad(randf_range(-5, 5))
        left_mouse_hint.scale = Vector2(randf_range(0.95, 1.05), randf_range(0.95, 1.05))
        cursor.skew = deg_to_rad(randf_range(-5, 5))
        cursor.scale = Vector2(randf_range(0.95, 1.05), randf_range(0.95, 1.05))
        cursor.flip_h = false
        # cursor.flip_v = false
        cursor.offset.y = 0
        return
    else:
        left_mouse_hint.skew = 0
        left_mouse_hint.scale = Vector2.ONE
        cursor.skew = 0
        cursor.scale = Vector2.ONE

    if is_mouse_right:
        right_mouse_hint.skew = deg_to_rad(randf_range(-5, 5))
        right_mouse_hint.scale = Vector2(randf_range(0.95, 1.05), randf_range(0.95, 1.05))
        cursor.skew = deg_to_rad(randf_range(-5, 5))
        cursor.scale = Vector2(randf_range(0.95, 1.05), randf_range(0.95, 1.05))
        cursor.flip_h = true
        # cursor.flip_v = true
        cursor.offset.y = -12
        # cursor.flip_v = true
    else:
        right_mouse_hint.skew = 0
        right_mouse_hint.scale = Vector2.ONE
        cursor.skew = 0
        cursor.scale = Vector2.ONE
        cursor.flip_h = false
        cursor.offset.y = 0
# func _reset_hint_position():
#     ground_hint.position.y = -2 if current_cell == MapCell.Ground else 0
#     wall_hint.position.y = -2 if current_cell == MapCell.Wall else 0
#     trap_hint.position.y = -2 if current_cell == MapCell.Trap else 0


func _draw_cell():
    if not StateManager.is_map_open:
        return
    if is_mouse_left:
        current_cell = MapCell.Trap
    elif is_mouse_right:
        current_cell = MapCell.Ground
    else:
        return

    var coords := tile_map_layer.local_to_map(get_local_mouse_position())
    var x = coords.x
    var y = coords.y

    # don't draw outside
    if x < min_x or x > max_x or y < min_y or y > max_y:
        return

    var cell_data = MapManager.player_map_initial[y][x]
    if cell_data in [1, 2]:
        return
    
    var current_coords := tile_map_layer.get_cell_atlas_coords(coords)
    # same cell coords
    if current_coords == cell_coords[current_cell]:
        return

    draw_sfx.play()
    tile_map_layer.set_cell(coords, 0, cell_coords[current_cell])
    MapManager.update_player_map(Vector2i(x, y), current_cell)

func draw_cell_on_coords(coords, value: int):
    tile_map_layer.set_cell(coords, 0, cell_coords[value])
