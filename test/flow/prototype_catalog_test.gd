extends GdUnitTestSuite

const ROOT := "user://test_prototype_catalog"


func before_test() -> void:
	_remove(ROOT)
	for dir_name in ["spike_004", "spike_003", "otra_cosa", "spike_005"]:
		DirAccess.make_dir_recursive_absolute("%s/%s" % [ROOT, dir_name])
	# spike_005 no tiene escena: no cuenta. otra_cosa no empieza con spike_.
	for path in [
		"spike_003/spike_003.tscn", "spike_004/spike_004.tscn", "otra_cosa/otra_cosa.tscn"
	]:
		var f := FileAccess.open("%s/%s" % [ROOT, path], FileAccess.WRITE)
		f.store_string("")
		f.close()


func after_test() -> void:
	_remove(ROOT)


func test_find_lists_spike_scenes_sorted() -> void:
	(
		assert_array(PrototypeCatalog.find(ROOT))
		. contains_exactly(
			[
				ROOT + "/spike_003/spike_003.tscn",
				ROOT + "/spike_004/spike_004.tscn",
			]
		)
	)


func test_find_without_folder_is_empty() -> void:
	assert_array(PrototypeCatalog.find(ROOT + "/no_existe")).is_empty()


func test_spike_number_from_path() -> void:
	assert_str(PrototypeCatalog.spike_number("res://prototypes/spike_003/spike_003.tscn")).is_equal(
		"003"
	)


func _remove(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	for dir_name in DirAccess.get_directories_at(path):
		_remove("%s/%s" % [path, dir_name])
	for file_name in DirAccess.get_files_at(path):
		DirAccess.remove_absolute("%s/%s" % [path, file_name])
	DirAccess.remove_absolute(path)
