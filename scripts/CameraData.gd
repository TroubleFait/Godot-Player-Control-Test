extends Resource

class_name CameraData


# Declare member variables here.
export(Vector3) var target_offset # The length of the arm that carries the Camera (arm attached to the character)
	# arm_length
export(Vector3) var rotation
	# arm_rotation
export(Vector2) var pitch_limit # To avoid rotation bugs at limit values
	# arm_rotation_pitch_limit

export(Vector3) var anchor_offset # Where on the character the arm is attached (that carries the Camera)
	# arm_position
export(Vector3) var look_target
	# camera_target


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
