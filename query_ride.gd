extends Control

var itemListRef = []

func _on_back_button_button_down() -> void:
	get_tree().change_scene_to_file("res://app.tscn")
	pass 


func _ready() -> void:
	# Reset Inputs
	$searchText.text = ""
	$itemList.clear()
	
	#init search to show all rides
	_on_search_button_button_down()
	
	#Increase scroll bar, see brows_logs.gd for more info
	$itemList.get_v_scroll_bar().custom_minimum_size.x = 20
	#$itemList.fixed_column_width = $itemList.fixed_column_width - 20 
	
	pass


func _on_search_button_button_down() -> void:
	searchRide()

func _on_search_text_text_submitted(new_text: String) -> void:
	searchRide()

func searchRide() -> void:
	var search : String = str($searchText.text) 
	
	
	
	var query : String = "SELECT RideRef.id, RideRef.name, Location.shortName AS locShortName FROM RideRef INNER JOIN Location ON RideRef.location = Location.id"
	query += " WHERE RideRef.name LIKE \"%"+ search + "%\""
	query += " OR Location.name LIKE \"%"+ search + "%\""
	query += " OR Location.shortName LIKE \"%"+ search + "%\""
	
	if !DB.db.query(query):
		print("ERR on rideQuery Search")
	
	print(DB.db.query_result)
	
	#clear item list and ref
	$itemList.clear()
	itemListRef.clear()
	
	if DB.db.query_result == []: #No results
		$itemList.add_item("No Results")
		$itemList.set_item_disabled(0, true)
		return
	
	#Fill Item List
	for i in DB.db.query_result:
		var text : String = ""
		
		text += i["name"]
		text += " | "
		text += i["locShortName"]
		
		$itemList.add_item(text)
		
		itemListRef.append(int(i["id"]))
	pass


func _on_item_list_item_selected(index: int) -> void:
	DB.selectRideForLog = itemListRef[index]
	get_tree().change_scene_to_file("res://app.tscn")
	pass
