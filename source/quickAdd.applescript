#!/usr/bin/env osascript
tell application "System Events"

	set previousApp to name of 1st process whose frontmost is true
	keystroke "c" using command down
	
	tell application "Bookends"
		activate
	end tell
	delay 0.1
	keystroke "n" using {command down, control down}
	delay 0.6
	keystroke "v" using command down
	delay 0.1
	keystroke return --comment this out if you want to edit text before search
	delay 0.5
	
	tell application previousApp
		activate
	end tell
	
end tell