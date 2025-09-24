extends CharacterBody2D

@onready var movement_comp = $Movimiento
@onready var dash_comp = $Dash
@onready var anim_player = $AnimationPlayer
@onready var sprite2d = $Sprite2D

func _physics_process(delta: float) -> void:
	# Si dash está activo, deja que dash mueva (o cambia según tu dash)
	if dash_comp and dash_comp.is_dashing():
		# en esta variante, DASH se encarga del movimiento (ej: move_and_collide dentro del dash)
		# opcional: anim de dash
		if anim_player and anim_player.has_animation("dash"):
			anim_player.play("dash")
		return

	# si no hay dash, calculamos la velocity con movement y movemos aquí
	velocity = movement_comp.compute_velocity(velocity, delta)
	move_and_slide()

	# anim & flip
	var direction = movement_comp.get_input_direction()
	if direction == 1:
		sprite2d.flip_h = false
	elif direction == -1:
		sprite2d.flip_h = true

	# anim state simple
	_play_movement_animation(direction)

	# input dash
	if Input.is_action_just_pressed("dash") and dash_comp and dash_comp.can_dash():
		var move_dir = Vector2(Input.get_axis("izq","der"), 0)
		dash_comp.try_dash(move_dir, position)

func _play_movement_animation(direction: int) -> void:
	if anim_player == null:
		return
	if not is_on_floor():
		if anim_player.has_animation("salto"):
			anim_player.play("salto")
	else:
		if direction == 0:
			if anim_player.has_animation("idle"):
				anim_player.play("idle")
		else:
			if anim_player.has_animation("caminar"):
				anim_player.play("caminar")
