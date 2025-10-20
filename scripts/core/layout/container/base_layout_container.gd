extends Node2D
class_name BaseLayoutContainer


var content_elements: Array[LayoutElement] = []


func add(content_element: LayoutElement, should_update_layout: bool=true) -> void:
	if content_element not in content_elements:
		content_elements.append(content_element)
		if should_update_layout:
			update_layout()
	
	
func remove(content_element: LayoutElement, should_update_layout: bool=true) -> void:
	if content_element in content_elements:
		content_elements.erase(content_element)
		if should_update_layout:
			update_layout()


func update_layout() -> void:
	var i: int = 0
	for content_element in content_elements:
		update_element_layout(content_element, i)
		i += 1

	
func update_element_layout(_content_element: LayoutElement, _index: int) -> void:
	pass

