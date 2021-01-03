use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

on run argv
	tell application "Bookends" to tell front library window
		if item 1 of argv is "mod" then
			set matchingPubs to sql search "dateModified > datediff( now(), '01/01/1904 00:00:00', 'second' ) - " & (item 2 of argv)
			set citekeys to {}
			repeat with thePub in matchingPubs
				set end of citekeys to citekey of thePub
			end repeat
			set AppleScript's text item delimiters to ","
			return citekeys as string
		else if item 1 of argv is "all" then
			return citekey of publication items of group all
		else if item 1 of argv is "get_bib" then
			set theItem to (publication items whose citekey is (item 2 of argv))
			return format theItem using "BibTeX.fmt"
		end if
	end tell
end run