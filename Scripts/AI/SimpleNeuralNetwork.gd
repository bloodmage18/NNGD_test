#extends Resource
#class_name  SimpleNeuralnetwork
#
#@export var input_size: int = 3
#@export var hidden_size: int = 4
#@export var output_size: int = 3  # Two for movement direction, one for move/idle decision
#
#var weights_input_hidden: PackedFloat32Array
#var weights_hidden_output: PackedFloat32Array
#var bias_hidden: PackedFloat32Array
#var bias_output: PackedFloat32Array
#
#func _init():
	#randomize_weights()
#
#func randomize_weights():
	#weights_input_hidden = PackedFloat32Array()
	#for i in range(input_size * hidden_size):
		#weights_input_hidden.append(randf() * 2 - 1)
#
	#weights_hidden_output = PackedFloat32Array()
	#for i in range(hidden_size * output_size):
		#weights_hidden_output.append(randf() * 2 - 1)
#
	#bias_hidden = PackedFloat32Array()
	#for i in range(hidden_size):
		#bias_hidden.append(randf() * 2 - 1)
#
	#bias_output = PackedFloat32Array()
	#for i in range(output_size):
		#bias_output.append(randf() * 2 - 1)
#
#func sigmoid(x: float) -> float:
	#return 1.0 / (1.0 + exp(-x))
#
#func process(inputs: PackedFloat32Array) -> PackedFloat32Array:
	#assert(inputs.size() == input_size, "Input size mismatch!")
#
	## Input to Hidden Layer
	#var hidden_values = PackedFloat32Array()
	#for h in range(hidden_size):
		#var value = bias_hidden[h]
		#for i in range(input_size):
			#value += inputs[i] * weights_input_hidden[i * hidden_size + h]
		#hidden_values.append(sigmoid(value))
#
	## Hidden to Output Layer
	#var output_values = PackedFloat32Array()
	#for o in range(output_size):
		#var value = bias_output[o]
		#for h in range(hidden_size):
			#value += hidden_values[h] * weights_hidden_output[h * output_size + o]
		#output_values.append(sigmoid(value))
#
	#return output_values


extends Resource
class_name SimpleNeuralNetwork

@export var network_shape: Array[int] = [2, 4, 4, 2]
var layers: Array = []

# Layer class for the neural network
class Layer:
	var weights: PackedFloat32Array
	var biases: PackedFloat32Array
	var nodes: PackedFloat32Array
	
	func _init(num_inputs: int, num_nodes: int):
		self.weights = PackedFloat32Array()
		self.biases = PackedFloat32Array()
		self.nodes = PackedFloat32Array()

		for i in range(num_nodes):
			self.biases.append(randf_range(-1.0, 1.0))
			for j in range(num_inputs):
				self.weights.append(randf_range(-1.0, 1.0))
		
		self.nodes.resize(num_nodes)

	func forward(inputs: PackedFloat32Array):
		for i in range(self.nodes.size()):
			self.nodes[i] = 0
			for j in range(inputs.size()):
				self.nodes[i] += self.weights[i * inputs.size() + j] * inputs[j]
			self.nodes[i] += self.biases[i]

	func activate():
		for i in range(self.nodes.size()):
			self.nodes[i] = max(self.nodes[i], 0)  # ReLU activation

# Initialize the network
func _init():
	for i in range(network_shape.size() - 1):
		var layer = Layer.new(network_shape[i], network_shape[i + 1])
		layers.append(layer)

# Perform forward propagation
func process(inputs: PackedFloat32Array) -> PackedFloat32Array:
	var current_input = inputs
	for i in range(layers.size()):
		var layer = layers[i]
		layer.forward(current_input)
		if i < layers.size() - 1:  # Apply activation for all layers except the last
			layer.activate()
		current_input = layer.nodes
	return layers[-1].nodes

# Copy weights and biases from another neural network
func copy_from(other: NeuralNetwork):
	for i in range(layers.size()):
		layers[i].weights = other.layers[i].weights.duplicate()
		layers[i].biases = other.layers[i].biases.duplicate()

# Mutate weights and biases with a mutation rate
func mutate_weights(mutation_rate: float):
	for i in range(layers.size()):
		for j in range(layers[i].weights.size()):
			if randf() < mutation_rate:
				layers[i].weights[j] += randf_range(-0.1, 0.1)
		for k in range(layers[i].biases.size()):
			if randf() < mutation_rate:
				layers[i].biases[k] += randf_range(-0.1, 0.1)
