## Arma un SpriteFrames (.tres) a partir de una hoja de sprites y su .json.
##
## Uso:
##   godot --headless -s res://prototypes/spike_001/comfy/build_frames.gd -- <hoja> <salida.tres>
## El .json tiene que estar al lado de la hoja, con el mismo nombre.
extends SceneTree


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var sheet_path := args[0]
	var meta: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(sheet_path.get_basename() + ".json")
	)
	var sheet: Texture2D = load(sheet_path)
	var size: Array = meta["frame_size"]
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for anim: String in meta["animations"]:
		var m: Dictionary = meta["animations"][anim]
		frames.add_animation(anim)
		frames.set_animation_speed(anim, m["fps"])
		frames.set_animation_loop(anim, m["loop"])
		for i in int(m["count"]):
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2((int(m["start"]) + i) * size[0], 0, size[0], size[1])
			frames.add_frame(anim, atlas)
	print(args[1], " ", ResourceSaver.save(frames, args[1]))
	quit()
