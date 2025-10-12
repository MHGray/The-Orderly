extends Resource

class_name PatrolRoute

@export var points:PackedVector3Array #Probably markers
var index = 0

func get_closest_patrol_point(pos) -> Vector3:
	var closest_distance:float = 999999999
	var closest_point:Vector3 = points[0]
	for point:Vector3 in points:
		var distance = point.distance_squared_to(pos)
		if distance < closest_distance:
			closest_distance = distance
			closest_point = point
	index = points.find(closest_point)
	return closest_point

func get_furthest_patrol_point(pos) -> Vector3:
	var furthest_distance:float = 0
	var furthest_point:Vector3 = points[0]
	for point:Vector3 in points:
		var distance = point.distance_squared_to(pos)
		if distance > furthest_distance:
			furthest_distance = distance
			furthest_point = point
	index = points.find(furthest_point)
	return furthest_point
	
func get_random_patrol_point(_pos) -> Vector3:
	var ind = randi_range(0, points.size() -1)
	return points[ind]

func get_next_patrol_point() -> Vector3:
	index = posmod(index + 1, points.size())
	return points[index]

func get_previous_patrol_point() -> Vector3:
	index = posmod(index - 1, points.size())
	return points[index]
