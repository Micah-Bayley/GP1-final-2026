extends Node2D

@export var tutorial_pages: Array[Texture2D]
@export_multiline var tutorial_texts: Array[String]

@onready var tutorial_image: TextureRect = $CanvasLayer/TextureRect
@onready var tutorial_label: RichTextLabel = $CanvasLayer/MarginContainer3/Label

@onready var next_button: Button = $CanvasLayer/MarginContainer/NextButton
@onready var previous_button: Button = $CanvasLayer/MarginContainer2/PreviousButton

@export var tutorial_titles: Array[String]

@onready var title_label: Label = $CanvasLayer/MarginContainer4/TitleLabel

var current_page := 0


func _ready():
	update_page()


func update_page():
	if tutorial_pages.is_empty():
		return
		
	# Update title
	if current_page < tutorial_titles.size():
		title_label.text = tutorial_titles[current_page]
	else:
		title_label.text = ""

	# Update screenshot
	tutorial_image.texture = tutorial_pages[current_page]

	# Update text
	if current_page < tutorial_texts.size():
		tutorial_label.clear()
		tutorial_label.append_text(tutorial_texts[current_page])
	else:
		tutorial_label.text = ""

	# Disable previous button on first page
	previous_button.disabled = current_page == 0

	# Change button text on last page
	if current_page == tutorial_pages.size() - 1:
		next_button.text = "Exit"
	else:
		next_button.text = "Next"


func _on_next_button_pressed() -> void:

	# Last page -> return to main menu
	if current_page == tutorial_pages.size() - 1:
		SceneManager.change_scene("res://scenes/main_menu.tscn")
		return

	current_page += 1
	update_page()


func _on_previous_button_pressed() -> void:
	current_page -= 1
	current_page = max(current_page, 0)

	update_page()
