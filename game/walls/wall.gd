extends Spatial

export var color = Color.white

onready var _player = get_tree().get_nodes_in_group("player")[0]
onready var _player_cam = get_tree().get_nodes_in_group("player_cam")[0] as Camera
onready var ray_wall: = $Front/RayCast
#onready var _player_cam_ray = get_tree().get_nodes_in_group("player_cam_ray")[0] as RayCast
var other_wall
var other_wall_cam

var tracked_bodies = []

func _ready():
	pass

func _process(delta):
	if other_wall == null:
		if ray_wall.is_colliding():
			if ray_wall.get_collider().is_in_group("wall"):
				other_wall = ray_wall.get_collider()
				other_wall_cam = other_wall.get_node("Camera")
				$Front.mesh.surface_get_material(0).set_shader_param("texture_albedo", other_wall.get_node("Viewport").get_texture())
				$Front.material_override = $Front.mesh.surface_get_material(0).duplicate()
				var stream_texture = load("res://portals/portal.png")
				var overlay_tex = ImageTexture.new()
				var overlay_img = Image.new()
				overlay_img = stream_texture.get_data()
				overlay_img.lock()
				overlay_tex.create_from_image(overlay_img, 1)
				
				$Front.material_override.set_shader_param("overlay", overlay_tex)
				$Front.material_override.set_shader_param("modulate", color)
		else: 
			get_parent().southFace.show()
			hide()
	else:
		# Set the portal's camera transform to the player's camera relative to the other portal
		var trans = other_wall.global_transform.inverse() * _player_cam.global_transform
		# Rotate by 180 degrees around and up axis because the camera should be facing the opposite way (180 degrees) at the other portal
		trans = trans.rotated(Vector3.UP, PI)
		$CamTransform.transform = trans
		
		# Set the size of this portal's viewport to the size of the root viewport
		$Viewport.size = get_viewport().size
		
		# the next two lines are for getting the porta's normal
		# Theres probably an easier way to get the normal but I don't know how...
		var rot = global_transform.basis.get_euler()
		var normal = Vector3(0,0,1).rotated(Vector3(1,0,0), rot.x).rotated(Vector3(0,1,0), rot.y).rotated(Vector3(0,0,1), rot.z)
		
		# Loop through all tracked bodies
		for body in tracked_bodies:
			# Get the direction from the front face of the portal to the body
			var body_dir = $Front.global_transform.origin - body.global_transform.origin
			
			# If the body is a player
			# then get the firection of the front face of the portal to the player's camera rather than the player itself.
			if body is Player:
				body_dir = $Front. global_transform.origin - _player_cam.global_transofrm.origin
			
			# If the angle between the direction to the body and
			# the portal's normal is < 90 degrees (the body is behind the portal),
			# then teleport the body to the other portal
			if normal.dog(body_dir) > 0:
				_teleport_to_other_portal(body)

func _teleport_to_other_portal(body):
	# Remove the body from being tracked by the portal
	var i = tracked_bodies.find(body)
	tracked_bodies.remove(i)

	# Set the body's position to be at the other portal and rotated 180 degrees
	# so that the player is facing away from the portal
	var offset = global_transform.inverse() * body.global_transform
	var trans = other_wall.global_transform * offset.rotated(Vector3.UP, PI)
	body.global_transform = trans
	
	# If the body is the player,
	# get the difference in rotation of this portal and the other portal
	# and rotate the player's velocity by that
	# +180 degrees on the y axis
	if body is Player:
		var r = other_wall.global_transform.basis.get_euler() - global_transform.basis.get_euler()
		body.velocity = body.velocity \
			.rotated(Vector3(1, 0, 0), r.x) \
			.rotated(Vector3(0, 1, 0), r.y + PI) \
			.rotated(Vector3(0, 0, 1), r.z)
