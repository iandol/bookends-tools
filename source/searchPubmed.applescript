#!/usr/bin/osascript
tell application "System Events"
	keystroke "c" using command down
	
	tell application "Bookends"
		activate
		delay 0.1
	end tell
	
	tell application "System Events"
		keystroke "w" using {command down, shift down}
		delay 0.6
		keystroke "v" using command down
		delay 0.1
		keystroke return
	end tell
end tell