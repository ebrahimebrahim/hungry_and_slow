extends Node2D

var direction_vec = Vector2(0,-1)

var max_speed = 200
var speed_control_radius = 200
var max_rot_speed = deg2rad(360*4) 

var F   = 300
var DF  = 150
var B   = 30
var DB  = 30


func _ready():
	update_direction(self.direction_vec)
	create_mask()


func update_direction(dir : Vector2) -> void :
	self.direction_vec = dir.normalized()
	self.rotation = atan2(dir.y,dir.x)+PI/2


func get_mouse_relpos() -> Vector2:
	return self.get_global_mouse_position() - position

func _process(delta):
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		var rel_mouse_pos : Vector2 = get_mouse_relpos()

		var angle_difference = direction_vec.angle_to(rel_mouse_pos)
		
		# If angle diff is smaller than threshold (in radians),
		# then snap to correct rotation immediately.
		# Otherwise head gradually towards correct rotation
		if abs(angle_difference) < 0.02:
			update_direction(rel_mouse_pos)
		else:
			update_direction( direction_vec.rotated((max_rot_speed * delta) * angle_difference/PI) )
		
		
		var speed = max_speed * min(rel_mouse_pos.length(),speed_control_radius)/float(speed_control_radius)
		self.position += (speed * delta) * direction_vec


func create_mask():
	var img = Image.new()
	var vp_size = get_viewport_rect().size
	img.create(2*vp_size.x, 2*vp_size.y, false, Image.FORMAT_RGBA8)
	img.lock()
	
	# pixel that corresponds to player position
	var p = Vector2(img.get_width()/2,img.get_height()/2)
	
	# forward and backward view distances

	
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			
			# location to draw pixel
			var q = Vector2(x,y)
			
			#displacement vector from expected player position to pixel that we are drawing
			var v = q-p
			
			# relative polar-like coords
			var th = acos(v.normalized().dot(direction_vec)) / PI
			var r  = v.length()
			
			var r_full =  th * B  + (1-th) * F
			var dr     =  th * DB + (1-th) * DF
			
			var alpha = 1
			if r < r_full: alpha = 0
			elif r < r_full + dr: alpha = 0.5
			
			img.set_pixel(x,y,Color(0,0,0,alpha))
	img.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	get_node("Mask").texture = tex
