extends Area2D

signal collected

const ACCEL_MULTI = 100
const CIRCULAR_TIME = 2
const _AM_END_TRI = 25
const ORBIT_RADIUS = 150.0
const ORBIT_SPEED = 1.0

enum State { FLOATING, LUNGING, ORBITING, COLLECTED }
var current_state: State = State.FLOATING

var velocity: Vector2
var accel: Vector2
var orbit_angle: float = 0.0
var screen_center: Vector2

var lunge_target_pos: Vector2

var snapped_player: Player = null

@onready var Circulars = $Circulars
@onready var AnimPlayer = $AnimationPlayer


func _ready():
    screen_center = get_viewport_rect().size / 2.0
    position = Vector2(1200, randf_range(0, 600))
    velocity = Vector2(randf_range(-250, -150), randf_range(-100, 100))
    accel = Vector2(randf_range(-1, 1), randf_range(-1, 1))

    var __ = create_tween().set_loops().tween_property(Circulars, "rotation", TAU, CIRCULAR_TIME).from(0.0)


func _process(delta):
    match current_state:
        State.FLOATING:
            _process_floating(delta)

        State.LUNGING:
            _process_lunging(delta)

        State.ORBITING:
            _process_orbiting(delta)

        State.COLLECTED:
            if is_instance_valid(snapped_player):
                snapped_player.global_position = global_position

func _process_floating(delta):
    position += velocity * delta
    velocity += ACCEL_MULTI * delta * accel
    if not TS.DESPAWN_AREA.has_point(position):
        var players: Array = GameMethods.get_players()
        if players.size() > 0:
            var target: Player = players[randi() % players.size()]
            lunge_target_pos = target.position
            velocity = position.direction_to(lunge_target_pos) * 500.0
            current_state = State.LUNGING


func _process_lunging(delta):
    position += velocity * delta
    var distance_to_center = position.distance_to(screen_center)
    if distance_to_center <= ORBIT_RADIUS:
        start_orbit()


func _process_orbiting(delta):
    orbit_angle += ORBIT_SPEED * delta
    var offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * ORBIT_RADIUS
    position = screen_center + offset

func start_orbit():
    orbit_angle = screen_center.direction_to(position).angle()
    current_state = State.ORBITING


func trigger_collection(player: Player):
    current_state = State.COLLECTED
    set_deferred("monitoring", false)
    set_deferred("monitorable", false)

    snapped_player = player
    snapped_player.global_position = global_position

    if snapped_player.has_method("set_physics_process"):
        snapped_player.set_physics_process(false)
    if snapped_player.has_method("set_process"):
        snapped_player.set_process(false)

    if "velocity" in snapped_player:
        snapped_player.velocity = Vector2.ZERO

    Circulars.hide()
    AnimPlayer.play("Collect")


func triangle_collected():
    if is_instance_valid(snapped_player):
        if snapped_player.has_method("set_physics_process"):
            snapped_player.set_physics_process(true)
        if snapped_player.has_method("set_process"):
            snapped_player.set_process(true)

    GameMethods.screen_flash(0.5)
    emit_signal("collected")
    queue_free()


func _on_EndTriangle_area_entered(area):
    if area is Player and current_state != State.COLLECTED:
        trigger_collection(area)
