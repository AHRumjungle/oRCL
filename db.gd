extends Node

var db : SQLite

var databasePath : String = "res://database.db" #Change res: to user: when exporting to android

var saveFilePath : String = "res://databasePath.save"

var appStart = true #For app start popups
var persistant : Dictionary

#DB Layout
#TODO Add Manufacture Table, add ride type tabel

var RCLogTable : String = "CREATE TABLE IF NOT EXISTS \"RCLog\" (\"id\"	INTEGER NOT NULL UNIQUE,\"date\"	TEXT NOT NULL,\"rideID\"	INTEGER NOT NULL,\"note\"	BLOB,PRIMARY KEY(\"id\" AUTOINCREMENT),FOREIGN KEY(\"rideID\") REFERENCES \"RideRef\"(\"id\"));"

var RideRefTable : String = "CREATE TABLE IF NOT EXISTS \"RideRef\" (\"id\"	INTEGER NOT NULL UNIQUE,\"name\"	TEXT NOT NULL,\"des\"	BLOB,\"location\"	INTEGER, \"isCredit\"	INTEGER, PRIMARY KEY(\"id\" AUTOINCREMENT),FOREIGN KEY(\"location\") REFERENCES \"Location\"(\"id\"));"

var LocationTable : String = "CREATE TABLE IF NOT EXISTS \"Location\" (\"id\"	INTEGER NOT NULL UNIQUE,\"name\"	TEXT NOT NULL,\"shortName\"	TEXT NOT NULL,PRIMARY KEY(\"id\" AUTOINCREMENT));"

# Init DB and stuff
func _ready() -> void:
	
	if OS.get_name() in ["Android"]:
			databasePath = "/storage/emulated/0" 
			saveFilePath = "user://databasePath.save" #Change res: to user: when exporting to android
			OS.request_permissions()
	
	#Load Persistant Data
	if FileAccess.file_exists(saveFilePath):
		var file = FileAccess.open(saveFilePath, FileAccess.READ)
		var inJSONString = file.get_as_text()
		file.close()
		
		var JSONHolder = JSON.new()
		var parseError = JSONHolder.parse(inJSONString)
		
		if(parseError == OK):
			print("Loaded JSON")
			persistant = JSONHolder.data
		else:
			printerr("Failed to load JSON: " + type_convert(parseError, TYPE_STRING))
		
	
	#Init database
	DB.db = SQLite.new()
	if(persistant["dbPath"] != null):
		databasePath = persistant["dbPath"]
	else:
		print("No Saved Path, opening default path")
	
	DB.db.path =  databasePath
	
	#Open DB
	if !db.open_db():
		print("ERR opening DB")
	
	initDB()
	pass

####

func savePersistantFile() -> void:
	if persistant == null:
		print("ERROR: No persistant data to save")
		return
	
	var pJSON = JSON.new()
	
	var pJSONString = pJSON.stringify(persistant)
	
	print("Saving persistant data: " + pJSONString)
	
	var file = FileAccess.open(saveFilePath, FileAccess.WRITE)
	file.resize(0) #deletes existing data
	file.store_string(pJSONString)
	file.close()

####

# On Close
func _exit_tree() -> void:
	print("EXIT!")
	db.close_db()
	pass

func initDB() -> void:
		#Create tables if not exists
	if !db.query(RCLogTable):
		print("ERR creating RCLog table")
	
	if !db.query(RideRefTable):
		print("ERR creating RideRef table")
		
	if !db.query(LocationTable):
		print("ERR creating Location table")
	pass

func saveDBPath(path : String):
	
	persistant["dbPath"] = path
	
	savePersistantFile()
	pass
