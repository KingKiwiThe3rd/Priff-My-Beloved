extends TileMap

# TileSet source ID (adjust based on your TileSet configuration)
var source_id: int = 0

# Atlas coordinates for different tile configurations (modify based on your tileset)
# Using a 4-bit bitmask: 1=North, 2=East, 4=South, 8=West
var tile_configs: Dictionary = {
	0: Vector2i(3, 3),  # No neighbors
	1: Vector2i(3, 1),  # North
	2: Vector2i(0, 1),  # East
	3: Vector2i(3, 0),  # North + East
	4: Vector2i(0, 1),  # South
	5: Vector2i(1, 1),  # North + South
	6: Vector2i(2, 1),  # East + South
	7: Vector2i(3, 1),  # North + East + South
	8: Vector2i(0, 2),  # West
	9: Vector2i(1, 2),  # North + West
	10: Vector2i(2, 2), # East + West
	11: Vector2i(3, 2), # North + East + West
	12: Vector2i(0, 3), # South + West
	13: Vector2i(1, 3), # North + South + West
	14: Vector2i(2, 3), # East + South + West
	15: Vector2i(3, 3)  # All neighbors
}

func _ready() -> void:
	# Update all tiles when the scene loads
	update_all_tiles()

func update_all_tiles() -> void:
	# Get all used cells in layer 0
	var used_cells: Array[Vector2i] = get_used_cells(0)
	for cell in used_cells:
		update_tile(cell)

func update_tile(cell: Vector2i) -> void:
	# Calculate bitmask based on neighboring tiles
	var bitmask: int = 0
	
	# Check North (1)
	if get_cell_source_id(0, cell + Vector2i(0, -1)) != -1:
		bitmask |= 1
	# Check East (2)
	if get_cell_source_id(0, cell + Vector2i(1, 0)) != -1:
		bitmask |= 2
	# Check South (4)
	if get_cell_source_id(0, cell + Vector2i(0, 1)) != -1:
		bitmask |= 4
	# Check West (8)
	if get_cell_source_id(0, cell + Vector2i(-1, 0)) != -1:
		bitmask |= 8
	
	# Get the corresponding atlas coordinates
	var atlas_coords: Vector2i = tile_configs.get(bitmask, Vector2i(0, 0))
	
	# Set the tile
	set_cell(0, cell, source_id, atlas_coords)

# Call this when you modify the tilemap (e.g., place or remove a tile)
func on_tilemap_changed(cell: Vector2i) -> void:
	# Update the modified tile and its neighbors
	update_tile(cell)
	update_tile(cell + Vector2i(0, -1))  # North
	update_tile(cell + Vector2i(1, 0))   # East
	update_tile(cell + Vector2i(0, 1))   # South
	update_tile(cell + Vector2i(-1, 0))  # West
