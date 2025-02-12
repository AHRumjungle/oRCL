extends Node

var db : SQLite

var databasePath : String = "res://database.db" #Change res: to user: when exporting to android

var saveFilePath : String = "res://databasePath.save"

var selectRideForLog : int = -1


#DB Layout
#TODO Add Manufacture Table, add ride type tabel

var RCLogTable : String = "CREATE TABLE IF NOT EXISTS \"RCLog\" (\"id\"	INTEGER NOT NULL UNIQUE,\"date\"	TEXT NOT NULL,\"rideID\"	INTEGER NOT NULL,\"note\"	BLOB,PRIMARY KEY(\"id\" AUTOINCREMENT),FOREIGN KEY(\"rideID\") REFERENCES \"RideRef\"(\"id\"));"

var RideRefTable : String = "CREATE TABLE IF NOT EXISTS \"RideRef\" (\"id\"	INTEGER NOT NULL UNIQUE,\"name\"	TEXT NOT NULL UNIQUE,\"des\"	BLOB,\"location\"	INTEGER, \"isCredit\"	INTEGER, PRIMARY KEY(\"id\" AUTOINCREMENT),FOREIGN KEY(\"location\") REFERENCES \"Location\"(\"id\"));"

var LocationTable : String = "CREATE TABLE IF NOT EXISTS \"Location\" (\"id\"	INTEGER NOT NULL UNIQUE,\"name\"	TEXT NOT NULL,\"shortName\"	TEXT NOT NULL,PRIMARY KEY(\"id\" AUTOINCREMENT));"

# Init DB and stuff
func _ready() -> void:
	
	if OS.get_name() in ["Android"]:
			databasePath = "user://database.db" #Change res: to user: when exporting to android
			saveFilePath = "user://databasePath.save"
			OS.request_permissions()
	
	#check for saved db path
	if FileAccess.file_exists(saveFilePath):
		var file = FileAccess.open(saveFilePath, FileAccess.READ)
		databasePath = file.get_line()
		file.close()
	
	#Init database
	DB.db = SQLite.new()
	DB.db.path =  databasePath
	
	#Open DB
	if !db.open_db():
		print("ERR opening DB")
	
	initDB()
	pass


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
	var file = FileAccess.open(saveFilePath, FileAccess.WRITE)
	file.resize(0) #deletes existing data
	file.store_string(path)
	file.close()
	print("Path Saved")
	pass
