set originalT to (time of (current date))
set groupName to "Last 100"
set outFile to ((path to desktop from user domain) as string) & "Biblio.bib"

-- tell application "Bookends"
-- 	tell front library window
-- 		ignoring case
-- 			if groupName is equal to "all" then
-- 				set myGroup to group all
-- 				set pubsList to publication items of myGroup
-- 			else if groupName is equal to "attachments" then
-- 				set myGroup to group attachments
-- 				set pubsList to publication items of myGroup
-- 			else if groupName is equal to "hits" then
-- 				set myGroup to group hits
-- 				set pubsList to publication items of myGroup
-- 			else
-- 				set pubsList to publication items of group item groupName
-- 			end if
-- 		end ignoring
-- 		if pubsList is not {} then
-- 			set bibContent to format pubsList using "BibTeX.fmt"
-- 			my writeTextToFile(outFile, bibContent)
-- 		end if
-- 	end tell
-- end tell
-- set newT to (time of (current date))
-- set diffT to newT - originalT
-- set output to "Script took " & diffT & " seconds"
-- display notification output with title "Simple Bookends to BibTeX exporter V1.0"

-- tell application "Bookends"
-- 	tell front library window
-- 		set pubsList to «event ToySRUID» groupName as string
-- 		if pubsList is not {} then
-- 			set bibContent to «event ToySGUID» pubsList given «class RRTF»:"false", string:"BibTeX"
-- 			my writeTextToFile(outFile, bibContent)
-- 		end if
-- 	end tell
-- end tell
-- set newT to (time of (current date))
-- set diffT to newT - originalT
-- set output to "Script took " & diffT & " seconds"
-- display notification output with title "Old Events Bookends to BibTeX exporter V1.0"

tell application "Bookends"
	tell front library window
		set pubsList to publication items of group item groupName
		if pubsList is not {} then
			set bibContent to format pubsList using "BibTeX.fmt"
			my writeTextToFile(outFile, bibContent)
		end if
	end tell
end tell
set newT to (time of (current date))
set diffT to newT - originalT
set output to "Script took " & diffT & " seconds"
display notification output with title "Simplest Bookends to BibTeX exporter V1.0"

on writeTextToFile(aFile, theText)
	set aFileRef to open for access aFile with write permission
	set eof aFileRef to 0
	write theText to aFileRef as «class utf8»
	close access aFileRef
end writeTextToFile
