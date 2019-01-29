#!/usr/bin/osascript
tell application "System Events"

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
	keystroke "h" using command down --comment out if you want bookeds to remain active

end tell