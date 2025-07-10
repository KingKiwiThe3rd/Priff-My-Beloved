@tool
extends TileMap

var source_id: int = 6

var tile_configs: Dictionary = {
	0: Vector2i(2, 2),
	1: Vector2i(3, 1),
	2: Vector2i(0, 1),
	3: Vector2i(3, 0),
	4: Vector2i(2, 1),
	5: Vector2i(1, 2),
	6: Vector2i(0, 0),
	7: Vector2i(3, 3),
	8: Vector2i(1, 1),
	9: Vector2i(2, 0),
	10: Vector2i(0, 2),
	11: Vector2i(2, 3),
	12: Vector2i(1, 0),
	13: Vector2i(1, 3),
	14: Vector2i(0, 3),
	15: Vector2i(3, 2)
}

func _ready() -> void:
	if not Engine.is_editor_hint():
		update_all_tiles()

func update_all_tiles(target_source_id: int = source_id) -> void:
	var layer_count = get_layers_count()
	for layer in range(layer_count):
		var used_cells: Array[Vector2i] = get_used_cells(layer)
		for cell in used_cells:
			if get_cell_source_id(layer, cell) == target_source_id:
				update_tile(layer, cell)

func update_tile(layer: int, cell: Vector2i) -> void:
	var bitmask: int = 0
	if get_cell_source_id(layer, cell + Vector2i(0, -1)) != -1:
		bitmask |= 1
	if get_cell_source_id(layer, cell + Vector2i(1, 0)) != -1:
		bitmask |= 2
	if get_cell_source_id(layer, cell + Vector2i(0, 1)) != -1:
		bitmask |= 4
	if get_cell_source_id(layer, cell + Vector2i(-1, 0)) != -1:
		bitmask |= 8
	var atlas_coords: Vector2i = tile_configs.get(bitmask, Vector2i(0, 0))
	set_cell(layer, cell, source_id, atlas_coords)

func on_tilemap_changed(cell: Vector2i) -> void:
	var layer_count = get_layers_count()
	for layer in range(layer_count):
		update_tile(layer, cell)
		update_tile(layer, cell + Vector2i(0, -1))
		update_tile(layer, cell + Vector2i(1, 0))
		update_tile(layer, cell + Vector2i(0, 1))
		update_tile(layer, cell + Vector2i(-1, 0))
