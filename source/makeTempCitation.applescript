-------------------------------------------------------------------------
-- SCRIPT FOR SETTING CITATION USING {AUTHOR, DATE #UID}
-------------------------------------------------------------------------
on run argv
	set refItem to argv as text
	tell application "Bookends"
		-- Extract first Author
		set refAuthorList to («event ToySRFLD» refItem given string:"authors")
		set AppleScript's text item delimiters to {","}
		set refAuthors to text items of refAuthorList
		set AppleScript's text item delimiters to {"'"}
		set refAuthor to first item of refAuthors
		set AppleScript's text item delimiters to {""}
		-- Extract date
		set refDateRaw to («event ToySRFLD» refItem given string:"thedate")
		set cmd to "echo '" & refDateRaw & "' | sed 's/\\([0-9]*\\)\\(.*\\)/\\1/g'"
		set refDate to (do shell script cmd)
		-- Set citation
		set refCitation to "{" & refAuthor & ", " & refDate & ", #" & refItem & "}"
		set the clipboard to {Unicode text:refCitation}
	end tell
end run