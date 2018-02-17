extends KinematicBody2D
#initialize varaibles
var vel = Vector2()
var vspd = 0
var hspd = 0
var dir = 0
var input_dir = 0

#access sprite
onready var sprite = get_node("Player_Sprite")

#initialize constant variable (fixed)
const JUMPSPEED = 850
const ACCELERATION = 50
const FRICTION = 40
const MAX_SPEED = 500
const NORMAL_FORCE = Vector2(0,-1)
const GRAVITY = 50
const TERMINAL_VELOCITY = 2500

#initialize all objects
func _ready():
	set_physics_process(true)
	set_process_input(true)

#input events
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

	#animate the player
	if input_dir == 1:
		sprite.flip_h = false
	elif input_dir == -1:
		sprite.flip_h = true
	if not is_on_floor() and vel.y > 0:
		sprite.animation = "Jump-down"
	elif vel.y < 0:
		sprite.animation = "Jump-up"
	elif vel.y == 0 and vel.x != 0:
		sprite.animation = "Running"
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

	#jump is the player is on floor, if there's a ceiling repulse the player
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		vspd = -JUMPSPEED
	elif is_on_ceiling():
		vspd = GRAVITY
	
	#Inertia for sudden turning
	if input_dir == -dir:
		hspd /= 10
	
	#Horizontal motion for the x component and vertical for y
	vel.x = hspd * dir
	vel.y = vspd 

	#move using linear velocity only
	vel = move_and_slide(vel,NORMAL_FORCE)
	pass 
