--------------------------------------------------------------------
-- SCRIPT FOR EXTRACTING REFERENCES FROM BOOKENDS
--------------------------------------------------------------------
on run argv
	set query to (do shell script "echo " & argv & " | iconv -s -f UTF-8-Mac -t UTF-8") as Unicode text
	tell application "Bookends"
		-- Extract UUID from Bookends
		set refList to {}
		if length of query is greater than 1 then --no point in searching for <=2 letter fragments
			set AppleScript's text item delimiters to {return}
			set refList to text items of («event ToySSQLS» "title REGEX '(?i)" & query as string & "'")
			set AppleScript's text item delimiters to {","}
		end if
		
		set json to "{\"items\": [    " & linefeed
		
		repeat with refItem in refList
			set refItem to contents of refItem
			
			-- Extract first Author
			set refAuthorList to («event ToySRFLD» refItem given string:"authors")
			set AppleScript's text item delimiters to {","}
			set refAuthors to text items of refAuthorList
			set AppleScript's text item delimiters to {"'"}
			set refAuthor to first item of refAuthors
			set AppleScript's text item delimiters to {""}
			
			
			-- Extract and clean (escape " and remove newlines) title for JSON
			set refTitle to («event ToySRFLD» refItem given string:"title")
			set findChars to {linefeed, return, tab, "\""}
			set replaceChars to {" ", " ", " ", "\\\""}
			repeat with i from 1 to length of findChars
				if (item i of findChars) is in refTitle then
					set AppleScript's text item delimiters to {item i of findChars}
					set refTitle to text items of refTitle
					set AppleScript's text item delimiters to {item i of replaceChars}
					set refTitle to refTitle as text
					set AppleScript's text item delimiters to {""}
				end if
			end repeat
			
			-- Extract date
			set refDateRaw to («event ToySRFLD» refItem given string:"thedate")
			--ruby is a bit too slow here, use sed
			--set cmd to "ruby -e 'puts $1 if \"" & refDateRaw & "\" =~ /([12][0-9]{3})/'"
			set cmd to "echo '" & refDateRaw & "' | sed 's/\\([0-9]*\\)\\(.*\\)/\\1/g'"
			set refDate to (do shell script cmd)
			
			-- json formatting
			-- Set json header
			set json to json & linefeed & "{" & linefeed
			set json to json & tab & "\"uid\": \"" & refItem & "\"," & linefeed
			set json to json & tab & "\"arg\": \"" & refItem & "\"," & linefeed
			set json to json & tab & "\"title\": \"" & refAuthor & " " & refDate & "\"," & linefeed
			set json to json & tab & "\"subtitle\": \"" & refTitle & "\"," & linefeed
			set json to json & tab & "\"icon\": {\"path\": \"file.png\"}" & linefeed
			set json to json & "}," & linefeed
		end repeat
		set json to text 1 thru -3 of json
		set json to json & linefeed & "]}" & linefeed
		return json
		
	end tell
end run
