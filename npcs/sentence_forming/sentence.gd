extends Node

class WordList:
	var words: Array[String];
	
	func _init():
		words = [];
	
	func random_word():
		return words.pick_random();
	
	func add_word(word: String):
		words.push_back(word);

class Story:
	var lines: Array[String];
	var current_beat: int;
	func progress():
		current_beat = min(current_beat + 1, len(lines) - 1);
	func add_line(line: String):
		lines.push_back(line)
	func get_line():
		return lines[current_beat];


var words_file_path = "res://npcs/sentence_forming/words.txt";
var templates_file_path = "res://npcs/sentence_forming/templates.txt";
var stories_file_path = "res://npcs/sentence_forming/stories.txt";

var words: Dictionary[String, WordList];
var templates: Array[String];
var stories: Dictionary[String, Story];

func load_files():
	var line: String;
	
	# process words file
	var words_file = FileAccess.open(words_file_path, FileAccess.READ);
	var words_type: String;
	while not words_file.eof_reached():
		line = words_file.get_line();
		if len(line) == 0 or line[0] == "#":
			continue;
		
		# handle word-type-declaring line
		if line[0] == "-":
			words_type = line.substr(2);
			words[words_type] = WordList.new();
			continue;
		
		# otherwise we have a word
		words[words_type].add_word(line);
	
	# process templates file
	var templates_file = FileAccess.open(templates_file_path, FileAccess.READ);
	while not templates_file.eof_reached():
		line = templates_file.get_line();
		if len(line) == 0 or line[0] == "#":
			continue;
		templates.push_back(line);
	
	# process stories file
	var stories_file = FileAccess.open(stories_file_path, FileAccess.READ);
	var name: String;
	while not stories_file.eof_reached():
		line = stories_file.get_line();
		if len(line) == 0 or line[0] == "#":
			continue;
		
		# handle word-type-declaring line
		if line[0] == "-":
			name = line.substr(2);
			stories[name] = Story.new();
			continue;
		
		# otherwise we have a word
		stories[name].add_line(line);


func random_line():
	var template = templates.pick_random();
	for word_type in words.keys():
		while (template.contains(word_type)):
			var word = words[word_type].random_word();
			var location = template.find(word_type);
			template = template.substr(0, location) + word + template.substr(location+len(word_type));
	return template;


func get_npc_lines(npc_name: String, num_sentences: int):
	var lines: Array[String];
	if stories.has(npc_name):
		lines.push_back(stories[npc_name].get_line());
		stories[npc_name].progress();
	
	while (len(lines) < num_sentences):
		lines.push_back(random_line())
	
	return lines;

# THIS ONLY EXISTS BECAUSE I HAD TO MAKE A SCENE TO TEST THIS ALL
# as long as you call load_files once somewhere that persists it should work
# idk how you wanna implement it but it should be intuitive
func _ready() -> void:
	load_files();
	for i in range(10):
		print(random_line());
	
	for npc_name in stories.keys():
		for i in range(5):
			print(stories[npc_name].get_line())
			stories[npc_name].progress()
			
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
