extends Control

var itemListRef = []

func _ready() -> void:
	#init search to show all logs
	_on_search_button_button_down()
	
	#Set item list scroll bar to be bigger
	#TODO Find better way to do this globaly. Themes?
	$itemList.get_v_scroll_bar().custom_minimum_size.x = 20
	
	#Adjust margins so text is not covered
	#$itemList.fixed_column_width = $itemList.fixed_column_width - 20 
	
	pass

func _on_back_button_button_down() -> void:
	get_tree().change_scene_to_file("res://app.tscn")
	
	#Close popup if up
	$moreInfoWindow.visible = false
	pass

#
# Main Search
#
func _on_search_button_button_down() -> void:
	searchLogs()

func _on_search_text_text_submitted(new_text: String) -> void:
	searchLogs()


func searchLogs() -> void:
	var searchBox : String = str($searchText.text)
	
	var query : String = "SELECT RCLog.ID, RCLog.date, RideRef.name, RCLog.note FROM RCLog INNER JOIN RideRef ON RClog.rideID = RideRef.id WHERE RideRef.name LIKE \"%"+ searchBox +"%\""
	
	#Date
	query = query + " OR RCLog.date LIKE \"%"+ searchBox +"%\""
	
	#Note
	if $searchNotesCheck.button_pressed:
		query = query + " OR RCLog.note LIKE \"%"+ searchBox +"%\""
	
	#Deced by most recent date
	query += "ORDER BY RClog.date DESC"
	
	
	if !DB.db.query(query):
		print("ERR in Log Search")
	
	#Clear List
	$itemList.clear()
	itemListRef.clear()
	
	#No Result
	if DB.db.query_result == []:
		$itemList.add_item("No Results")
		$itemList.set_item_disabled(0, true)
	
	for i in DB.db.query_result:
		print(i)
		itemListRef.append(int(i["id"]))
		
		var text : String = ""
		
		var DT = Time.get_datetime_dict_from_datetime_string(i["date"], false)
		
		text = text + str(DT["month"]) + "/" + str(DT["day"]) + "/" + str(DT["year"]) + " | "
		
		text = text + i["name"]
		
		#text = text + i["note"]
		
		$itemList.add_item(text)
	pass

#
#More Info Popup
#
func _on_item_list_item_selected(index: int) -> void:
	
	var sqlID = itemListRef[index]
	#Query for more info
	print("Selected Index: " + str(sqlID))
	
	var query : String = "SELECT RClog.date, RideRef.name, RCLog.note, RideRef.des, Location.name AS locName FROM RCLog INNER JOIN Location ON RideRef.location = Location.id INNER JOIN RideRef ON RClog.rideID = RideRef.id WHERE RCLog.id = " + str(sqlID)
	
	
	
	if !DB.db.query(query):
		print("ERR on itemTable Select")
		return
	
	print(DB.db.query_result)
	
	var qResult = DB.db.query_result[0]
	var dText : String = ""
	
	dText += "Ride: " + str(qResult["name"]) + "\n"
	dText += "Ride Description: " + str(qResult["des"]) + "\n"
	dText += "Date and Time Logged: " + str(qResult["date"]) + "\n"
	dText += "Ride Location: " + str(qResult["locName"]) + "\n\n"
	dText += "Note: " + str(qResult["note"])
	
	$moreInfoWindow.dialog_text = dText
	
	$moreInfoWindow.visible = true
	pass # Replace with function body.


func _on_more_info_window_confirmed() -> void:
	$moreInfoWindow.visible = false
	pass # Replace with function body.
