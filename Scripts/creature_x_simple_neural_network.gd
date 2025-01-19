extends CharacterBody2D

@export var speed: float = 50.0
@export var energy: float = 100.0  # Energy depletes with movement
@export var hunger_threshold: float = 50.0  # Trigger to search for food
@export var detection_radius: float = 100.0  # Food detection range

var neural_network = preload("res://Scripts/AI/SimpleNeuralNetwork.gd").new()
var target_food: Node2D = null

func _ready():
	neural_network.input_size = 3  # Energy and hunger status
	neural_network.hidden_size = 4
	neural_network.output_size = 3  # Move left, right, up, or down
	neural_network.randomize_weights()
	
	$Area2D.connect("body_entered" , _on_body_entered)
	$Area2D.connect("body_exited" , _on_body_exited)
	$Area2D/CollisionShape2D.shape.radius = detection_radius

func _physics_process(delta):
	if target_food and is_instance_valid(target_food):
		move_towards_food(delta)
	else:
		think_and_move(delta)
		

func _on_body_entered(body):
	if body.is_in_group("Food") and not target_food:
		target_food = body  # Set the nearest food as the target

func _on_body_exited(body):
	if body == target_food:
		target_food = null  # Clear the target if it exits the detection radius

func think_and_move(delta):
	# Neural network inputs: energy level, is_hungry
	var is_hungry = energy < hunger_threshold
	#var inputs = PackedFloat32Array([energy / 100.0, 1.0 if is_hungry else 0.0])
	# Inputs for the neural network
	var inputs = PackedFloat32Array([
		energy / 100.0,
		target_food.position.distance_to(position) / detection_radius if target_food else 1.0,
		1.0 if is_hungry else 0.0
	])
	var outputs = neural_network.process(inputs)

	# Outputs decide direction
	var directions = [
		Vector2(-1, 0),  # Left
		Vector2(1, 0),   # Right
		Vector2(0, -1),  # Up
		Vector2(0, 1)    # Down
	]

	var max_index = find_max_index(outputs)
	velocity = directions[max_index] * speed

	# Energy management
	energy -= delta * 5 if velocity.length() > 0 else delta * 2
	energy = clamp(energy, 0, 100)

	move_and_slide()

func find_max_index(array: PackedFloat32Array) -> int:
	var max_index = 0
	var max_value = array[0]
	for i in range(1, array.size()):
		if array[i] > max_value:
			max_value = array[i]
			max_index = i
	return max_index

func move_towards_food(delta):
	if not is_instance_valid(target_food):
		target_food = null
		return

	var direction = (target_food.position - position).normalized()
	velocity = direction * speed
	move_and_slide()

	# Check for food consumption
	if position.distance_to(target_food.position) < 15.0:
		consume_food(target_food)
		target_food = null

func consume_food(food):
	if is_instance_valid(food):
		food.consume()
		#food.queue_free()  # Remove the food from the scene
		energy = min(energy + 30, 100)  # Gain energy

