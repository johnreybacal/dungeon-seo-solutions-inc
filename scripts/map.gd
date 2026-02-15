extends Node2D
class_name Map

enum MapCell {
    Ground, Wall, Trap, Enemy
}

@onready var coordinates_label: Label = $CoordinatesLabel

var current_cell: MapCell = MapCell.Ground

var cell_coords = {
    MapCell.Ground: Vector2i(1, 0),
    MapCell.Wall: Vector2i(0, 1),
    MapCell.Trap: Vector2i(1, 1),
    MapCell.Enemy: Vector2i(0, 0)
}

var is_mouse_down = false

var y_walls = [-1, 0, 1, 21]
var x_walls = [-1, 0, 41]
var min_y = -1
var max_y = 21
var min_x = -1
var max_x = 41

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

func _ready() -> void:
    for y in range(-1, 22):
        for x in range(-1, 42):
            var coords = Vector2i(x, y)
            
            tile_map_layer.set_cell(coords, 0, cell_coords[MapCell.Ground])

            if x in x_walls or y in y_walls:
                tile_map_layer.set_cell(coords, 0, cell_coords[MapCell.Wall])

            # if cell == 1 or cell == 2:
            #     print("wall")


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("use_ground"):
        current_cell = MapCell.Ground
    if event.is_action_pressed("use_wall"):
        current_cell = MapCell.Wall
    if event.is_action_pressed("use_trap"):
        current_cell = MapCell.Trap
    if event.is_action_pressed("use_enemy"):
        current_cell = MapCell.Enemy

    # https://www.youtube.com/watch?v=U_TGOgp5-pc
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            is_mouse_down = event.pressed
            if is_mouse_down:
                _draw_cell()

    if event is InputEventMouseMotion:
        if is_mouse_down:
            _draw_cell()
        var coords := tile_map_layer.local_to_map(get_local_mouse_position() - tile_map_layer.position)
        var x = coords.x
        var y = coords.y
        if x > min_x and x < max_x and y > min_y and y < max_y:
            coordinates_label.text = str(coords.x) + ":" + str(coords.y)
            coordinates_label.visible = true
        else:
            coordinates_label.visible = false

func _draw_cell():
    var coords := tile_map_layer.local_to_map(get_local_mouse_position() - tile_map_layer.position)
    var x = coords.x
    var y = coords.y
    # don't draw on walls
    if x in x_walls or y in y_walls:
        return
    # don't draw outside
    if x < min_x or x > max_x or y < min_y or y > max_y:
        return
    tile_map_layer.set_cell(coords, 0, cell_coords[current_cell])