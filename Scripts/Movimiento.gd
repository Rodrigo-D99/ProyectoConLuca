extends Node

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0
@export var DECEL: float = 800.0  # fuerza de frenado

@onready var player: CharacterBody2D = null

func _ready() -> void:
	player = get_parent() as CharacterBody2D
	assert(player != null, "Movement debe ser hijo directo de un CharacterBody2D (Player).")

# Recibe la velocity actual y devuelve la nueva velocity (no hace move_and_slide aquí)
func compute_velocity(current_velocity: Vector2, delta: float) -> Vector2:
	var v := current_velocity

	# gravedad usando el player (CharacterBody2D)
	if not player.is_on_floor():
		v += player.get_gravity() * delta

	# salto
	if Input.is_action_just_pressed("salto") and player.is_on_floor():
		v.y = JUMP_VELOCITY

	# input horizontal (-1..1)
	var direction := Input.get_axis("izq", "der")
	if direction != 0:
		v.x = direction * SPEED
	#elif Input.is_action_just_pressed("correr"):
	#	v.x = direction * SPEED*2
	else:
		v.x = move_toward(v.x, 0, DECEL * delta)

	return v

# utilidad para animación/flip: devuelve -1/0/1
func get_input_direction() -> int:
	var d = Input.get_axis("izq", "der")
	if d > 0: return 1
	if d < 0: return -1
	return 0
