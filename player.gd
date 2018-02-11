extends KinematicBody2D
#Local Variables
var input_dir = 0	#keywords dir->direction
var dir = 0
var hspd = 0	#hspd->horizonal speed component
var vspd = 0	#vspd->vertical speed component
var jspd = 800	#jspd->jump speed, is an impulsive force

#Global Variables
const GRAVITY = 2000
const TERMINAL_VELOCITY = 5600
const MAX_SPEED = 600
const MOMENTUM = 1000	#acceleration
const FRICTION = 2000 #friction
var vel = Vector2()	#velocity


func _ready():
	# Process function is below, for every frame
	set_process(true)
	set_process_input(true)
	pass
	
func _input(event):
	#In godot negative in y direction means it is up
	if event.is_action_pressed("move_up") and vspd == 0:
		vspd = -jspd
	pass

#Process is linked to time, code belows applies for every frame
func _process(delta):
	# Set direction for velocity for when the player isn't pressing anything
	if input_dir:
		dir = input_dir
	# If player presses right that'll be 1 and left will be 0, this is a shorter way for writing it
	input_dir = Input.is_action_pressed("move_right") - Input.is_action_pressed("move_left")
	#if input is same as direction value divide hspd by 3 to induce jetlag effect
	if input_dir == -dir:
		hspd /= 3
	#Add speed when there's input which will be add to velocity after direction is applied
	if input_dir:
		hspd += MOMENTUM * delta
	else:
		hspd -= FRICTION * delta
	#Max speed
	hspd = clamp(hspd,0,MAX_SPEED)
	vspd += GRAVITY * delta
	#reached terminal velocity
	if vspd >= TERMINAL_VELOCITY:
		vspd = TERMINAL_VELOCITY
	#Velocity of the last input direction
	vel.x = hspd * delta * dir
	vel.y = vspd * delta
	#Activating 2D vector
	var resultant_force = move(vel)
	#Basically finds the horizonal component, and slide off the surface with remaining net force
	if is_colliding():
		var normal_force = get_collision_normal()
		var net_force = normal_force.slide(resultant_force)
		vspd = normal_force.slide(Vector2(0, vspd)).y
		move(net_force)
	pass
