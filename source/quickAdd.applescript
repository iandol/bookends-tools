#!/usr/bin/osascript
tell application "System Events"
	keystroke "c" using command down
	
	tell application "Bookends"
		activate
		delay 0.1
	end tell
	
	tell application "System Events"
		keystroke "n" using {command down, control down}
		delay 0.6
		keystroke "v" using command down
		delay 0.1
		keystroke return --comment this out if you want to edit text before search
	end tell
end tell