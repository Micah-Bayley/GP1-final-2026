extends Node2D

# -----------------------------
# TUNING
# -----------------------------
@export var terrain_types: Array[TerrainData]
@export var lanes := [
	300.0,   # ground
	100.0,   # mid
	100.0   # ceiling
]
@export var scroll_speed := 300.0
@export var spawn_x := 1200.0      # fixed X where terrain spawns (right of screen)
@export var min_gap := 100.0        # minimum pixels between spawns
@export var max_gap := 500.0        # maximum pixels between spawns (randomness)

# -----------------------------
# INTERNAL STATE
# -----------------------------
var _distance_to_next := 0.0  # pixels until next spawn
var _last_lane := -1

# -----------------------------
# READY
# -----------------------------
func _ready():
	for t in terrain_types:
		if t != null and t.width == 0.0:
			t.update_size()
	# Spawn one immediately so the screen isn't empty
	_distance_to_next = 0.0

# -----------------------------
# PROCESS (MAIN LOOP)
# -----------------------------
func _process(delta):
	# Count down distance using scroll speed as a proxy for world movement
	_distance_to_next -= scroll_speed * delta

	if _distance_to_next <= 0.0:
		spawn_terrain()

# -----------------------------
# SPAWN TERRAIN
# -----------------------------
func spawn_terrain():
	var data = pick_weighted_terrain()
	if data == null or data.scene == null:
		_distance_to_next = min_gap
		return

	if data.allowed_lanes.is_empty():
		data.allowed_lanes = [0]

	var instance = data.scene.instantiate()

	# -------------------------
	# LANE SELECTION (no repeat if avoidable)
	# -------------------------
	var lane_index = data.allowed_lanes.pick_random()
	if lane_index == _last_lane and data.allowed_lanes.size() > 1:
		var others = data.allowed_lanes.filter(func(l): return l != _last_lane)
		lane_index = others.pick_random()

	var y_pos = lanes[lane_index]

	# -------------------------
	# POSITION — always at spawn_x (right edge)
	# -------------------------
	var pos = Vector2(spawn_x + data.x_offset, y_pos + data.y_offset)
	if data.random_y_offset > 0.0:
		pos.y += randf_range(-data.random_y_offset, data.random_y_offset)

	instance.global_position = pos

	# -------------------------
	# Pass scroll speed so the terrain can move itself
	# -------------------------
	if instance.has_method("set_scroll_speed"):
		instance.set_scroll_speed(scroll_speed)

	# -------------------------
	# VISUAL VARIATION
	# -------------------------
	if data.random_scale_variation > 0.0:
		var s = 1.0 + randf_range(-data.random_scale_variation, data.random_scale_variation)
		instance.scale = Vector2(s, s)
	if data.random_rotation > 0.0:
		instance.rotation_degrees = randf_range(-data.random_rotation, data.random_rotation)

	add_child(instance)
	_last_lane = lane_index

	# -------------------------
	# NEXT SPAWN DISTANCE — random gap (the "alternating times" effect)
	# -------------------------
	var base_gap = randf_range(min_gap, max_gap)
	# Add the terrain's own width so wide pieces don't overlap
	_distance_to_next = base_gap + data.width

# -----------------------------
# WEIGHTED PICK
# -----------------------------
func pick_weighted_terrain() -> TerrainData:
	if terrain_types.is_empty():
		return null
	var total_weight := 0.0
	for t in terrain_types:
		if t != null:
			total_weight += t.weight
	var r = randf() * total_weight
	for t in terrain_types:
		if t == null:
			continue
		r -= t.weight
		if r <= 0:
			return t
	return terrain_types[0]
