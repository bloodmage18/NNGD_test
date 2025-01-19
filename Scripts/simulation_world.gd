extends Node2D

@export var food_scene: PackedScene
@export var creature_scene: PackedScene
@export var food_count: int = 10
@export var creature_count: int = 5

@onready var world_size : Vector2 = $Bonds/CollisionShape2D.shape.size 
@onready var Food_node : Node = $Food
@onready var Creature_node : Node = $Creatures

func _ready():
	#spawn_food()
	spawn_creatures()

func spawn_food(food):
	Food_node.add_child(food)
	#for i in food_count:
		#var food = food_scene.instantiate()
		#food.position = Vector2($Bonds.global_position.y /4 , $Bonds.global_position.x / 8 ) + Vector2( randf() * world_size.x, randf() * world_size.y ) # point 2
		##food.position = $FoodSpawner.global_position + Vector2(randi() % 100, randi() % 100)  #----- [pint 1
		#add_child(food)

func spawn_creatures():
	for i in creature_count:
		var creature = creature_scene.instantiate()
		creature.position = Vector2($Bonds.global_position.y /4 , $Bonds.global_position.x / 8 ) + Vector2( randf() * world_size.x, randf() * world_size.y ) # point 2
		#creature.position = $CreatureSpawner.global_position + Vector2(randi() % 100, randi() % 100)
		Creature_node.add_child(creature)
