set originalT to (time of (current date))
set groupName to "Last 100"
set outFile to ((path to desktop from user domain) as string) & "BiblioN.bib"
-- this uses the new Bookends applescript API, works fine but takes about 2X longer to process than the old event system...
tell application "Bookends"
	try
		set groupName to first group item of front library window whose id contains groupName
		set myFile to open for access outFile with write permission
		set eof of myFile to 0 --make sure we overwrite
		set steps to 2000
		set listLength to count of publication items of groupName
		set nLoop to round (listLength / steps) rounding up
		set thisLoop to 1
		repeat while thisLoop is less than or equal to nLoop
			-- set the batch index range
			set startindex to (steps * thisLoop) - (steps - 1)
			set endindex to (steps * thisLoop)
			if endindex is greater than listLength then
				set endindex to listLength
			end if
			tell front library window
				-- select current batch of items
				set pubsList to publication items startindex thru endindex of groupName
				--set pubsList to publication items of group item groupName
				set bibtexRefs to format pubsList using "BibTeX.fmt"
			end tell
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

set newT to (time of (current date))
set diffT to newT - originalT
set output to " Export took " & diffT & " seconds"
display notification output with title "newBibTeX exporter V1.0"


