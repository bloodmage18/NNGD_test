extends Resource

@export var input_size: int = 3
@export var hidden_size: int = 4
@export var output_size: int = 3  # Two for movement direction, one for move/idle decision

var weights_input_hidden: PackedFloat32Array
var weights_hidden_output: PackedFloat32Array
var bias_hidden: PackedFloat32Array
var bias_output: PackedFloat32Array

func _init():
	randomize_weights()

func randomize_weights():
	weights_input_hidden = PackedFloat32Array()
	for i in range(input_size * hidden_size):
		weights_input_hidden.append(randf() * 2 - 1)

	weights_hidden_output = PackedFloat32Array()
	for i in range(hidden_size * output_size):
		weights_hidden_output.append(randf() * 2 - 1)

	bias_hidden = PackedFloat32Array()
	for i in range(hidden_size):
		bias_hidden.append(randf() * 2 - 1)

	bias_output = PackedFloat32Array()
	for i in range(output_size):
		bias_output.append(randf() * 2 - 1)

func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + exp(-x))

func process(inputs: PackedFloat32Array) -> PackedFloat32Array:
	assert(inputs.size() == input_size, "Input size mismatch!")

	# Input to Hidden Layer
	var hidden_values = PackedFloat32Array()
	for h in range(hidden_size):
		var value = bias_hidden[h]
		for i in range(input_size):
			value += inputs[i] * weights_input_hidden[i * hidden_size + h]
		hidden_values.append(sigmoid(value))

	# Hidden to Output Layer
	var output_values = PackedFloat32Array()
	for o in range(output_size):
		var value = bias_output[o]
		for h in range(hidden_size):
			value += hidden_values[h] * weights_hidden_output[h * output_size + o]
		output_values.append(sigmoid(value))

	return output_values
