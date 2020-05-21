use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application "Bookends"
	tell front library window
		try
			set groupName to "Core"
			set tGroup to group items whose id ends with groupName
			set tGroup to first item of tGroup
			set outFile to ((path to desktop from user domain) as string) & "Bibliography.bib"
			set myFile to open for access outFile with write permission
			set eof of myFile to 0 --make sure we overwrite
			set steps to 25
			set listLength to length of first item in tGroup
			set nLoop to round (listLength / steps) rounding up
			set thisLoop to 1
			
			repeat while thisLoop is less than or equal to nLoop
				-- set the batch index range
				set startindex to (steps * thisLoop) - (steps - 1)
				set endindex to (steps * thisLoop)
				if endindex is greater than listLength then
					set endindex to listLength
				end if
				-- select current batch of items
				set thisListItems to items startindex thru endindex of publication items of tGroup
				set thisList to thisListItems as string
				
				set bibContent to format thisList using "BibTeX Minimal.fmt"
				
				-- write out as UTF-8, from: http://macscripter.net/viewtopic.php?id=24534
				write bibContent to myFile as «class utf8»
				
				-- update the loop number
				set thisLoop to thisLoop + 1
				
			end repeat -- thisLoop
			
			close access myFile
			
		on error
			try
				close access myFile
			end try
			return "Problem processing references..."
		end try
		
	end tell
end tell
