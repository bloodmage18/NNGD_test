extends CharacterBody2D

@export var speed: float = 50.0
@export var energy: float = 100.0
@export var hunger_threshold: float = 20.0
@export var detection_radius: float = 100.0
@export var reproduction_cost: float = 30.0  # Energy cost of reproducing
@export var reproduction_threshold: float = 80.0  # Energy level to trigger reproduction

@export var neural_network := SimpleNeuralnetwork.new() #= preload("res://Scripts/AI/SimpleNeuralNetwork.gd").new()
@export var creature_scene : PackedScene   # Scene for a new creature
var target_food: Node2D = null

enum CreatureState { IDLE, ROAMING, TARGETING_FOOD, DEAD}
var state: CreatureState = CreatureState.IDLE

var roaming_direction: Vector2 = Vector2.ZERO
var state_timer: float = 0.0

var info_text = ""

func _init():
	neural_network = SimpleNeuralnetwork.new()

func _ready():
	neural_network.input_size = 3
	neural_network.hidden_size = 4
	neural_network.output_size = 3
	neural_network.randomize_weights()

	$Area2D.connect("body_entered", _on_body_entered)
	$Area2D.connect("body_exited", _on_body_exited)
	$Area2D/CollisionShape2D.shape.radius = detection_radius

func _physics_process(delta):
	if energy <= 0 and state != CreatureState.DEAD:
		change_state(CreatureState.DEAD)
		
	match state:
		CreatureState.IDLE:
			idle_behavior(delta)
			info_text = "[ IDLE ]"# + str(energy - 2) + "]"
		CreatureState.ROAMING:
			roaming_behavior(delta)
			info_text = "[ ROAM ]"# + str(energy - 1) + "]"
		CreatureState.TARGETING_FOOD:
			info_text = "[ HUNT ]"# + str(energy - 1) + "]"
			if target_food and is_instance_valid(target_food):
				move_towards_food(delta)
			else:
				target_food = null
				change_state(CreatureState.IDLE)
		CreatureState.DEAD:
			death_behavior(delta)
			info_text = "[ DEAD ]"
			
	$Label.text = info_text
	$EnergyBar.value = energy

func idle_behavior(delta):
	#energy = min(energy + delta * 5, 100)  # Regain energy
	energy = min(energy + delta * 1, 100)  # Regain less energy
	state_timer -= delta
	if energy >= reproduction_threshold:
		reproduce()
		state_timer = 1.0  # Short delay after reproduction
	elif state_timer <= 0:
		change_state(CreatureState.ROAMING)

func roaming_behavior(delta):
	if roaming_direction == Vector2.ZERO or state_timer <= 0:
		roaming_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		state_timer = randf_range(1.0, 3.0)  # Roam for 1-3 seconds

	velocity = roaming_direction * speed
	move_and_slide()

	energy -= delta * 2  # Roaming consumes energy
	energy = clamp(energy, 0, 100)
	if energy >= reproduction_threshold:
		reproduce()
		state_timer = 1.0  # Short delay after reproduction
	if state_timer <= 0 and energy <= hunger_threshold:
		change_state(CreatureState.IDLE)
	state_timer -= delta
	
func death_behavior(delta):
	velocity = Vector2.ZERO  # Stop all movement
	# Optional: Play death animation or visual effect here
	queue_free()  # Remove the creature after "dying"
	
func reproduce():
	if energy < reproduction_cost:
		return  # Prevent reproduction if not enough energy

	energy -= reproduction_cost
	energy = max(energy, 0)

	var new_creature = creature_scene.instantiate()
	new_creature.position = position + Vector2(randf_range(-20, 20), randf_range(-20, 20))  # Spawn nearby

	# Check if the parent has a valid neural network before copying
	if neural_network:
		new_creature.neural_network = SimpleNeuralnetwork.new()
		new_creature.neural_network.copy_from(neural_network)  # Inherit neural network weights
		new_creature.neural_network.mutate_weights(0.1)  # Add slight mutation

	get_parent().add_child(new_creature)  # Add to the scene
	print("Creature reproduced!")

func change_state(new_state: CreatureState):
	state = new_state
	state_timer = randf_range(1.0, 3.0) if new_state == CreatureState.IDLE else 0.0
	roaming_direction = Vector2.ZERO if new_state == CreatureState.IDLE else roaming_direction

func move_towards_food(delta):
	if not is_instance_valid(target_food):
		target_food = null
		return

	var direction = (target_food.position - position).normalized()
	velocity = direction * speed
	move_and_slide()

	if position.distance_to(target_food.position) < 15.0:
		consume_food(target_food)
		target_food = null

func _on_body_entered(body):
	if body.is_in_group("Food") and not target_food:
		target_food = body
		change_state(CreatureState.TARGETING_FOOD)

func _on_body_exited(body):
	if body == target_food:
		target_food = null
		change_state(CreatureState.IDLE)

func consume_food(food):
	if is_instance_valid(food):
		food.consume()
		energy = min(energy + 30, 100)
