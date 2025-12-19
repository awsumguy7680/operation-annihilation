extends AudioStreamPlayer

#Tracks
const MENU_THEME = preload("res://assets/sounds/Music/CoffeebrewedinTimesofWar.wav")
const TANK_THEME = preload("res://assets/sounds/Music/mammoth.wav")
const HELI_THEME = preload("res://assets/sounds/Music/JammedwithLimbshigh.wav")
const JET_THEME = preload("res://assets/sounds/Music/destoroya.wav")

func set_music(track):
	stream = track
	play()
