# res://scripts/dash.gd
extends Node
class_name DashComponent   # opcional: hace la clase accesible globalmente

@export var dash_mode: String = "movement"  # "movement" o "blink"
@export var dash_speed: float = 1200.0
@export var dash_duration: float = 0.18
@export var dash_distance: float = 160.0
@export var dash_cooldown: float = 0.6
@export var enemy_group: String = "enemies"  # grupo usado por los enemigos

signal dash_started(pos: Vector2)
signal dash_ended(pos: Vector2)
signal dash_hit_enemy(enemy: Node, collision: Dictionary)  # emite si choca con enemy

var _is_dashing: bool = false
var _dash_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _dash_dir: Vector2 = Vector2.ZERO
var _player: CharacterBody2D = null

func _ready() -> void:
	_player = get_parent() as CharacterBody2D
	assert(_player != null, "DashComponent debe ser hijo de un CharacterBody2D (Player).")

func _physics_process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer = max(0.0, _cooldown_timer - delta)

	if _is_dashing:
		_dash_timer -= delta
		# MOVIMIENTO por pasos: usamos move_and_collide en el player para detectar colisiones exactas
		var step_velocity = _dash_dir * dash_speed * delta
		var collision = _player.move_and_collide(step_velocity)
		if collision:
			var collider = collision.get_collider()
			# si el objeto con el que colisionamos está en el grupo 'enemies', emitimos señal
			if collider and collider.is_in_group(enemy_group):
				emit_signal("dash_hit_enemy", collider, collision)
				# opcional: si querés detener dash al chocar:
				# _end_dash()
			else:
				# si choca con paredes u otras cosas, podemos detener el dash:
				_end_dash()
		if _dash_timer <= 0.0:
			_end_dash()

func try_dash(dir: Vector2, position: Vector2 = Vector2.INF) -> void:
	if _cooldown_timer > 0.0 or _is_dashing:
		return
	if dir == Vector2.ZERO:
		if position != Vector2.INF:
			dir = (position - _player.global_position).normalized()
		else:
			dir = Vector2.RIGHT
	_dash_dir = dir.normalized()
	_start_dash()

func _start_dash() -> void:
	_is_dashing = true
	_dash_timer = dash_duration
	_cooldown_timer = dash_cooldown
	emit_signal("dash_started", _player.global_position)

func _end_dash() -> void:
	_is_dashing = false
	emit_signal("dash_ended", _player.global_position)

func can_dash() -> bool:
	return _cooldown_timer <= 0.0 and not _is_dashing

func is_dashing() -> bool:
	return _is_dashing
