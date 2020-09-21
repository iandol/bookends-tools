use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
-- this uses the new Bookends applescript API, works fine but takes about 2X longer to process than the old event system...
tell application "Bookends"
	tell front library window
		try
			set groupName to "Ideas"
			set tGroup to first group item whose id contains groupName
			set outFile to ((path to desktop from user domain) as string) & "Bibliography.bib"
			set myFile to open for access outFile with write permission
			set eof of myFile to 0 --make sure we overwrite
			set steps to 30
			set listLength to count of publication items of tGroup
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
				set myPubs to publication items startindex thru endindex of tGroup
				set bibtexRefs to format myPubs using "BibTeX-Minimal.fmt"
				-- write out as UTF-8, from: http://macscripter.net/viewtopic.php?id=24534
				write bibtexRefs to myFile as «class utf8»
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
