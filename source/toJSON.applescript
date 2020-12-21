use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

set myJSONFile to "/Users/ian/Desktop/Test.json"
set jsonFile to POSIX file myJSONFile
set myGroup to "Last 1000"

tell application "System Events"
	if exists file myJSONFile then
		set cmd to "xattr -p 'com.apple.metadata:kMDSyncDate#S' '" & myJSONFile & "'"
		set syncDate to do shell script cmd
	else
		set syncDate to "No such xattr"
	end if
end tell

if syncDate contains "No such xattr" then
	set lastUpdate to (current date)
else
	set lastUpdate to (date syncDate)
end if

set originalT to (time of (current date))
	
tell application "System Events"
	if exists file myJSONFile then
		try
			set currentBibs to do shell script "cat " & quoted form of myJSONFile & " | /usr/local/bin/jq -r ' .[] | \"\\(.id)\"'"
			set currentBibs to paragraphs of currentBibs
			set bibJSON to my readFile(jsonFile)
			tell application "JSON Helper" to set bibJSON to read JSON from bibJSON
		on error
			set currentBibs to {}
			set bibJSON to {}
		end try
	else
		my write_to_file("[", jsonFile, false)
		set bibJSON to {}
		set currentBibs to {}
		set lastUpdate to (current date)
		set dateString to lastUpdate as string
		set dList to my convertDate(dateString)
		set cmd to "xattr -w 'com.apple.metadata:kMDSyncDate#S' '" & dateString & "' '" & myJSONFile & "'"
		do shell script cmd
	end if
end tell

set theDate to current date
set theSeconds to theDate - lastUpdate

set modKeys to {}
set bibsAdded to {}
set bibsSubtracted to {}

tell application "Bookends"
	tell front library window
		set theIDs to get citekey of publication items of group item myGroup
		set matchingPubs to sql search "dateModified > datediff( now(), '01/01/1904 00:00:00', 'second' ) - " & theSeconds
		repeat with thePub in matchingPubs
			if citekey of thePub is not "" then copy citekey of thePub to end of modKeys
		end repeat
		repeat with x from 1 to count of items of theIDs
			set n to item x of theIDs
			if n is in theIDs and n is not in currentBibs and n is not "" then
				set theItem to (publication items whose citekey is n)
				set theRecord to (format theItem using "BibTeX.fmt") as string
				set theJSON to do shell script "echo " & quoted form of theRecord & " | /usr/local/bin/pandoc -f biblatex -t csljson"
				tell application "JSON Helper" to set theRecord to read JSON from theJSON
				set the end of bibJSON to item 1 of theRecord
				set the end of bibsAdded to n
			end if
		end repeat
		repeat with x from 1 to count of items of currentBibs
			set n to item x of currentBibs
			if n is in modKeys and n is not in bibsAdded then
				set theItem to (publication items whose citekey is n)
				set theRecord to (format theItem using "BibTeX.fmt") as string
				set theJSON to do shell script "echo " & quoted form of theRecord & " | /usr/local/bin/pandoc -f biblatex -t csljson"
				tell application "JSON Helper" to set theRecord to read JSON from theJSON
				set item x of bibJSON to item 1 of theRecord
			else if n is not in theIDs then
				set bibJSON to (items 1 thru (x - 1)) of bibJSON & (items (x + 1) thru -1) of bibJSON
			end if
		end repeat
		tell application "JSON Helper" to set finalJSON to make JSON from bibJSON
	end tell
end tell

my write_to_file(finalJSON, jsonFile, false)
set dateString to (current date) as string
set cmd to "xattr -w 'com.apple.metadata:kMDSyncDate#S' '" & dateString & "' '" & myJSONFile & "'"
set newT to (time of (current date))
set diffT to newT - originalT
set output to " Export took " & diffT & " seconds"
display notification output with title "newJSON exporter V1.0"

on readFile(theFile)
	-- Convert the file to a string
	set theFile to theFile as string
	
	-- Read the file and return its contents
	return read file theFile
end readFile

on write_to_file(this_data, target_file, append_data)
	try
		set the target_file to the target_file as string
		set the open_target_file to open for access file target_file with write permission
		if append_data is false then set eof of the open_target_file to 0
		write this_data to the open_target_file as «class utf8» starting at eof
		close access the open_target_file
		return true
	on error
		try
			close access file target_file
		end try
		return false
	end try
end write_to_file

on convertDate(inDate)
	set dateSections to {}
	set dateSections to my splitString(inDate, " ")
	return dateSections
end convertDate

on joinList(aList, delimiter)
	set retVal to ""
	set prevDelimiter to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set retVal to aList as string
	set AppleScript's text item delimiters to prevDelimiter
	return retVal
end joinList

on splitString(aString, delimiter)
	set retVal to {}
	set prevDelimiter to AppleScript's text item delimiters
	log delimiter
	set AppleScript's text item delimiters to {delimiter}
	set retVal to every text item of aString
	set AppleScript's text item delimiters to prevDelimiter
	return retVal
end splitString
