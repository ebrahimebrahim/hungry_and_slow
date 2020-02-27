extends "Creature.gd"


var F   = 400
var DF  = 140
var B   = 50
var DB  = 50

var max_speed = 400
export var speed_control_radius = 400


func _ready():
#	create_mask()
	pass





func get_mouse_relpos() -> Vector2:
	return self.get_global_mouse_position() - position

func _process(delta):
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		var rel_mouse_pos : Vector2 = get_mouse_relpos()

		step_rotate(rel_mouse_pos,delta)
		
		var speed = max_speed * min(rel_mouse_pos.length(),speed_control_radius)/float(speed_control_radius)
		step_move_ahead(speed * delta)





func create_mask():
	var img = Image.new()
	var vp_diag_size = get_viewport_rect().size.length()
	img.create(vp_diag_size, vp_diag_size, false, Image.FORMAT_RGBA8)
	img.lock()
	
	# pixel that corresponds to player position
	var p = Vector2(img.get_width()/2,img.get_height()/2)
	
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
