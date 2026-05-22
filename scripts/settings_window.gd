extends Window


func _ready() -> void:
	
	updatePathLabel()
	
	#Update reset button
	$resetDatabaseButton.disabled = false
	$resetDatabaseButton.text = "Reset Database"
	pass 

func updatePathLabel():
	$currentPath.text = "Current Database Path:\n" + DB.databasePath
	pass

#
#
#

func _on_settings_button_button_down() -> void:
	self.visible = true
	pass

func _on_settings_window_close_requested() -> void:
	self.visible = false
	pass

func _on_reset_database_button_button_down() -> void:
	$resetDatabaseButton/resetDbWindow.visible = true
	pass

func _on_reset_db_window_confirmed() -> void:
	#Will delete DB and quit
	
	#Scary!
	var query : String = "DROP TABLE RCLog; DROP TABLE RideRef; DROP TABLE Location;"
	
	if !DB.db.query(query):
		print("ERR reseting database")
	else:
		print("ALL TABLES DROPED")
		
		#Disable Reset Button
		$resetDatabaseButton.disabled = true
		$resetDatabaseButton.text = "Database Reseted"
		
		DB.initDB()
		
		self.get_parent().refreshAllList() # Calls the function from the root
		updatePathLabel()
		#Deselect any previous rides
		DB.selectRideForLog = -1
		self.get_parent().updateSelectedRideButton()
	pass


func _on_change_database_button_button_down() -> void:
	$changeDatabaseButton/FileDialog.visible = true
	pass # Replace with function body.


func _on_file_dialog_file_selected(path: String) -> void:
	DB.db.close_db()
	
	DB.db.path = path
	
	
	if !DB.db.open_db():
		print("ERR on open")
		
		OS.crash("ERR on open")
	else:
		DB.databasePath = path #For refence
		DB.saveDBPath(path)
		DB.initDB()
	
	
	self.get_parent().refreshAllList() # Calls the function from the root
	updatePathLabel()
	
	#Deselect any previous rides
	#DB.selectRideForLog = -1 #TODO Refernce app selected ride
	self.get_parent().updateSelectedRideButton()
	pass

func _on_back_button_button_down() -> void:
	self.visible = false
	pass

# ------
