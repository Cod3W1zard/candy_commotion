extends CharacterBody2D

@export var tile_map_layer: TileMapLayer
@export var target: Node2D
@export var speed: float = 60.0
@export var repath_interval: float = 0.4
@export var empty_cells_block: bool = true
@export var allow_diagonals: bool = false

const CUSTOM_LAYER_NAME := "collidable"

var astar := AStarGrid2D.new()
var path: Array[Vector2] = []
var repath_timer: float = 0.0


func _ready() -> void:
	_build_grid()


func _physics_process(delta: float) -> void:
	if target == null:
		return

	repath_timer -= delta
	if repath_timer <= 0.0:
		repath_timer = repath_interval
		_update_path()

	_follow_path()


func _build_grid() -> void:
	var rect: Rect2i = tile_map_layer.get_used_rect()

	astar.region = rect
	astar.cell_size = Vector2(tile_map_layer.tile_set.tile_size)
	astar.diagonal_mode = (
		AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES if allow_diagonals
		else AStarGrid2D.DIAGONAL_MODE_NEVER
	)
	astar.update()

	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var cell := Vector2i(x, y)
			if _is_cell_blocked(cell):
				astar.set_point_solid(cell, true)


func _is_cell_blocked(cell: Vector2i) -> bool:
	var data: TileData = tile_map_layer.get_cell_tile_data(cell)
	if data == null:
		return empty_cells_block
	return data.get_custom_data(CUSTOM_LAYER_NAME) == true


func refresh_cell(cell: Vector2i) -> void:
	if astar.is_in_boundsv(cell):
		astar.set_point_solid(cell, _is_cell_blocked(cell))


func _update_path() -> void:
	var start_cell: Vector2i = tile_map_layer.local_to_map(
	tile_map_layer.to_local(global_position))
	var end_cell: Vector2i = tile_map_layer.local_to_map(
	tile_map_layer.to_local(target.global_position))

	if not astar.is_in_boundsv(start_cell) or not astar.is_in_boundsv(end_cell):
		path.clear()
		return

	var id_path: Array[Vector2i] = astar.get_id_path(start_cell, end_cell)

	path.clear()
	for cell in id_path:
		path.append(tile_map_layer.to_global(tile_map_layer.map_to_local(cell)))

	if path.size() > 0:
		path.remove_at(0)


func _follow_path() -> void:
	if path.is_empty():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var next_point: Vector2 = path[0]

	if global_position.distance_to(next_point) < 2.0:
		path.remove_at(0)
		return

	velocity = global_position.direction_to(next_point) * speed
	move_and_slide()
