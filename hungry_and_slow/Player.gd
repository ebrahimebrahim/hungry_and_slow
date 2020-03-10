extends "Creature.gd"


var F   = 400
var DF  = 140
var B   = 50
var DB  = 50

var max_speed = 600
export var speed_control_radius = 400


func _ready():
#	create_mask()
	max_rot_speed = deg2rad(360*6)
	pass





func get_mouse_relpos() -> Vector2:
	return self.get_global_mouse_position() - position

func _physics_process(delta):
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		var rel_mouse_pos : Vector2 = get_mouse_relpos()

		step_rotate(rel_mouse_pos,delta)
		
		current_speed = max_speed * min(rel_mouse_pos.length(),speed_control_radius)/float(speed_control_radius)
		step_move_ahead()
	else:
		current_speed = 0

func _draw():
	if current_speed>0 : draw_speed_overlay()

func _process(delta):
	update() # drawing update

func draw_speed_overlay():
	draw_line(Vector2(),to_local(position+speed_control_radius*direction_vec.normalized()),Color(1,0,0),2)
	draw_line(Vector2(),to_local(position+(current_speed/max_speed)*speed_control_radius*direction_vec.normalized()),Color(0,1,1),4)




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
