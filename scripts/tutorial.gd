extends Node2D

@onready var instruction: Node2D = $Instruction
@onready var wasd: Node2D = $Instruction/Sprites/WASD
@onready var space_sprite: Sprite2D = $Instruction/Sprites/SpaceSprite
@onready var trap_sprite: Sprite2D = $Instruction/Sprites/TrapSprite
@onready var q_sprite: Sprite2D = $Instruction/Sprites/SpriteQ
@onready var leave: Node2D = $Instruction/Sprites/Leave

@onready var instruction_label: Label = $Instruction/Label
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var w_duration: float = 0
var a_duration: float = 0
var s_duration: float = 0
var d_duration: float = 0

var dash_number: int = 0

var stage = 0
# 0 wasd
# 1 dash
# 2 watch out for trap
# 3 enemies

var camera: Camera2D
var player: Player
var map: Map

var input_threshold = .5

func _ready() -> void:
    StateManager.can_open_map = false
    player = get_tree().get_first_node_in_group("Player")
    map = get_tree().get_first_node_in_group("Map")
    camera = get_tree().get_first_node_in_group("Camera")

    player.hp = 99999

    camera.limit_bottom = 180 + 16

    wasd.visible = false
    space_sprite.visible = false
    trap_sprite.visible = false
    q_sprite.visible = false
    leave.visible = false

    MapManager.map_updated.connect(_on_map_update)
    MapManager.player_map_initial[6][20] = 2
    MapManager.player_map[6][20] = 2
    MapManager.update_player_map(Vector2i(20, 6), 2)
    map.draw_cell_on_coords(Vector2i(20, 6), 2)

    _update_instructions()

func _physics_process(delta: float) -> void:
    instruction.modulate.a = lerp(
        instruction.modulate.a,
        .2 if StateManager.is_menu_open or StateManager.is_menu_open else 1.0,
        .05
    )
    # WASD
    if stage == 0:
        if Input.is_action_pressed("move_up"):
            w_duration += delta
            _shake_object($Instruction/Sprites/WASD/SpriteW)
        if Input.is_action_pressed("move_left"):
            a_duration += delta
            _shake_object($Instruction/Sprites/WASD/SpriteA)
        if Input.is_action_pressed("move_down"):
            s_duration += delta
            _shake_object($Instruction/Sprites/WASD/SpriteS)
        if Input.is_action_pressed("move_right"):
            d_duration += delta
            _shake_object($Instruction/Sprites/WASD/SpriteD)

        if w_duration > input_threshold and a_duration > input_threshold and s_duration > input_threshold and d_duration > input_threshold:
            stage = 1
            _update_instructions()
    # DASH
    elif stage == 1:
        if Input.is_action_just_pressed("dash") and player.dash_cooldown <= 0:
            dash_number += 1

        if player.dash_duration > 0:
            _shake_object(space_sprite)

        if dash_number > 2:
            stage = 2
            _update_instructions()
    # Trigger trap
    elif stage == 2:
        if BulletTimeManager.bullet_timer > 0:
            stage = 3
            _update_instructions()
    # Mark trap
    elif stage == 3:
        if Input.is_action_pressed("toggle_map"):
            _shake_object(q_sprite)
    if stage > 1 and stage < 5:
        instruction.position.x = max(camera.position.x - 100, camera.limit_left + 100)
    elif stage == 5:
        instruction.position.x = max(camera.position.x - 100, camera.limit_left + 100)
        instruction.position.y = max(camera.position.y, camera.limit_top + 100)
    elif stage == 8:
        instruction.position.x = min(camera.position.x + 100, camera.limit_right - 100)
        instruction.position.y = clampf(camera.position.y, camera.limit_top + 100, camera.limit_bottom - 100)

func _update_instructions():
    # WASD
    if stage == 0:
        wasd.visible = true
        instruction_label.text = "Use WASD to move around."
    # DASH
    elif stage == 1:
        wasd.visible = false
        space_sprite.visible = true
        instruction_label.text = "Use SPACE to dash."
    # Trigger trap
    elif stage == 2:
        _remove_first_area()
        space_sprite.visible = false
        trap_sprite.visible = true
        instruction_label.text = "Think fast. Dungeons are full of traps."
    # Mark trap
    elif stage == 3:
        trap_sprite.visible = false
        q_sprite.visible = true
        StateManager.can_open_map = true
        instruction_label.text = "Your Job: Mark traps on the map."
    # Proceed to monsters
    elif stage == 4:
        q_sprite.visible = false
        instruction_label.text = "You may proceed. Traps are reset after a while."
    # Monsters
    elif stage == 5:
        instruction_label.text = "Monsters will kill you. Stand still to hide or lead them to traps."
    # Deal with Monsters
    elif stage == 6:
        instruction.visible = false
    # Good luck
    elif stage == 7:
        instruction.visible = true
        instruction.position = Vector2(536, 231)
        instruction_label.text = "That's it! Mark traps and survive.\nGood luck crawler!"
    # Exit Dungeon
    elif stage == 8:
        leave.visible = true
        instruction_label.text = "Once you leave, you can't go back"


func _on_map_update(coords: Vector2i, value: int):
    if coords == Vector2i(19, 6) and value == 2 and stage == 3:
        stage = 4
        var cell = Vector2(-1, -1)
        for i in range(5, 8):
            tile_map_layer.set_cell(Vector2i(21, i), 0, cell)
        _update_instructions()
        

func _remove_first_area():
    var cell = Vector2(-1, -1)
    for i in range(3, 11):
        tile_map_layer.set_cell(Vector2i(11, i), 0, cell)


func _on_third_area_entrance_area_body_entered(body: Node2D) -> void:
    if body is Player and stage == 4:
        stage = 5
        camera.limit_left = 16
        camera.limit_bottom = 360 + 16
        _update_instructions()
        
func _on_third_area_exit_area_body_entered(body: Node2D) -> void:
    if body is Player and stage == 5:
        stage = 6
        _update_instructions()

func _on_fourth_area_entrance_area_body_entered(body: Node2D) -> void:
    if body is Player and stage == 6:
        stage = 7
        _update_instructions()

func _on_fifth_area_entrance_area_body_entered(body: Node2D) -> void:
    if body is Player and stage == 7:
        stage = 8
        _update_instructions()


func _shake_object(node: Node2D):
    node.skew = deg_to_rad(randf_range(-5, 5))
    node.scale = Vector2(randf_range(0.95, 1.1), randf_range(0.95, 1.1))
