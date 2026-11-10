extends Node

class WordList:
	var words: Array[String]
	func _init():
		words = []
	func random_word():
		words.pick_random();
	func add_word(word: String):
		words.push_back(word);

var words_file_path = "res://npcs/sentence_forming/words.txt";
var templates_file_path = "";

var words: Dictionary[String, WordList];
var templates: Array[String];

func load_files():
	var line: String;
	print("start reading files")
	
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
	
	var templates_file = FileAccess.open(templates_file_path, FileAccess.READ);
	
	while not templates_file.eof_reached():
		line = words_file.get_line();
		if len(line) == 0 or line[0] == "#":
			continue;
		templates.push_back(line)

func random_sentence():
	var template = templates.pick_random()
	

# THIS ONLY EXISTS BECAUSE I HAD TO MAKE A SCENE TO TEST IT IN
# as long as you call load_files once somewhere that persists it should work
# idk how you wanna implement it but it should be intuitive
func _ready() -> void:
	load_files();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
