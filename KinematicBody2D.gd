extends KinematicBody2D
#initialize varaibles
var vel = Vector2()
var vspd = 0
var hspd = 0
var dir = 0
var input_dir = 0

#access sprite
onready var sprite = get_node("Player_Sprite")
onready var wallLeft_signal = get_node("wallLeft_signal")
onready var wallRight_signal = get_node("wallRight_signal")


#initialize constant variable (fixed)
const JUMPSPEED = 850
const ACCELERATION = 50
const FRICTION = 40
const AIR_RESISTANCE = 20
const MAX_SPEED = 500
const NORMAL_FORCE = Vector2(0,-1)
const GRAVITY = 50
const WALL_SLIDE = 25
const TERMINAL_VELOCITY = 2500
const LOW_JUMPSPEED = 400

#initialize all objects
func _ready():
	set_physics_process(true)
	set_process_input(true)
	pass


#input events
func _input(event):
	pass

	
func _physics_process(delta):
	#wall jump
	var on_wallLeft = wallLeft_signal.is_colliding()
	var on_wallRight = wallRight_signal.is_colliding()
	
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
	#Animate the player
	#walking right
	if input_dir == 1 and vspd >= 0:
		sprite.flip_h = false
	#walking left
	elif input_dir == -1 and vspd >= 0:
		sprite.flip_h = true
	#jumping down
	if not is_on_floor() and vel.y > 0:
		sprite.animation = "Jump-down"
		#This adds some air drag. Fixes the issue with dropping too fast
		vspd -= AIR_RESISTANCE
	#jumping up
	elif vel.y < 0:
		sprite.animation = "Jump-up"
	#running
	elif vel.y == 0 and vel.x != 0:
		sprite.animation = "Running"
	#idle
	else:
		sprite.animation = "Idle"

	#activate hspd if there's input
	if input_dir != 0:
		hspd += ACCELERATION
	else:
		hspd -= FRICTION 

	#max speed, as well as constant acceleration on player
	hspd = clamp(hspd,0,MAX_SPEED)

	#don't want the player to constantly accelerate even on floor
	if not is_on_floor():
		vspd += GRAVITY

	#Terminal Velocity reached
	if vspd >= TERMINAL_VELOCITY:
		vspd = TERMINAL_VELOCITY

	#jump is the player is on floor, if there's a ceiling, apply newton's third law
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		vspd = -JUMPSPEED
	elif is_on_ceiling():
		vspd = GRAVITY

	#Inertia for sudden turning
	if input_dir == -dir:
		hspd = 0
	
	if on_wallLeft and not is_on_floor():
		vel.x = -hspd
		vspd = -JUMPSPEED
	elif on_wallRight and not is_on_floor():
		vel.x = -hspd
		vspd = -JUMPSPEED
	
	#Horizontal motion for the x component and vertical for y
	vel.x = hspd * dir
	vel.y = vspd 

	#move using linear velocity only
	vel = move_and_slide(vel,NORMAL_FORCE)
	pass 
