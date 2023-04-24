extends KinematicBody


# Declare member variables here.
var SCREEN_CENTER
var SPIN = 0.005 # Mouse sensitivity

# Camera rotation
var camera_rot_x = 0
var camera_rot_y = 0

# Cursors
var virtual_cursor = Vector2.ZERO
#var old_cursor_pos = Vector2()
#var cursor_speed = Vector2()
#var follow_cursor_speed = Vector2()
var follow_cursor_design_param = {
	"f": 8,
	"zeta": 1,
	"r": 0,
#	"f": 0.5,
#	"zeta": 0.8,
#	"r": 1,
}

# Moving the head
var virtual_head_target = Vector2.ZERO

export var LIMITS: Dictionary = {
	"Head_right": -0.2 * TAU,
	"Head_left": 0.2 * TAU,
	"Head_top": 0.2 * TAU,
	"Head_bottom": -0.25 * TAU,
#	"Head_speed": ,
	
#	"Torso_right": ,
#	"Torso_left": ,
#	"Torso_top": ,
#	"Torso_bottom": ,
#	"Torso_speed": ,
}

var follow_cursor = SecondOrderDynamics2D.new()
var move_head_anim = SecondOrderDynamics2D.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Calibrate cursors
	SCREEN_CENTER = get_viewport().get_texture().get_size() / 2
	$ControlCursors/Cursor.position = SCREEN_CENTER
	$ControlCursors/FollowCursor.position = SCREEN_CENTER
	follow_cursor.initialise(follow_cursor_design_param.f, follow_cursor_design_param.zeta, follow_cursor_design_param.r, virtual_cursor)
	# Calibrate head target
	move_head_init()
	
	$Camera/RayCast.add_exception(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
# _delta if process doesn't actually use delta.
func _process(delta):
	# Cursor(the eyes) moves, then Camera and Head in tandem, then the Torso,
	# and finally Body(the hips).
	move_camera(delta)
	move_head(delta)
#	move_torso()
	debug_show_raycast_collision_points()


func _input(event):
	update_mouse_mode(event)
#	debug_camera_collision(event)


func _unhandled_input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# have mouse move Cursor
			virtual_cursor += 100*SPIN*event.relative


func move_camera(delta):
	var update = follow_cursor.update_k2_clamp(delta, virtual_cursor)
	# Move camera
	camera_rot_x = (-update.x) * SPIN
	camera_rot_y = (-update.y) * SPIN
	$Camera.transform.basis = Basis()
	$Camera.rotate_object_local(Basis().y, camera_rot_x)
	$Camera.rotate_object_local(Basis().x, camera_rot_y)
	# Move cursor
	$ControlCursors/Cursor.position = virtual_cursor - update + SCREEN_CENTER


func move_head_init():
	$HeadTarget.transform = $Head2.transform
	# Look at camera collision point
	if $Camera/RayCast.is_colliding():
		$HeadTarget.look_at($Camera/RayCast.get_collision_point(), Vector3.UP)
	# Or look at the horizon
	else:
		$HeadTarget.set_rotation($Camera.rotation)
	move_head_anim.initialise(8, 1, 0, $HeadTarget.rotation)
	$Head2.rotation = $HeadTarget.rotation


func move_head(delta):
	var update
	# Look at camera collision point
	if $Camera/RayCast.is_colliding():
		$HeadTarget.look_at($Camera/RayCast.get_collision_point(), Vector3.UP)
	# Or look at the horizon
	else:
		$HeadTarget.set_rotation($Camera.rotation)
	update = move_head_anim.update_accurate(delta, $HeadTarget.rotation)
	$Head2.rotation = update
	
#	# Look at camera collision point
#	if $Camera/RayCast.is_colliding():
#		$HeadTarget.look_at($Camera/RayCast.get_collision_point(), Vector3.UP)
#		$Head2.set_rotation($HeadTarget.rotation)
#	# Or look at the horizon
#	else:
##		$Head2.look_at($Head2.global_transform.origin - $Camera.global_transform.basis.z, Vector3.UP)
##		print($Head2.global_transform.origin - $Camera.global_transform.basis.z)
#		$Head2.set_rotation($Camera.rotation)


func debug_show_raycast_collision_points():
	if $Head2/RayCast.is_colliding():
		$Head2/RayCast/CollisionPoint.set_visible(true)
		$Head2/RayCast/CollisionPoint \
				.set_global_transform(Transform(Basis(), 
				$Head2/RayCast.get_collision_point()))
	# Maybe place it "at the horizon"? Or maybe at a set distance along the RayCast? Maybe depending on weapon range or user viewing distance
	else:
		$Head2/RayCast/CollisionPoint.set_visible(false)
	
	if $Camera/RayCast.is_colliding():
		$Camera/RayCast/CollisionPoint.set_visible(true)
		$Camera/RayCast/CollisionPoint.set_global_transform(Transform(Basis(), $Camera/RayCast.get_collision_point()))
	else:
		$Camera/RayCast/CollisionPoint.set_visible(false)


func update_mouse_mode(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().set_input_as_handled()


#func debug_camera_collision(event):
#	if event.is_action_pressed("click"):
#		if $Camera/RayCast.is_colliding():
#			print($Camera/RayCast.get_collider().name)
#		else:
#			print("Horizon")
