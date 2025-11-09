extends PointLight2D

@export var min_energy := 0.2
@export var max_energy := 1.2
@export var flicker_chance := 0.35 # how often flicker happens per frame
@export var flicker_intensity := 0.4 # how low it drops
@export var recovery_speed := 10.0 # how fast it recovers

var target_energy := 1.0

func _ready():
	randomize()
	energy = max_energy

func _process(delta):
	if randf() < flicker_chance * delta * 60:
		# sudden dip
		target_energy = randf_range(min_energy, max_energy * flicker_intensity)
	else:
		# recover toward full brightness
		target_energy = max_energy
	
	# make transitions sharp but not instant
	energy = lerp(energy, target_energy, delta * recovery_speed)
