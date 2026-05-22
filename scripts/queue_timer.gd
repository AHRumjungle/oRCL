extends Control

var queueEnterTime

var DTKey = "queueStartTime"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if DB.persistant == null:
		printerr("No Persistant Object")
		return
	
	print(DB.persistant)
	
	if DB.persistant.has(DTKey):
		$updateTimer.start()

		$TabContainer/stats/queueEnterTime.text  = convertTimeStringToHMS(DB.persistant[DTKey], "Entered: ", "hm")
		


func updateTime():
	print("UPDATE!")
	
	var currentTime = Time.get_datetime_dict_from_system()
	var startTime = Time.get_datetime_dict_from_datetime_string(DB.persistant[DTKey], false)
	
	#TODO Fix negative time bug
	
	var delta : Dictionary
	
	for n in ["hour", "minute", "second"]:
		delta[n] = currentTime[n] - startTime[n]
	$TabContainer/stats/timeWaited.text = convertTimeStringToHMS(delta, "Waited: ", "hms")


func convertTimeStringToHMS(t, pre: String, hms: String) -> String:
	var timeString = pre
	var timeDic
	if(t is String):
		timeDic = Time.get_datetime_dict_from_datetime_string(t, false)
	else:
		timeDic = t
	
	if(hms.contains("h")):
		timeString += "%02d:" % [timeDic["hour"]]
	if(hms.contains("m")):
		timeString += "%02d" % [timeDic["minute"]]
	if(hms.contains("s")):
		timeString += ":%02d" % [timeDic["second"]]

	return timeString

func _on_start_queue_button_button_down() -> void:
	DB.persistant[DTKey]  = Time.get_datetime_string_from_system()
	$TabContainer/stats/queueEnterTime.text  = convertTimeStringToHMS(DB.persistant[DTKey], "Entered: ", "hm")
	$updateTimer.start()
	updateTime()
	DB.savePersistantFile()
