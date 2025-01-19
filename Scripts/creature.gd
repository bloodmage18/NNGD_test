extends Node2D

@export var speed: float = 100.0  # Movement speed
@export var detection_radius: float = 100.0  # Food detection range

var target_food: Node2D = null

@export var neural_network: Resource


func _ready():
	$Area2D.connect("body_entered" , _on_Area2D_body_entered)
	$Area2D.connect("body_exited" , _on_Area2D_body_exited)
	$Area2D/CollisionShape2D.shape.radius = detection_radius

func _process(delta: float):
	if target_food and is_instance_valid(target_food):
		move_towards_food(delta)
	if not target_food:  # No target food, keep searching
		search_for_food()

func search_for_food():
	# Search for new food within the detection radius
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("Food"):
			target_food = body
			return

func move_towards_food(delta: float):
	var direction = (target_food.global_position - global_position).normalized()
	position += direction * speed * delta

	if global_position.distance_to(target_food.global_position) < 10.0:
		target_food.consume()
		target_food = null

func _on_Area2D_body_entered(body):
	if body.is_in_group("Food") and not target_food:
		target_food = body

func _on_Area2D_body_exited(body):
	# Clear the target if the food leaves the detection radius
	if body == target_food:
		target_food = null
