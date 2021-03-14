extends Node

# List the directories (but not files) in the given path
# (assumes directories do not contain the char ".")
func list_files(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)

	while true:
		var file = dir.get_next()
		if file == "":
			break
		if file.find(".") != -1:
			continue
		files.append(file)

	dir.list_dir_end()
	return files

func parse_vec3(vec3_str):
	vec3_str = "["+vec3_str.replace(" ", ",")+"]"
	var p = JSON.parse(vec3_str)
	var result = Vector3(p.result[0], p.result[1], p.result[2])
	return result
