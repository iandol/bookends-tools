use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

-- this is ~2 seconds
tell application "Bookends"
	tell front library window
		set mypub to first publication item whose id is "59232"
		set myfmt to format mypub using "APA 7th Edition" as RTF
	end tell
end tell

-- this is ~0.05 seconds
tell application "Bookends"
	tell front library window
		return «event ToySGUID» "59232" given «class RRTF»:"true", string:"APA 7th Edition"
	end tell
end tell
