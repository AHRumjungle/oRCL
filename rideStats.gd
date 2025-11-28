extends Control

var selectedRideID : int = -1

var itemListRef = []

func _ready() -> void:
	
	#remove existing info text
	$info.text = ""
	
	#Set item list scroll bar to be bigger
	#TODO Find better way to do this globaly. Themes?
	$rideLogs.get_v_scroll_bar().custom_minimum_size.x = 20
	
	if FS.returnDict.has("rideID"):
		selectedRideID = FS.returnDict["rideID"]
		FS.returnDict = {}
	
	updatePage()




func _on_back_button_button_down() -> void:
	get_tree().change_scene_to_file("res://app.tscn")
	pass # Replace with function body.


func _on_query_ride_button_down() -> void:
	FS.functionScene("res://queryRide.tscn")
	pass # Replace with function body.


func updatePage() -> void:
	if selectedRideID == -1:
		$queryRide.text = "No Ride Selected"
		return
	
	var query : String = "
	SELECT RideRef.name AS name, 
	RideRef.des AS des,
	RideRef.isCredit AS isCredit,
	Location.shortName AS locShortName,
	Location.name AS locName FROM 
	RideRef INNER JOIN Location ON 
	RideRef.location = Location.id WHERE 
	Rideref.id = "+ str(selectedRideID) +" LIMIT 1"
	
	if !DB.db.query(query):
		print("Ride Stats: Error on Ride Stats Querry")
		return
	
	var returnRide = DB.db.query_result[0]
	
	#Info Text
	
	var infoText = ""
	infoText += returnRide.name + "\n"
	infoText += returnRide.locName + "\n"
	infoText += returnRide.des + "\n\n"
	
	#Stats
	
	## Number of times ridden
	query = "SELECT COUNT(*) AS count FROM RCLog WHERE RClog.rideID = " + str(selectedRideID)
	
	if !DB.db.query(query):
		print("Ride Stats: Error on Ride Stats Querry")
		return
	
	infoText += "Times Ridden: " + str(DB.db.query_result[0]["count"]) + "\n"
	
	$queryRide.text = returnRide.name + " | " + returnRide.locShortName
	
	##Ride Rank
	
	query = "SELECT rideID, COUNT(*) AS count FROM RCLog rideID GROUP BY rideID ORDER BY count DESC"
	
	if !DB.db.query(query):
		print("Ride Stats: Error on Ride Stats Querry")
		return
	
	var rank = 1
	
	while(true):
		if(DB.db.query_result[rank - 1]["rideID"] == selectedRideID):
			break
		else:
			rank += 1
	
	infoText += "Ride Rank: #" + str(rank) + "\n"
	
	$info.text = infoText
	
	
	
	#Item list
	
	var logQuery : String = "SELECT RCLog.ID, 
	RCLog.date, 
	RideRef.name, 
	RCLog.note FROM 
	RCLog INNER JOIN RideRef ON RClog.rideID = RideRef.id WHERE
	RideRef.id LIKE " + str(selectedRideID) + " ORDER BY RCLog.id DESC"

	
	$rideLogs.clear()
	itemListRef.clear()
	
	if !DB.db.query(logQuery):
		print("Ride Stats: Error on Log Querry")
	
	#No Result
	if DB.db.query_result == []:
		$rideLogs.add_item("No Results")
		$rideLogs.set_item_disabled(0, true)
	
	for i in DB.db.query_result:
		print(i)
		itemListRef.append(int(i["id"]))
		
		var text : String = ""
		
		var DT = Time.get_datetime_dict_from_datetime_string(i["date"], false)
		
		text = text + str(DT["month"]) + "/" + str(DT["day"]) + "/" + str(DT["year"]) + " | "
		
		text = text + i["name"]
		
		#text = text + i["note"]
		
		$rideLogs.add_item(text)
	pass


func _on_ride_logs_item_selected(index: int) -> void:
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
