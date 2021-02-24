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
