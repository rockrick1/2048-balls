extends Node


func saveGame(activeBalls : Array) -> void:
	var saveGame = File.new()
	saveGame.open("user://savegame.save", File.WRITE)
	
	var exponents = []
	for ball in activeBalls:
		exponents.append(ball.Exponent)
	
	saveGame.store_line(to_json(exponents))
	saveGame.close()
	print("Game saved successfully!")

func loadGame() -> Array:
	var saveGame = File.new()
	if not saveGame.file_exists("user://savegame.save"):
		print("No save found.")
		return []

	saveGame.open("user://savegame.save", File.READ)
	var exponents = []
	while saveGame.get_position() < saveGame.get_len():
		exponents = parse_json(saveGame.get_line())
	
	if exponents == []:
		print("Error loading save!")
	else:
		print("Game loaded successfully!")
	
	saveGame.close()
	return exponents
