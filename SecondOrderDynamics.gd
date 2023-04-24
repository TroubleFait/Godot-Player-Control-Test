class_name SecondOrderDynamics2D extends Node

# Declare member variables here. Examples:
var x_prev # Previous input
var y
var y_speed
var y_accel # State variables
#var x_prev: Vector2 # Previous input
#var y: Vector2
#var y_speed: Vector2
#var y_accel := Vector2() # State variables
var k1: float
var k2: float
var k3: float
var _w
var _z
var _d


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func initialise(f: float, zeta: float, r: float,
		x0 = 0):
	# Compute constants
	_w = TAU * f
	_z = zeta
	_d = _w * sqrt(abs(zeta*zeta - 1))
#	print("initialise(	f: ", f, ", 	zeta: ", zeta, ", 	r: ", r, ")")
	k1 = zeta / (PI * f)
	k2 = 1 / ((TAU * f) * (TAU * f))
	k3 = r * zeta / (TAU * f)
	# Initialise variables
	x_prev = x0
	y = x0
	y_speed = 0 * y
#	print("k1: ", k1, ", 	k2: ", k2, ", 	k3: ", k3)
#	print("x_prev: ", x_prev, ", 	y: ", y, ", 	y_speed: ", y_speed)

func update(delta, x, x_speed = null):
#	print("update(	delta: ", delta, ", 	x: ", x, ", 	x_speed: ", x_speed, ")")
	if x_speed == null: # Estimate velocity
		x_speed = (x - x_prev) / delta
#		print("x_speed: ", x_speed, ", 	x_prev: ", x_prev)
		x_prev = x
	y += delta * y_speed # Integrate position by velocity
	y_accel = (x + k3 * x_speed - y - k1*y_speed) / k2
#	print("y: ", y, ", 	y_accel: ", y_accel)
	y_speed += delta * y_accel # Integrate velocity by acceleration
#	print("y: ", y, ", 	y_speed: ", y_speed)
	return y


func update_k2_clamp(delta, x, x_speed = null):
#	print("update(	delta: ", delta, ", 	x: ", x, ", 	x_speed: ", x_speed, ")")
	if x_speed == null: # Estimate velocity
		x_speed = (x - x_prev) / delta
#		print("x_speed: ", x_speed, ", 	x_prev: ", x_prev)
		x_prev = x
	var k2_stable = max(k2, max((delta*delta/2 + delta*k1/2), delta*k1)) # Clamp k2 to guarantee stability without jitter
	y += delta * y_speed # Integrate position by velocity
	y_accel = (x + k3 * x_speed - y - k1*y_speed) / k2_stable
#	print("y: ", y, ", 	y_accel: ", y_accel)
	y_speed += delta * y_accel # Integrate velocity by acceleration
#	print("y: ", y, ", 	y_speed: ", y_speed)
	return y


func update_accurate(delta, x, x_speed = null):
	#	print("update(	delta: ", delta, ", 	x: ", x, ", 	x_speed: ", x_speed, ")")
	if x_speed == null: # Estimate velocity
		x_speed = (x - x_prev) / delta
#		print("x_speed: ", x_speed, ", 	x_prev: ", x_prev)
		x_prev = x
	var k1_stable
	var k2_stable
	if _w*delta < _z: # Clamp k2 to guarantee stability without jitter
		k1_stable = k1
		k2_stable = max(k2, max((delta*delta/2 + delta*k1/2), delta*k1))
	else: # Use pole matching when the system is very fast
		var t1 = exp(- _z * _w * delta)
		var alpha = 2 * t1 * (cos(delta * _d) if _z <=1 else cosh(delta * _d))
		var beta = t1 * t1
		var t2 = delta / (1 + beta - alpha)
		k1_stable = (1 - beta) * t2
		k2_stable = delta * t2
	y += delta * y_speed # Integrate position by velocity
	y_accel = (x + k3 * x_speed - y - k1_stable*y_speed) / k2_stable
#	print("y: ", y, ", 	y_accel: ", y_accel)
	y_speed += delta * y_accel # Integrate velocity by acceleration
#	print("y: ", y, ", 	y_speed: ", y_speed)
	return y
