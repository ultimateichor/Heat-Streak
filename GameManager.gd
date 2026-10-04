extends Node

var player: Player

var currentGameSpeed: float = 0
var defaultGameSpeed: float = 0.5
var shouldSpeedUp: bool = true

var gameStarted: bool = false
var readyToStart: bool = false

var useHim = false

var highScore : int

const ROBOT_SCENE := "res://Player/Player.tscn"
const VEHICLE_SCENES := [
	"res://Player/Vehicles/Car.tscn","res://Player/Vehicles/Heli.tscn","res://Player/Vehicles/Heli.tscn","res://Player/Vehicles/Heli.tscn"
]

var unlocked_vehicles: Array[int] = [0,1]
var selected_vehicle := 0


func _process(_delta: float) -> void:
	pass

func _start_game():
	gameStarted = true

func _end_game():
	gameStarted = false
	readyToStart = false
	currentGameSpeed = 0
	
func _unlock_vehicle(index: int) -> void:
	if index not in unlocked_vehicles:
		unlocked_vehicles.append(index)

func _select_vehicle(index: int) -> void:
	if index in unlocked_vehicles:
		selected_vehicle = index

func load_images_from_dir(path: String, outArray: Array) -> void:
	if not path.ends_with("/"):
		path += "/"
		
	if DirAccess.dir_exists_absolute(path):
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			
			while file_name != "":
				# Ignore directories and hidden/dot files
				if not dir.current_is_dir() and not file_name.begins_with("."):
					if file_name.ends_with(".remap"):
						file_name = file_name.trim_suffix(".remap")
					if file_name.ends_with(".import"):
						file_name = file_name.trim_suffix(".import")
					# Check for common image extensions
					var ext = file_name.get_extension().to_lower()
					if ext in ["png", "jpg", "jpeg", "svg", "webp"]:
						var full_path = path + file_name
						var texture = load(full_path)
						if texture:
							outArray.append(texture)
							
				file_name = dir.get_next()
			dir.list_dir_end()
			print("Successfully loaded ", outArray.size(), " images.")
		else:
			print("An error occurred when trying to access the path.")
	else:
		print("Path does not exist: ", path)
