extends KinematicBody2D
#initialize varaibles
var vel = Vector2()
var vspd = 0
var hspd = 0
var dir = 0
var input_dir = 0
#flags
var wall_jump = false
var can_play = true
var fullscreen_mode = false
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
const WALL_JUMP_SPEED = 280

#initialize all objects
func _ready():
	set_physics_process(true)
	set_process_input(true)
	pass

#input events
func _input(event):
	
	pass
	
func _physics_process(delta):
	#layer of abstractions
	var walk_right = Input.is_action_pressed("ui_right")
	var walk_left = Input.is_action_pressed("ui_left")
	var jump_up = Input.is_action_just_pressed("ui_up")
	var jump_released = Input.is_action_just_released("ui_up")

	#raycast's variables
	var on_wallLeft = wallLeft_signal.is_colliding()
	var on_wallRight = wallRight_signal.is_colliding()
	
	#conditions, store previous dir for inertia in opposite direction as well as making so that it wouldn't stop immediately
	#see vel.y for more context. As Oppose to just input.dir the 
	if input_dir != 0:
		dir = input_dir

	#if player is not in air or is wall jumping
	if can_play:
		#Input direction
		if walk_right and not walk_left:
			input_dir = 1 
		elif walk_left and not walk_right:
			input_dir = -1
		elif walk_right and walk_left: 
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
	else:
		wall_jump = false
		can_play = true
		
	#Terminal Velocity reached
	if vspd >= TERMINAL_VELOCITY:
		vspd = TERMINAL_VELOCITY

	#jump is the player is on floor, if there's a ceiling, apply newton's third law
	if is_on_floor() and jump_up:
		vspd = -JUMPSPEED
	elif is_on_ceiling():
		vspd = GRAVITY
	#limits the player jump to a minimum
	if jump_released:
		if vspd < -LOW_JUMPSPEED:
			vspd = -LOW_JUMPSPEED
			
	#Inertia for sudden turning
	if input_dir == -dir:
		hspd = 0
	
	#checks if player is colliding with a wall
	if (on_wallLeft || on_wallRight) and jump_up and not is_on_floor():
		#if it is flagged
		if wall_jump:
			#propels the player up
			vspd = -JUMPSPEED
		#trigger flag
		wall_jump = true
		#remove control from player
		can_play = false
		#change direciont
		dir = -dir

	#Horizontal motion for the x component and vertical for y
	if wall_jump:
		hspd = 0
		input_dir = dir
		vel.x = WALL_JUMP_SPEED * -dir
		#this is the equivalent switch statement in gdscript
		match -dir:
			-1: sprite.flip_h = true
			1: sprite.flip_h = false
	else:
		#by default
		vel.x = hspd * dir
	#keybind/command script
	_game_commands()
	#proceed with wall jump
	vel.y = vspd 
	#move using linear velocity only
	vel = move_and_slide(vel,NORMAL_FORCE)
	pass 
	
	
	
	
#game commands
func _game_commands():
	#game command variables
	var escape = Input.is_action_just_pressed("ui_escape")
	var restart = Input.is_action_just_pressed("ui_restart")
	var fullscreen = Input.is_action_just_pressed("ui_fullscreen")
	#if player presses ESC
	if escape:
		get_tree().quit()
	#if player presses R
	if restart:
		get_tree().reload_current_scene()
	#if player played Ctrl-F
	if fullscreen and (fullscreen_mode==false): 
		fullscreen_mode = true
		OS.set_window_fullscreen(true)
	elif fullscreen and (fullscreen_mode==true):
		fullscreen_mode = false
		OS.set_window_fullscreen(false)
	pass
