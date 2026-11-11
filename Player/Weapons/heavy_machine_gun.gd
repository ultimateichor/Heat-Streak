extends Weapon


@export var slowest_interval := 0.4 
@export var fastest_interval := 0.05
@export var spin_up_time := 2.0  
@export var spin_down_time := 3.0  
@export var heatUpTime = 3
@export var coolDownTime = 4
var spin := 0.0

var trigger_held := false

func _ready() -> void:
	weapon_id = get_parent().name + "/" + name
	$Timer.wait_time = heatUpTime
	$Timer2.wait_time = coolDownTime

func _physics_process(delta: float) -> void:
	if trigger_held and $Timer2.time_left == 0:
		spin = minf(spin + delta / spin_up_time, 1.0)
		if fire_rate < 0.1:
			$Timer.start()
		else:
			$Timer.stop()
	else:
		spin = maxf(spin - delta / spin_down_time, 0.0)
	trigger_held = false


func _try_fire(just_pressed: bool) -> void:
	if $Timer2.time_left == 0:
		trigger_held = true
		var bonus := GameManager.get_weapon_upgrade(weapon_id, "fire_rate")
		fire_rate = maxf(lerpf(slowest_interval, fastest_interval, spin) + bonus, 0.02)
		super._try_fire(just_pressed)


func _on_timer_timeout() -> void:
	$Timer2.start()
	spin = 0
