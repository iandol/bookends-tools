tell application "System Events"
	keystroke "c" using command down
	
	tell application "Bookends"
		activate
	end tell
	
	tell application "System Events"
		keystroke "w" using {command down, shift down}
		delay 0.8
		keystroke "v" using command down
		keystroke return
	end tell
end tell