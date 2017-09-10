	 tell application "System Events"
			keystroke "c" using command down
			delay 0.3
			do shell script "id=$(pbpaste); open \"bookends://sonnysoftware.com/$id\""
	 end tell