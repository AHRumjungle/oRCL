extends Control

var queueEnterTime

var stateKey = "queueTimerState"
#State 0: Idel
#State 1: Timing
#State 2: Timer end, show stats
var DTKey = "queueStartTime"
var STKey = "queueStopTime"
var PKey = "queuePostedTime"


var timeWaitedColorState = {
	0: Color(0.8, 0.8, 0.8, 0.8), #Idle
	1: Color(1.0, 0, 0, 1), #In Queue
	2: Color(0.0, 1.0, 0, 1) #Post Queue
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	$TabContainer.current_tab = 0
	# Defualt tab to the stats
	
	
	if DB.persistant == null:
		printerr("No Persistant Object")
		return
	
	
	if DB.persistant.has(stateKey):
		
		updateTimeWaitedColor(timeWaitedColorState[int(DB.persistant[stateKey])])
		
		if(DB.persistant[stateKey] == 0):
			queueStats()
		if(DB.persistant[stateKey] == 1):
			if(DB.persistant.has(DTKey)):
				$updateTimer.start()
				updateTime()
				queueStats()
			else:
				DB.persistant[stateKey] = 0
				DB.savePersistantFile()
		if(DB.persistant[stateKey] == 2):
			queueStats()
	else:
		DB.persistant[stateKey] = 0
		DB.savePersistantFile()

####

func updateTime():
	#print("UPDATE!")
	
	var state = DB.persistant[stateKey]
	
	var currentTime = Time.get_datetime_dict_from_system()
	var startTime = Time.get_datetime_dict_from_datetime_string(DB.persistant[DTKey], false)
	
	var delta = timeDicDiff(currentTime, startTime)
	
	$TabContainer/stats/timeWaitedPanel/timeWaited.text = convertTimeStringToHMS(delta, "Waited: ", "hms")

####

func updateTimeWaitedColor(c: Color):
	
	var timeWaitedBox : StyleBoxFlat
	timeWaitedBox = $TabContainer/stats/timeWaitedPanel.get_theme_stylebox("panel")
	
	timeWaitedBox.border_color = c

####


func timeDicDiff(a : Dictionary, b :Dictionary) -> Dictionary:
	var delta : Dictionary
	var deltaSeconds
	
	if(!a.has_all(["second","minute","hour"]) or !b.has_all(["second","minute","hour"])):
		return {}
	
	var aSecond = (
		a["second"] 
		+ a["minute"] * 60 
		+ a["hour"] * ( 60 * 60)
	)
	
	var bSecond = (
		b["second"] 
		+ b["minute"] * 60 
		+ b["hour"] * (60 * 60)
	)
	
	deltaSeconds = aSecond - bSecond
	
	delta["hour"] = floor(deltaSeconds / (60 * 60))
	deltaSeconds = deltaSeconds % (60 * 60)
	
	delta["minute"] = floor(deltaSeconds / 60)
	deltaSeconds = deltaSeconds % 60
	
	delta["second"] = deltaSeconds
	
	return delta

####

func convertTimeStringToHMS(t, pre: String, hms: String) -> String:
	var timeString = pre
	var timeDic
	if(t is String):
		timeDic = Time.get_datetime_dict_from_datetime_string(t, false)
	elif(t is Dictionary):
		timeDic = t
	else:
		printerr("convertTimeStringToHMS: Invalid input time")
		return pre + "Error"
	
	if(hms.contains("h")):
		timeString += "%02d:" % [timeDic["hour"]]
	if(hms.contains("m")):
		timeString += "%02d" % [timeDic["minute"]]
	if(hms.contains("s")):
		timeString += ":%02d" % [timeDic["second"]]

	return timeString

###

func queueStats() -> void:
	
	if(!DB.persistant.has(stateKey)): return
	
	var state = DB.persistant[stateKey]
	
	if(state == 0):
		$TabContainer/stats/extraPostQueue.visible = false
		
		$TabContainer/stats/timeWaitedPanel/timeWaited.text = "Waited: n/a"
		$TabContainer/stats/queueEnterTime.text = "Queue Enter:"
		$TabContainer/stats/queuePostedTime.text = "Posted Wait Time:"
		$TabContainer/stats/queueETA.text = "ETA:"
	elif(state == 1):
		$TabContainer/stats/queueEnterTime.text = convertTimeStringToHMS(DB.persistant[DTKey], "Queue Enter: ", "hm")

		if(DB.persistant.has(PKey)):
			$TabContainer/stats/queuePostedTime.text = "Posted Wait Time: " + str(int(DB.persistant[PKey])) + " Min"
			
			var complement = {}
			
			complement["hour"] = -int(DB.persistant[PKey] / 60)
			complement["minute"] = -(int(DB.persistant[PKey]) % 60)
			complement["second"] = 0
			
			var start = Time.get_datetime_dict_from_datetime_string(DB.persistant[DTKey], false)
			var eta = timeDicDiff(start, complement)
			
			
			$TabContainer/stats/queueETA.text = convertTimeStringToHMS(eta, "ETA: ", "hm")
		
	elif(state == 2):
		#PostQueue
		var start = Time.get_datetime_dict_from_datetime_string(DB.persistant[DTKey], false)
		var end = Time.get_datetime_dict_from_datetime_string(DB.persistant[STKey], false)
		
		var delta = timeDicDiff(end, start)
		
		$TabContainer/stats/timeWaitedPanel/timeWaited.text = convertTimeStringToHMS(delta, "Time Waited: ", "hms")
		
		$TabContainer/stats/extraPostQueue.visible = true
		$TabContainer/stats/extraPostQueue/queueEndTime.text = convertTimeStringToHMS(end, "Queue Exit: ", "hm")
		

####

func _on_start_queue_button_button_down() -> void:
	
	if(DB.persistant[stateKey] != 0): return
	
	DB.persistant[stateKey] = 1
	DB.persistant[DTKey]  = Time.get_datetime_string_from_system()
	$TabContainer/stats/queueEnterTime.text  = convertTimeStringToHMS(DB.persistant[DTKey], "Entered: ", "hm")
	$updateTimer.start()
	updateTime()
	DB.savePersistantFile()
	
	_ready()


func _on_end_queue_button_button_down() -> void:
	
	if(DB.persistant[stateKey] != 1): return
	
	DB.persistant[stateKey] = 2
	DB.persistant[STKey] = Time.get_datetime_string_from_system()
	$updateTimer.stop()
	
	DB.savePersistantFile()
	queueStats()
	
	_ready()


func _on_reset_queue_button_down() -> void:
	
	if(DB.persistant[stateKey] != 2): return
	
	print("Reseting Queue Data!")
	
	DB.persistant[stateKey] = 0
	DB.persistant.erase(STKey)
	DB.persistant.erase(DTKey)
	DB.persistant.erase(PKey)
	
	DB.savePersistantFile()
	
	_ready()


func _on_set_posted_time_button_down() -> void:
	if(!DB.persistant.has(stateKey)): return
	
	if(DB.persistant[stateKey] == 2): return
	
	var postedMinutes = int($TabContainer/control/postedTimeInput.text)
	
	if(postedMinutes == 0): return
	
	DB.persistant[PKey] = int(postedMinutes)
	DB.savePersistantFile()
	
	_ready()
