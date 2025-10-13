extends RefCounted
class_name PickGroup


var name: String
var pick_count_limit: int
var picked_picks: Array[Pick]


func _init(_name: String, _pick_count_limit: int = 1) -> void:
	name = _name
	pick_count_limit = _pick_count_limit
	picked_picks = []
	
		
func pick(target: Pick) -> void:
	if not picked_picks.has(target):
		if pick_count_limit <= 0 or picked_picks.size() < pick_count_limit:
			var pick_index: int = picked_picks.size()
			picked_picks.append(target)
			target.pick(pick_index)
	elif target.cancel_on_repick:
		cancel(target)
			
			
func query_pick_index(target: Pick) -> int:
	return picked_picks.find(target)
			
			
func cancel(target: Pick) -> void:
	if picked_picks.has(target):
		picked_picks.erase(target)
		target.cancel()
		
		
func cancel_latest_pick() -> void:
	if picked_picks.size() > 0:
		cancel(picked_picks.back())
		
		
func clear():
	for p in picked_picks:
		p.cancel()
	picked_picks.clear()
