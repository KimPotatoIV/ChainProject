extends Node2D

##################################################
const SCREEN_SIZE: Vector2 = Vector2(1920.0, 1080.0)
const POINT_COUNT: int = 192
const BASE_Y_POSITION: float = 310.0
const RESTORE_FORCE: float = 50.0
const DAMPING: float = 0.98
const SPREAD: float = 0.1

var splash_timer: Timer
var line_node: Line2D
var polygon_node: Polygon2D
var poison_points_y_position: Array = []
var poison_points_velocity: Array = []

##################################################
func _ready() -> void:
	splash_timer = $SplashTimer
	splash_timer.connect("timeout", Callable(self, "_on_splash_timer_timeout"))
	splash_timer.wait_time = 0.1
	splash_timer.one_shot = true
	splash_timer.start()
	line_node = $Line2D
	polygon_node = $Polygon2D
	
	init_poison()

##################################################
func _process(delta: float) -> void:
	apply_points_physics(delta)
	draw_poison()

##################################################
func _on_splash_timer_timeout() -> void:
	var index_value = randi_range(0, POINT_COUNT - 1)
	var force_value = randf_range(0.0, 75.0)
	
	force_value = min(force_value, 200)
	
	poison_points_velocity[index_value] += force_value
	
	if index_value > 1:
		poison_points_velocity[index_value - 1] += force_value * 0.75
		poison_points_velocity[index_value - 2] += force_value * 0.5
	if index_value < POINT_COUNT - 2:
		poison_points_velocity[index_value + 1] += force_value * 0.75
		poison_points_velocity[index_value + 2] += force_value * 0.5
	
	splash_timer.start()

##################################################
func init_poison() -> void:
	for i in range(POINT_COUNT):
		poison_points_y_position.append(BASE_Y_POSITION)
		poison_points_velocity.append(0)

##################################################
func apply_points_physics(delta) -> void:
	for i in range(POINT_COUNT):
			poison_points_y_position[i] += poison_points_velocity[i] * delta
			
			var force = (BASE_Y_POSITION - poison_points_y_position[i]) * RESTORE_FORCE
			poison_points_velocity[i] += force * delta
			poison_points_velocity[i] *= DAMPING
	
	var new_positions: Array = poison_points_y_position.duplicate()
	for i in range(1, POINT_COUNT - 1):
		new_positions[i] += \
			(poison_points_y_position[i - 1] - poison_points_y_position[i]) * SPREAD
	
	for i in range(1, POINT_COUNT - 1):
		poison_points_y_position[i] = new_positions[i]

##################################################
func draw_poison() -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var segment_width: float = SCREEN_SIZE.x / (POINT_COUNT - 1)
	
	for i in range(POINT_COUNT):
		points.append(Vector2(i * segment_width, poison_points_y_position[i]))
		
	line_node.points = points
	line_node.width = 2.0
	line_node.default_color = Color(0, 0.75, 0.25, 1)
	
	points.append(SCREEN_SIZE)
	points.append(Vector2(0.0, SCREEN_SIZE.y))
	polygon_node.polygon = points
	polygon_node.color = Color(0, 0.25, 0.05, 1)
