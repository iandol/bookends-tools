#!/usr/bin/osascript

(*
Script originally written by Naupaka Zimmerman, modified by iandol
August 10, 2017

MIT License

Copyright (c) 2017 Naupaka Zimmerman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*)

(*
Trim whitespace, from http://macscripter.net/viewtopic.php?id=18519
*)
on trim(someText)
	repeat until someText does not start with " "
		set someText to text 2 thru -1 of someText
	end repeat
	
	repeat until someText does not end with " "
		set someText to text 1 thru -2 of someText
	end repeat
	
	return someText
end trim

(*
Function to split returned values on a character into an array
and also to parse out only those that match the query string.
E.g. if you have a folder of groups called "Manuscripts/", this will
find all groups with that word in their path and export them.
It will also work with the name of just a single specific group.
Based on code from this page: 
http://erikslab.com/2007/08/31/applescript-how-to-split-a-string/
*)
on theSplit(allGroups, theDelimiter, myGroups)
	-- set delimiters to delimiter to be used
	set AppleScript's text item delimiters to theDelimiter
	-- create the array
	set groupArray to every text item of allGroups
	set theSelectedList to {}
	repeat with currentGroup in myGroups
		set currentGroup to my trim(currentGroup)
		repeat with thisGroup in groupArray
			if ((thisGroup as string) contains (currentGroup as string)) then
				-- use sed to strip out all folder names from the group name returned from bookends
				-- this leaves only group name 
				set cmd to "echo \"" & thisGroup & "\"| sed \"s/.*\\/\\(.*\\)/\\1/\"" as string
				set sedResult to (do shell script cmd)
				-- if there's a match, append parsed group name onto end of list
				set end of theSelectedList to sedResult
			end if
		end repeat
	end repeat
	return theSelectedList
end theSplit

on run argv
	--start time
	set originalT to (time of (current date))
	--version
	set myVersion to 1.12
	-- store default delimiters
	set oldDelimiters to AppleScript's text item delimiters
	-- get JSON option
	set toJSON to (system attribute "BibTeXtoJSON" as string)
	if toJSON is "true"
		set toJSON to true
	else
		set toJSON to false
	end if
	-- check that pandoc-citeproc is available
	set cpPath to "/usr/local/bin/pandoc-citeproc"
	set isCiteproc to false
	tell application "Finder" to if exists cpPath as POSIX file then set isCiteproc to true

	-- parse input
	set homePath to POSIX path of (path to home folder)
	if (count of argv) > 1 then
		set myPath to POSIX path of homePath & (item 1 of argv)
		set theGroups to items 2 thru -1 of argv
	else if (count of argv) > 0 then
		set myPath to POSIX path of homePath & (item 1 of argv)
		set theGroups to "Selection" 
	else
		set myPath to POSIX path of (path to desktop) 
		set theGroups to "Selection" 
	end if
	set AppleScript's text item delimiters to " "
	set myGroupsToExport to theGroups as text
	
	-- parse based on comma delimiter
	set AppleScript's text item delimiters to ","
	set myGroupsToExport to every text item of myGroupsToExport
	set AppleScript's text item delimiters to oldDelimiters
	
	tell application "Bookends"
		-- get a list of all groups in open library
		set allGroups to «event ToySRGPN» given «class PATH»:"true"
		-- prepend the default bookends groups
		set allGroups to "All" & return & "Hits" & return & "Attachments" & return & "Selection" & return & allGroups
		-- split up those groups into elements of an array
		-- 'return' here, as the middle parameter, is the return or newline character
		set myGroupArray to my theSplit(allGroups, return, myGroupsToExport)
	end tell
	
	if myGroupArray is {} then
		set output to "No groups matched your input..."
	else
		display notification "Running BibTeX conversion, please wait…" with title "Bookends to BibTeX exporter V" & myVersion
		-- set output string based on parsed input parameters or defaults
		set AppleScript's text item delimiters to ", "
		set output to ("Path: " & myPath & " | " & "Groups:" & myGroupArray & "." as string)
		set AppleScript's text item delimiters to oldDelimiters -- change back to default
	end if

	-- loop over each folder matching the pattern and export each to a bibtex file
	repeat with myGroup in myGroupArray
		set thisFile to (myPath & (myGroup as string) & ".bib") as POSIX file
		set thisJSONFile to (myPath & (myGroup as string) & ".json") as POSIX file
		set quotedName to quoted form of POSIX path of thisFile
		set quotedJSONName to quoted form of POSIX path of thisJSONFile
		set myFile to open for access thisFile with write permission
		set eof of myFile to 0 --make sure we overwrite

		try
			tell application "Bookends"
				-- get a list of all unique reference IDs in the specified group 
				set myListString to «event ToySRUID» myGroup as string
				-- convert to list 
				set AppleScript's text item delimiters to return
				set myList to text items of myListString
				-- set up the loop to batch fetch sets of references, 
				-- in theory this should be more efficient, 
				-- and saves around 1-2 seconds per 1000 exported
				set steps to 100
				set listLength to length of myList
				set nLoop to round (listLength / steps) rounding up
				set thisLoop to 1
				
				-- iterate through list writing each entry
				repeat while thisLoop is less than or equal to nLoop
					-- set the batch index range
					set startindex to (steps * thisLoop) - (steps - 1)
					set endindex to (steps * thisLoop)
					if endindex is greater than listLength then
						set endindex to listLength
					end if
					-- select current batch of items
					set thisListItems to items startindex thru endindex of myList
					set thisList to thisListItems as string
					
					-- fetch the BibTeX
					set myBibTex to «event ToySGUID» thisList given «class RRTF»:"false", string:"bibtex"
					
					-- write out as UTF-8, from: http://macscripter.net/viewtopic.php?id=24534
					write myBibTex to myFile as «class utf8»
					
					-- update the loop number
					set thisLoop to thisLoop + 1
					
				end repeat -- thisLoop
			end tell -- Bookends
		on error
			try
				close access myFile
				set AppleScript's text item delimiters to oldDelimiters
			end try
			return false
		end try

		close access myFile
		
		-- To force case of the title we have to wrap it in an extra { }
		-- so we have to do it with sed (grrr applescript!)
		set permBibPath to POSIX path of thisFile
		set tempBibPath to permBibPath & ".tmp"
		set permBibPath to quoted form of permBibPath
		set tempBibPath to quoted form of tempBibPath
		set cmd to "sed -E 's/(title = )({[^}]*})/\\1{\\2}/g' " & permBibPath & " > " & tempBibPath & " && mv " & tempBibPath & " " & permBibPath
		do shell script cmd

		-- Convert to JSON? JSON is much faster to parse for pandoc-citeproc
		if (toJSON is true) and (isCiteproc is true) then
			set cmd to cpPath & " -j " & quotedName & " > " & quotedJSONName
			do shell script cmd
			do shell script "rm -f " & quotedName
		end if
		
	end repeat
	
	set newT to (time of (current date))
	set diffT to newT - originalT
	set output to output & " | took " & diffT & " seconds"
	
	set AppleScript's text item delimiters to oldDelimiters
	display notification output with title "Bookends to BibTeX exporter V" & myVersion
	
end run
