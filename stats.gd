extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateStats()
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://app.tscn")
	pass

#
#
#
func updateStats() -> void:
	var text : String = ""
	
	DB.db.query("SELECT * FROM RClog")

	if DB.db.query_result == []: #Check for nothing
		print("No Data")
		$statsLabel.text = "No Data in DB"
		return

	#Calculate Credit Count
	var creditQuery : String = """
	SELECT COUNT(DISTINCT rideID) AS credits FROM RCLog 
	INNER JOIN RideRef ON RCLog.rideID = RideRef.id 
	WHERE RideRef.isCredit = 1
	"""
	
	if !DB.db.query(creditQuery):
		onStatsError("ERR on creditQuery")
		return
	
	var credits : String = str(DB.db.query_result[0]["credits"])
	
	text += "Credit Count: " + credits + "\n\n"
	
	
	# Calculate total number of logs
	var totalLogsQuery : String = "SELECT COUNT(*) as logCount FROM RClog"
	
	if !DB.db.query(totalLogsQuery):
		onStatsError("ERR on totalLogsQuery")
		return
	
	var totalLogs : String = str(DB.db.query_result[0]["logCount"])
	
	text += "Total Logs: " + totalLogs + "\n\n"
	
	
	# Calculate most ridden ride
	var mostRidenQuery : String = """
	SELECT rideID, COUNT(*) AS count FROM RCLog 
	GROUP BY rideID 
	ORDER BY count DESC LIMIT 1
	"""
	
	if !DB.db.query(mostRidenQuery):
		onStatsError("ERR on mostRidenQuery")
		return
	
	var rideID : int = DB.db.query_result[0]["rideID"]
	var rideCount : int = DB.db.query_result[0]["count"]
	
	
	#get ride name
	var getRideName : String = """
	SELECT RideRef.name, Location.shortName AS locShort FROM RideRef 
	INNER JOIN Location ON RideRef.location = Location.id 
	WHERE RideRef.id = 
	""" + str(rideID)
	
	if !DB.db.query(getRideName):
		print("ERR on getRideName")
		return
	
	var rideName : String = DB.db.query_result[0]["name"]
	var locShort : String = DB.db.query_result[0]["locShort"]
	
	text += "Most Ridden Ride: " + rideName +  " | " + locShort + "\n"
	text +="Ride Count: " + str(rideCount)
	text += "\n\n"
	
	
	#Get Most Visted Location
	#Finds the location with the most distinct dates
	var mostVistLoc : String = """
	SELECT count(DISTINCT strftime('%Y-%m-%d', date)) as count, Location.name FROM RCLog 
	INNER JOIN RideRef ON RCLog.rideID = RideRef.id 
	INNER JOIN Location ON RideRef.location = Location.id 
	GROUP BY location.name ORDER BY count DESC
	"""
	
	text += "Most Visited Location: "
	
	if DB.db.query(mostVistLoc):
		text+= DB.db.query_result[0]["name"] + "\n"
		text+= "Times Visted: " + str(DB.db.query_result[0]["count"])
	else:
		onStatsError("ERR on mostVistLoc query")
		return
	
	text += "\n\n"
	
	#TODO
	# Longets Marathon
	# Finds the Ride with the most adjacent date/time/entery
	
	$statsLabel.text = text
	pass
#
#
#
func onStatsError(errorText : String):
	print(errorText)
	$statsLabel.text = "ERROR:\n" + errorText
	pass
