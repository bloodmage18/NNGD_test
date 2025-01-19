extends Marker2D

@export var food_scene: PackedScene = preload("res://Scenes/Food.tscn")  # The food scene
@export var spawn_area_size: Vector2 = Vector2(500, 500)  # Spawning area dimensions
@export var max_food_count: int = 10  # Maximum food items in the scene
@export var spawn_interval: float = 5.0  # Time between spawns
@export var enabled : bool = false

var food_items: Array = []  # Track active food items
var spawn_timer: float = 0.0

func _process(delta):
	if enabled:
		spawn_timer -= delta
		if spawn_timer <= 0.0 and food_items.size() < max_food_count:
			spawn_food()
			spawn_timer = spawn_interval

func spawn_food():
	var food_instance = food_scene.instantiate()
	var random_position = Vector2(
		randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
		randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
	)
	food_instance.global_position = global_position + random_position
	#food_instance.position = global_position + Vector2(randi() % spawn_area_size.x , randi() % spawn_area_size.y) #Vector2(randi() % spawn_area_size.x, randi() % spawn_area_size.y) 
	food_items.append(food_instance)
	get_parent().spawn_food(food_instance)

	# Clean up when food is consumed
	food_instance.connect("tree_exiting", Callable(self, "_on_food_removed").bind(food_instance))

func _on_food_removed(food_instance):
	food_items.erase(food_instance)
