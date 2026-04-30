extends Resource
class_name TerrainData

@export var scene: PackedScene
@export var width: float = 0
@export var height: float = 0
@export var allowed_lanes: Array[int] = [0]
@export var weight: float = 1.0
@export var random_scale_variation: float = 0.0
@export var random_y_offset: float = 0.0
@export var random_rotation: float = 0.0
@export var size_node_path: NodePath = "Sprite2D"
@export var x_offset: float = 0.0
@export var y_offset: float = 0.0

func update_size():
	if scene == null:
		push_warning("No scene assigned in TerrainData")
		return
	var instance = scene.instantiate()
	var node = instance.get_node_or_null(size_node_path)
	if node == null:
		push_warning("Node not found: " + str(size_node_path))
		instance.queue_free()
		return

	if node is Sprite2D and node.texture:
		var root_scale = instance.scale
		width = node.texture.get_width() * node.scale.x * root_scale.x
		height = node.texture.get_height() * node.scale.y * root_scale.y
	elif node is CollisionShape2D:
		var shape = node.shape
		if shape is RectangleShape2D:
			var root_scale = instance.scale
			width = shape.size.x * node.scale.x * root_scale.x
			height = shape.size.y * node.scale.y * root_scale.y
	else:
		push_warning("Unsupported node type for size detection")

	instance.queue_free()
