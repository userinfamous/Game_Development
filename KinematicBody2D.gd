extends KinematicBody2D
#initialize varaibles
var vel = Vector2()
var vspd = 0
var hspd = 0
var dir = 0
var input_dir = 0

#initialize constant variable (fixed)
const JUMPSPEED = 850
const ACCELERATION = 100
const FRICTION = 38
const MAX_SPEED = 500
const NORMAL_FORCE = Vector2(0,-1)
const GRAVITY = 50
const TERMINAL_VELOCITY = 1000

func _ready():
	set_physics_process(true)
	set_process_input(true)

func _input(event):
	pass

	
func _physics_process(delta):
	#conditions, store previous dir for inertia in opposite direction as well as making so that it wouldn't stop immediately
	#see vel.y for more context. As Oppose to just input.dir the 
	if input_dir != 0:
		dir = input_dir
	
	#Input direction
	if Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
		input_dir = 1 
	elif Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
		input_dir = -1
	elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"): 
		input_dir = 0
	else:
		input_dir = 0


	#activate hspd if there's input
	if input_dir != 0:
		hspd += ACCELERATION
	else:
		hspd -= FRICTION 

	#max speed, as well as constant acceleration on player
	hspd = clamp(hspd,0,MAX_SPEED)
	vspd += GRAVITY

	#Terminal Velocity reached
	if vspd >= TERMINAL_VELOCITY:
		vspd = TERMINAL_VELOCITY

	#jump
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		vspd = -JUMPSPEED
	
	#Inertia
	if input_dir == -dir:
		hspd /= 10
	
	#Horizontal motion for the x component and vertical for y
	vel.x = hspd * dir
	vel.y = vspd 

	#move using linear velocity only
	move_and_slide(vel,NORMAL_FORCE)
	pass 
