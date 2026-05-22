extends Node

#Function Scene Handler

#Return values
var returnScene : String = ""

var returnDict = {} #The function scene return value(s)

func functionScene(targetScene : String) -> void:
	
	returnDict = {} #Reset return
	
	returnScene = get_tree().current_scene.scene_file_path
	
	print("FS: Opening function scene \"" + targetScene + "\" from \"" + returnScene + "\"")
	get_tree().change_scene_to_file(targetScene)
	pass

func returnToLastScene() -> void:
	if returnScene == "":
		print("FS: Error on return")
		return
	else:
		print("FS: Returning to \"" + returnScene + "\"")
		get_tree().change_scene_to_file(returnScene)
		returnScene = ""
