extends Control
	
var index = 0	
signal stopped_talking
var dialogue_finished = false
var line_completed = true
var skip_text = false

#Going to just hardcode the text I want here, since I won't have that much dialogue anyway.
#If I was to expand this, I would definitely pull the text in from file.
var dialogue = ["G'day ma-",
"Oh!",
"It's you Larry.",
"Some night last night eh?",
"All that toad blood on you tells me you've had a fun morning.....",
"...",
"Look.",
"I need your help with Dazza.",
"He's been an absolute disgrace.",
"He ran off with money from the till.",
"Could you do me a favour mate?",
"Go south from here and deal with Dazza for me.",
"Cheers."]

func _ready():
	self.connect("stopped_talking", get_parent().get_parent(), "hide_dialogue_panel")
	return

func print_dialogue( string ):
	line_completed = false
	for letter in string:
		if !skip_text:
			$LetterTimer.start()
			$RichTextLabel.add_text( letter )
			yield($LetterTimer, "timeout")
	line_completed = true
	index += 1
	return
	
func advance_dialogue():
	if !dialogue_finished:
		$RichTextLabel.text = ""
		if(index < dialogue.size()):
			if line_completed:
				skip_text = false
				print_dialogue(dialogue[index])
			else:
				skip_text = true
				$RichTextLabel.text = dialogue[index]
				index += 1
		if index == dialogue.size() - 1:
			dialogue_finished = true
	else:
		emit_signal("stopped_talking")
	return
