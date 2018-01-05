#!/usr/bin/osascript
tell application "System Events"
	keystroke "c" using command down
	--we use sed to remove ( ) , . ; @ and et al and uniqueID from a formatted ref and copy it back to clipboard
	--for example selecting {Hulme et al., 2010, #42249} should become "Hulme 2010" in the Bookends quick search field
	do shell script "pbpaste | sed -Ee 's/ et[ .]+al//g' -e 's/ and //g' -e 's/[\\{\\}\\(\\),\\.;@]//g' -e 's/#[0-9]+//g' | pbcopy"
	
	tell application "Bookends"
		activate
		delay 0.1
	end tell
	
	tell application "System Events"
		keystroke "f" using {command down, option down}
		delay 0.5
		keystroke "v" using command down
		delay 0.1
		keystroke return --comment this out if you want to edit text before search
	end tell
end tell