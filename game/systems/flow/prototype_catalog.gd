## Lista los prototipos de spike que hay en el proyecto, para abrirlos desde el menú.
##
## Herramienta temporal de desarrollo: los prototipos viven solo en las branches
## spike/* (nunca llegan a develop), así que en develop la lista sale vacía.
## Busca carpetas spike_NNN con una escena spike_NNN.tscn adentro.
class_name PrototypeCatalog
extends RefCounted

const ROOT := "res://prototypes"
const PREFIX := "spike_"


## Rutas de las escenas encontradas, ordenadas por número. Vacía si no existe la carpeta.
static func find(root: String = ROOT) -> Array[String]:
	var found: Array[String] = []
	# DirAccess lee carpetas del proyecto (res://) o del jugador (user://).
	# get_directories_at devuelve los nombres de las subcarpetas.
	if not DirAccess.dir_exists_absolute(root):
		return found
	for dir_name in DirAccess.get_directories_at(root):
		if not dir_name.begins_with(PREFIX):
			continue
		var scene := "%s/%s/%s.tscn" % [root, dir_name, dir_name]
		# ResourceLoader.exists (y no FileAccess) porque en un build exportado las
		# escenas quedan convertidas y el .tscn original ya no está como archivo.
		if ResourceLoader.exists(scene) or FileAccess.file_exists(scene):
			found.append(scene)
	found.sort()
	return found


## Número del spike a partir de la ruta: ".../spike_003/spike_003.tscn" → "003".
static func spike_number(scene_path: String) -> String:
	return scene_path.get_file().get_basename().trim_prefix(PREFIX)
