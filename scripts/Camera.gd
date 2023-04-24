extends Camera


# Declare member variables here.
export(NodePath) onready var target = get_node(target)

export(Resource) var setup


# Called when the node enters the scene tree for the first time.
func _ready():
	if setup.target_offset == Vector3.ZERO:
		setup.target_offset = self.transform.origin - target.transform.origin - setup.anchor_offset
	if setup.look_target == Vector3.ZERO:
		setup.look_target = Vector3(0, 0, 100.0)
	setup.pitch_limit.x = deg2rad(setup.pitch_limit.x)
	setup.pitch_limit.y = deg2rad(setup.pitch_limit.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.transform.origin = target.transform.origin + setup.anchor_offset
#	var target_offset = setup.target_offset
#	var look_at = setup.look_target
#	var up_down_axis = Vector3.RIGHT.rotated(Vector3.UP, setup.rotation.y)
#	target_offset = Vector3.RIGHT.rotated(Vector3.UP, setup.rotation.y)
#	look_at = Vector3.RIGHT.rotated(Vector3.UP, setup.rotation.y)
	pass
