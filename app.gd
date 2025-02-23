extends Control




func _ready() -> void:
	
	
	#Change file select base directory
	if OS.get_name() in ["Android"]:
		$settingsWindow/changeDatabaseButton/FileDialog.root_subfolder = "/storage/emulated/0"
		$settingsWindow/changeDatabaseButton/FileDialog.use_native_dialog = false
	
	refreshAllList()
	
	#update query ride button
	updateSelectedRideButton()
	
	#Have the Feedback Label show the DB path only for the first run
	if DB.appStart == true:
		$feedbackLabel.add_theme_color_override("font_color", Color(0,255,0))
		$feedbackLabel.text = "Opened DB: " + DB.databasePath
		$feedbackLabel.visible = true
		$feedbackLabel/timer.start()
	
	DB.appStart = false
	pass 

#
#
#

func refreshAllList() -> void:
	#Updates the contents of all dropdowns
	
	var counter = 0

	
	#TODO Replace with query search window
	DB.db.query("SELECT RideRef.id, RideRef.name, Location.shortName AS shortLocName FROM RideRef INNER JOIN Location ON RideRef.location = Location.id LIMIT 10")
	
	
	#Add Ride Location
	$addRideWindow/addRideLoc.clear()
	
	DB.db.query("SELECT * FROM Location")
	
	counter = 0
	for i in DB.db.query_result:
		var name : String = str(DB.db.query_result[counter]["name"])
		var id : int = DB.db.query_result[counter]["id"]
		$addRideWindow/addRideLoc.add_item(name, id)
		counter = counter + 1
	pass


# Log Ride
func _on_log_ride_button_button_down() -> void:
	
	var rideID : String = str(DB.selectRideForLog)
	var date : String = Time.get_datetime_string_from_system()
	var note : String = str($logNotes.text)
	
	#A option of `-1` is none
	if rideID == "-1" or date == "":
		print("ERR null input")
		
		#Feedback label stuff
		$feedbackLabel.add_theme_color_override("font_color", Color(255,0,0))
		$feedbackLabel.text = "Empty Input"
		$feedbackLabel.visible = true
		$feedbackLabel/timer.start()
		
		return
	
	var query : String = "INSERT INTO RClog (\"rideID\", \"date\", \"note\") VALUES ("+ rideID +", \""+ date +"\", \""+ note +"\")"
	
	if !DB.db.query(query):
		print("ERR on logRide query")
		#Feedback label stuff
		$feedbackLabel.add_theme_color_override("font_color", Color(255,0,0))
		$feedbackLabel.text = "Query Error"
		$feedbackLabel.visible = true
		$feedbackLabel/timer.start()
	else:
		print("Logged Ride at " + date)
		
		#clear inputs
		$logNotes.clear()
		DB.selectRideForLog = -1
		updateSelectedRideButton()
		
		#Feedback label stuff
		$feedbackLabel.add_theme_color_override("font_color", Color(0,255,0))
		$feedbackLabel.text = "Logged Ride"
		$feedbackLabel.visible = true
		$feedbackLabel/timer.start()
	
	pass 



#
# Add Ride/Location Signels
#

# Add ride
func _on_add_ride_window_button_down() -> void:
	$addRideWindow.visible = true
	
	#clear inputs
	$addRideWindow/addRideName.clear()
	$addRideWindow/addRideDes.clear()
	$addRideWindow/addRideLoc.select(-1)
	$addRideWindow/isCreditButton.button_pressed = 1
	
	#hide label
	$addRideWindow/confLabel.visible = false
	
	#Enabel add button
	$addRideWindow/addRideButton.disabled = false
	pass


func _on_add_ride_window_close_requested() -> void:
	$addRideWindow.visible = false
	pass 

func _on_add_ride_button_button_down() -> void:
	
	var name : String = str($addRideWindow/addRideName.text)
	var des : String = str($addRideWindow/addRideDes.text)
	var locID : String = str($addRideWindow/addRideLoc.get_selected_id())
	var isCredit : String
	
	if $addRideWindow/isCreditButton.button_pressed == true:
		isCredit = "1"
	else:
		isCredit = "0"
	
	#print("ID: " + str($addRideWindow/addRideLoc.get_selected_id())) # Debug
	
	if name == "" or des == "" or locID == "-1":
		print("ERR null input")
		
		$addRideWindow/confLabel.text = "Cannot Have Blank Inputs"
		$addRideWindow/confLabel.visible = true
		return
	
	var query : String = "INSERT INTO RideRef (\"name\", \"des\", \"location\", \"isCredit\") VALUES (\""+ name +"\", \""+ des +"\", "+ locID +","+ isCredit +")"
	
	if !DB.db.query(query):
		print("ERR on add ride query")
		
		#update label
		$addRideWindow/confLabel.text = "Error adding ride"
		$addRideWindow/confLabel.visible = true
	else:
		#disable add button
		$addRideWindow/addRideButton.disabled = true
		
		$addRideWindow/confLabel.text = "Added Ride to DB"
		$addRideWindow/confLabel.visible = true
		
		refreshAllList()
	pass

func _on_back_button_button_down_ride_add_window() -> void:
	$addRideWindow.visible = false
	pass



#Add Location
func _on_add_location_window_button_button_down() -> void:
	#Rest input
	$addLocationWindow/addLocationFullName.clear()
	$addLocationWindow/addLocationShortName.clear()
	
	#Hide label
	$addLocationWindow/confLabel.visible = false
	
	#re-enable add button
	$addLocationWindow/addLocationButton.disabled = false
	
	$addLocationWindow.visible = true
	pass


func _on_add_location_window_close_requested() -> void:
	$addLocationWindow.visible = false
	pass



func _on_add_location_button_button_down() -> void:
	#add location to DB
	
	#check for empty inputs
	if $addLocationWindow/addLocationFullName.text == "" or $addLocationWindow/addLocationShortName.text == "":
		print("ERR empty input")
		$addLocationWindow/confLabel.text = "Cannot Have Blank Inputs"
		$addLocationWindow/confLabel.visible = true
		return
	
	
	#cursed long query
	var query : String = "INSERT INTO \"Location\" (\"name\", \"shortName\") VALUES (\""+ str($addLocationWindow/addLocationFullName.text) +"\", \"" + str($addLocationWindow/addLocationShortName.text) + "\");"
	
	if !DB.db.query(query):
		print("ERR add location query")
		
		#update label
		$addLocationWindow/confLabel.text = "Error Adding Location"
		$addLocationWindow/confLabel.visible = true
	else:
		#update label
		$addLocationWindow/confLabel.text = "Location Added"
		$addLocationWindow/confLabel.visible = true
	
		#update options
		refreshAllList()
		
		#disable add button
		$addLocationWindow/addLocationButton.disabled = true
	pass 


func _on_back_button_button_down_add_location() -> void:
	$addLocationWindow.visible = false
	pass


#
#
#

func _on_browse_logs_button_button_down() -> void:
	get_tree().change_scene_to_file("res://browseLog.tscn")
	pass

#

func _on_label_timer_timeout() -> void:
	$feedbackLabel.visible = false
	pass


func _on_stats_button_button_down() -> void:
	get_tree().change_scene_to_file("res://stats.tscn")
	pass

#Query Ride Button
func _on_query_ride_button_down() -> void:
	get_tree().change_scene_to_file("res://queryRide.tscn")
	pass

func updateSelectedRideButton():
	
	if DB.selectRideForLog == -1:
		$queryRide.text = "No Ride Selected"
		return
	
	
	var id : String = str(DB.selectRideForLog)
	
	var query : String = "SELECT RideRef.name, Location.shortName AS locShortName FROM RideRef INNER JOIN Location ON RideRef.location = Location.id WHERE Rideref.id = "+ id +" LIMIT 1"
	
	if !DB.db.query(query):
		print("ERR on updateQueryRideButton")
	
	var text : String = ""
	
	text += DB.db.query_result[0]["name"]
	text += " | "
	text += DB.db.query_result[0]["locShortName"]
	
	$queryRide.text = text
	pass
