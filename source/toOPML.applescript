#!/usr/bin/osascript
--Script to Export Bookends Notes to OPML file v1.17
--Written by Dave Glogowski (modified by iandol)
--07 August 2017
--
--This script converts Bookends references and associated notes into an OPML structured file which can then be imported into Scrivener's research folder.
--Each reference is a top level card which contains the Title, Author, Date, Type, Publisher, Abstract, and Bookends citation key
--If there are notes associated with a reference, each note creates its own subordinate note card with the Page number (if any), note header, quotes, 
--comments, and keywords (tags).  This allows you to individually review each comment and change its status (label) within Scrivener.
--
--The script does some error checking as follows:
--  - Strips images from notes
--  - Converts double quotes (") to single quotes (')
--  - Converts < > to &lt; and &gt;
--  - Converts ampersand (&) to &amp;
--
--The script is written very modularly so that it can easily be adapted based on changes in OPML syntax, the need to add additional "bad characters", or 
--changes in the Bookends reference or note delimiters or event calls

on run argv
	--Version------------------------------------------------------------------------
	set myVersion to 1.17

	--Start Time----------------------------------------------------------------------
	set originalT to (time of (current date))

	--User Options-------------------------------------------------------------------
	set showCitation to true -- show temp citation in main text (it will always be shown in the child notes)?
	set citationPMID to false -- replace the uniqueID with PMID in the temp citation if present
	set useBibTeXKey to true -- use BiBteX formatting for temp citation
	set showHeaderOption to false -- ask user about header-only cards?

	--Variable Setup-----------------------------------------------------------------
	--Set Counters
	set nbr_references to 0
	set nbr_notes to 0

	--Set Control Variables
	set remove_headers to true
	set userCanceled to false

	--Set Old Text Delimiters
	set tid to AppleScript's text item delimiters
	set note_delimiter to (ASCII character 10) & (ASCII character 10)
	set comma to ","
	set date_separators to {"/", " ", ".", "-"}
	set digits to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
	set era_first_digit to {"1", "2"}

	--set Bookends Delimiters
	set be_page_nbr_delimiter to "@"
	set be_header_delimiter to "#"
	set be_tag_delimiter to "%"
	set be_quote_delimiter to ">"
	set be_cite_delimiter to ";"

	--set image content tags
	set open_image_tag to "<iimg>"
	set end_image_tag to "</iimg>"

	--Set OPML Text variables
	set xml_version to "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>" & return
	set opml_version to "<opml version=\"1.0\">" & return
	set opml_close to "</opml>" & return
	set opml_header to tab & "<head>" & return
	set opml_title to tab & tab & "<title>Bookends to Scrivener OPML File</title>" & return
	set opml_date to tab & tab & "<dateCreated>" & (current date) & "</dateCreated>" & return
	set opml_header_close to tab & "</head>" & return
	set opml_body to tab & "<body>" & return
	set opml_body_close to tab & "</body>" & return
	set opml_outline to tab & tab & "<outline text=\""
	set opml_outline_close to tab & tab & "</outline>" & return
	set opml_notes to "  _note=\""

	--File Name and Setup-----------------------------------------------------------------
	set remove_headers to true
	if showHeaderOption is true then
		--Ask user to remove header only Bookends notes
		try
			set AlertResult to display alert "Remove Bookends Header ONLY note cards?" buttons {"No", "Yes"} default button "Yes" giving up after 2
		end try
		if button returned of AlertResult is "No" then set remove_headers to false
	end if

	set homePath to POSIX path of (path to home folder)
	if (count of argv) > 0 then
		set myPath to POSIX path of (homePath & (item 1 of argv) & "/")
	else
		set myPath to POSIX path of (path to desktop)
	end if
	set myFile to (myPath & "BE-Selection.opml") as POSIX file
	--Interaction with Bookends-----------------------------------------------------------
	tell application "Bookends"
		activate
		--get ids for selected bookends references 
		set selected_ids to «event ToySRUID» "Selection"
		--test to make sure user selected Bookends references
		if selected_ids is "" then
			display dialog "No Boookends References were selected." & return & return & "Please select 1 or more references and restart"
			return false
		end if
		
		--Write OPML Version, Headers, and Open Body statements to File---------------
		my write_to_file(xml_version, myFile, false)
		my write_to_file(opml_version, myFile, true)
		my write_to_file(opml_header, myFile, true)
		my write_to_file(opml_title, myFile, true)
		my write_to_file(opml_date, myFile, true)
		my write_to_file(opml_header_close, myFile, true)
		my write_to_file(opml_body, myFile, true)
		
		set selected_ids to words of selected_ids
		
		--Process Handiling For Each Reference------------------------------------------
		--get citation, quotes, comments, and tags for of the selected references
		repeat with i from 1 to length of selected_ids
			
			--set variables and counters
			set ref_id to item i of selected_ids
			set ref_nbr to ref_id
			set nbr_references to nbr_references + 1
			
			--FOR EACH REFERENCE BUILD THE TOP LEVEL OPML OUTLINE 
			
			--Reference Author or Editor      
			set ref_author to «event ToySRFLD» ref_id given string:"authors"
			if ref_author is "" then set ref_author to «event ToySRFLD» ref_id given string:"editors"
			
			if ref_author is "" then
				set ref_title to "No Authors or Editors"
			else
				set AppleScript's text item delimiters to linefeed
				set author_list to every text item of ref_author
				set author_list_count to length of author_list
				set AppleScript's text item delimiters to comma
				set first_author to (first item of author_list as string)
				set remaining_authors to every text item of first_author
				if (last character of first_author) is comma then set first_author to first_author's text 1 thru -2
				if author_list_count = 1 then
					set ref_author to (first item of remaining_authors as string)
				else if author_list_count = 2 then
					set second_author to (second item of author_list as string)
					set final_authors to every text item of second_author
					set ref_author to (first item of remaining_authors as string) & " and " & (first item of final_authors as string)
				else if author_list_count > 2 then
					set ref_author to (first item of remaining_authors as string) & " et al."
				end if
				set ref_author to my replace_bad_characters(ref_author)
			end if
			set AppleScript's text item delimiters to tid
			
			--Reference Year      
			set ref_date to «event ToySRFLD» ref_id given string:"thedate"
			if ref_date is "" then
				set ref_date to "Undated"
			else
				set ref_date to my replace_bad_characters(ref_date)
				set got_year to false
				repeat with d in date_separators
					set AppleScript's text item delimiters to d
					set date_list to every text item of ref_date
					set AppleScript's text item delimiters to tid
					repeat with k in date_list
						if length of k is 4 then
							if first character of k is in era_first_digit then
								set ref_year to k
								set got_year to true
							end if
						end if
						if got_year then exit repeat
					end repeat
					if got_year then exit repeat
				end repeat
				if got_year then set ref_date to ref_year
			end if
			
			--Reference Title
			set ref_title to «event ToySRFLD» ref_id given string:"title"
			if ref_title is "" then
				set ref_title to "No Title"
			else
				set ref_title to my replace_bad_characters(ref_title)
			end if
			
			--Reference Type (Journal, Book, etc)
			set ref_ris to «event ToySGUID» ref_id given string:"RIS"
			if ref_ris is "" then
				set ref_type to "undefined"
			else
				set ref_type to second word of ref_ris as text
				set ref_type to my replace_bad_characters(ref_type)
			end if
			
			--Reference key (BibTeX key uses user1)
			set ref_key to «event ToySRFLD» ref_id given string:"user1"
			
			--Reference doi
			set ref_doi to «event ToySRFLD» ref_id given string:"user17"
			if ref_doi is not "" then
				set ref_doi to "https://doi.org/" & ref_doi
			end if
			
			--Reference attachments
			set ref_att to «event ToySRFLD» ref_id given string:"attachments"
			
			--Reference url
			set ref_url to «event ToySRFLD» ref_id given string:"url"
			
			--Reference pmid
			set ref_pmid to «event ToySRFLD» ref_id given string:"user18"
			
			--Reference Publisher
			set ref_publisher to «event ToySRFLD» ref_id given string:"publisher"
			if ref_publisher is "" then
				set ref_publisher to "undefined publisher"
			else
				set ref_publisher to my replace_bad_characters(ref_publisher)
			end if
			
			--Reference Abstract
			set ref_abstract to «event ToySRFLD» ref_id given string:"abstract"
			if ref_abstract is "" then
				set ref_abstract to "Abstract not provided"
			else
				set ref_abstract to my replace_bad_characters(ref_abstract)
			end if
			
			--Build Cite Key
			if useBibTeXKey is true then
				set cite_key to "[@" & ref_key & "]"
			else if citationPMID is true then
				set cite_key to "{" & ref_author & ", " & ref_date & ", #" & ref_pmid & "}"
			else
				set cite_key to "{" & ref_author & ", " & ref_date & ", #" & ref_nbr & "}"
			end if
			
			--Form the Reference Card OPML Outline Statement
			set ref_text to opml_outline & ref_author & ", " & ref_date & " (ID:" & ref_nbr & ")\"" & opml_notes & ref_title & "&#10;" & return as text
			if showCitation is true then
				if cite_key is not "" then set ref_text to ref_text & "Cite: " & cite_key & "&#10;" & return as text
			end if
			set ref_text to ref_text & "---------------------------&#10;" & return & ref_abstract & "&#10;" & return as text
			if ref_url is not "" then set ref_text to ref_text & "URL: " & my encodeURL(ref_url) & "&#10;" & return as text
			if ref_doi is not "" then set ref_text to ref_text & "DOI: " & my encodeURL(ref_doi) & "&#10;" & return as text
			if ref_pmid is not "" then set ref_text to ref_text & "PMID: " & ref_pmid & "&#10;" & return as text
			if ref_att is not "" then set ref_text to ref_text & "Attachments: " & my replace_bad_characters(ref_att) & "&#10;" & return as text
			if ref_type is not "" then set ref_text to ref_text & "Type: " & ref_type & "&#10;" & return as text
			set ref_text to ref_text & "Backlink: bookends://sonnysoftware.com/" & ref_nbr & "\">" & return as text
			
			my write_to_file(ref_text, myFile, true)
			
			--Process Handiling For Each Note within Each Reference------------      
			--get notes from this reference
			set ref_notes to «event ToySRFLD» ref_id given string:"notes"
			
			--extract each note and create separate note card (subordinate outline)      
			set AppleScript's text item delimiters to note_delimiter
			set ref_notes to text items of ref_notes
			set AppleScript's text item delimiters to tid
			
			repeat with p from 1 to length of ref_notes
				--reset variables
				set header_only to false
				set keywords to false
				set quotes to false
				set ref_note_header to " "
				set ref_page_nbr to "##"
				set ref_note_title to " "
				set ref_note_text to " "
				set ref_tags to " "
				set ref_quote to " "
				set ref_note_quote to " "
				set ref_note_comment to ""
				
				-- ref_note_item is an individual note within the note stream
				set ref_note_item to item p of ref_notes
				
				--parse note_item for Bookends header and page number
				if ref_note_item is not "" then
					
					set ref_note_list to paragraphs of ref_note_item
					
					--test and process headers   
					if first character in ref_note_item is be_header_delimiter then
						--header
						set ref_note_header to first paragraph in ref_note_item
						--determine if header only and set note contents to rest of notes
						if (count of ref_note_list) > 1 then
							set ref_note_text to text (second paragraph of ref_note_item) thru -1 of ref_note_item
						else
							set ref_note_text to "Header Only"
							if remove_headers is true then set header_only to true
						end if
						--set header, but first test if header also includes page number
						if second character in ref_note_item is be_page_nbr_delimiter then
							--with page number
							set ref_page_nbr to "@" & first word of ref_note_item
							set ref_note_header to text (second word of ref_note_header) thru -1 of ref_note_header
						else
							--without page number
							set ref_note_header to text (first word of ref_note_header) thru -1 of ref_note_header
						end if
					else
						--no header, set title to untitled note and set contents to all of note
						set ref_note_header to "Untitled Note"
						set ref_note_text to ref_note_item
					end if
					
					--test for page numbers      
					if first character in ref_note_item is be_page_nbr_delimiter then
						set ref_page_nbr to "@" & first word of ref_note_item
						set ref_note_text to text (second word of ref_note_item) thru -1 of ref_note_item
					end if
					
					--form the note card title
					set ref_note_title to ref_page_nbr & " - " & ref_note_header
					
					--test note title for well formed contents (bad opml characters)
					set ref_note_title to my replace_bad_characters(ref_note_title)
					
					--Process Handling For Each Line (Paragraph) within Each Note
					--extract each line (paragraph) of the note      
					set AppleScript's text item delimiters to (ASCII character 10)
					set ref_note_text to text items of ref_note_text
					set AppleScript's text item delimiters to tid
					
					repeat with n from 1 to length of ref_note_text
						
						--get and process each paragraph (segement) of the note
						set ref_note_body to item n of ref_note_text
						
						--test notes for well formed contents (ie. no images)
						if (open_image_tag is in ref_note_body) then
							set image_start to (offset of open_image_tag in ref_note_body)
							set image_end to (offset of end_image_tag in ref_note_body) + (length of end_image_tag) - 1
							set first_half to text 1 thru image_start of ref_note_body
							set last_half to text from image_end to -1 of ref_note_body
							set ref_note_body to first_half & " -- Graphics Image Removed --" & last_half
						end if
						
						--test notes for well formed contents (bad opml characters)
						set ref_note_body to my replace_bad_characters(ref_note_body)
						
						if ref_note_body is not "" then
							
							--clear temp vars
							set temp_tag to ""
							set temp_quote to ""
							set no_comment_flag to false
							
							--test for tags
							if first character in ref_note_body is be_tag_delimiter then
								set temp_tags to ref_note_body
								set AppleScript's text item delimiters to be_tag_delimiter
								set temp_tags to text items of temp_tags
								set AppleScript's text item delimiters to space
								set temp_tags to temp_tags as text
								set AppleScript's text item delimiters to tid
								set ref_tags to ref_tags & temp_tags
								set no_comment_flag to true
								set keywords to true
							end if
							
							
							--test for bookends quotes            
							if first character in ref_note_body is be_quote_delimiter then
								set temp_quote to ref_note_body
								set temp_quote to text (second character of temp_quote) thru -1 of temp_quote
								set ref_note_quote to ref_quote & temp_quote
								set no_comment_flag to true
								set quotes to true
							end if
							
							--form note comments
							if no_comment_flag is false then set ref_note_comment to ref_note_comment & ref_note_body & return
							
						end if
						
					end repeat
					
					--form the note card OPML statements
					set ref_key to "Keywords: " & ref_tags & "&#10;" & return
					set ref_quote to "Quote(s): " & ref_note_quote & "&#10;" & return
					set ref_comment to "Comments: " & ref_note_comment & "&#10;" & return
					
					set cite to cite_key
					if useBibTeXKey is true and ref_page_nbr is not "##" then
						set page_nbr to text 2 thru -1 of ref_page_nbr
						set cite to text 1 thru -2 of cite
						set cite to cite & " pp." & page_nbr & "]"
					else if ref_page_nbr is not "##" then
						set cite to text 1 thru -2 of cite
						set cite to cite & " " & ref_page_nbr & "}"
					end if
					set ref_cite_key to "Citation Key: " & cite
					
					set note_card to "" as text
					if keywords is true then set note_card to note_card & ref_key
					if quotes is true then set note_card to note_card & ref_quote
					set note_card to note_card & ref_comment & ref_cite_key
					
					set ref_note_contents to tab & opml_outline & ref_note_title & "\"" & opml_notes & note_card & "\"/>" & return as text
					
					--write contents of note
					if header_only is false then
						my write_to_file(ref_note_contents, myFile, true)
						set nbr_notes to nbr_notes + 1
					end if
				end if
			end repeat
			my write_to_file(opml_outline_close, myFile, true)
		end repeat
	end tell

	my write_to_file(opml_body_close, myFile, true)
	my write_to_file(opml_close, myFile, true)

	set newT to (time of (current date))
	set diffT to newT - originalT

	display notification "Complete" & return & return & "Exported " & nbr_references & " References and " & nbr_notes & " Notes in " & diffT & " seconds" with title "Bookends to OPML exporter V" & myVersion
	return true

end run--end of script **************************************************

--subroutine area ************************************************
--write_to_this_file subroutine
on write_to_file(this_data, target_file, append_data)
	try
		set target_file to target_file as string
		set open_target_file to open for access target_file with write permission
		if append_data is false then set eof of the open_target_file to 0
		write this_data as «class utf8» to open_target_file starting at eof
		close access open_target_file
		return true
		
	on error errMsg number errNum
		if errNum = -49 then
			close access target_file
			set open_target_file to open for access target_file with write permission
			if append_data is false then set eof of the open_target_file to 0
			write this_data as «class utf8» to open_target_file starting at eof
			close access open_target_file
			return true
		else
			display dialog "Write Subroutine Error:" & return & "Target_File: " & target_file & return & "Open_Target_File: " & open_target_file & return & "Error: " & errNum & " - " & errMsg
			close access open_target_file
			return false
		end if
	end try
end write_to_file

--test for well formed contents (bad opml characters) subroutine
on replace_bad_characters(input_string)
	try
		--set arrays for error checking
		set bad_opml_char_array to {"\"", "&", "<", ">"}
		set good_opml_char_array to {"'", "&amp;", "&lt;", "&gt;"}
		set input_string to input_string as string
		set output_string to ""
		set good_char to ""
		
		repeat with x from 1 to count of characters in input_string
			set good_char to character x of input_string
			repeat with y from 1 to length of bad_opml_char_array
				if good_char is equal to item y of bad_opml_char_array then set good_char to item y of good_opml_char_array
			end repeat
			set output_string to output_string & good_char
		end repeat
		return output_string
		
	on error errMsg number errNum
		display dialog "Error replacing bad OPML characters.  Error Number: " & errNum & " - " & errMsg
		return false
	end try
end replace_bad_characters

on findAndReplaceInText(theText, theSearchString, theReplacementString)
	set AppleScript's text item delimiters to theSearchString
	set theTextItems to every text item of theText
	set AppleScript's text item delimiters to theReplacementString
	set theText to theTextItems as string
	set AppleScript's text item delimiters to ""
	return theText
end findAndReplaceInText

on encodeCharacter(theCharacter)
	set theASCIINumber to (the ASCII number theCharacter)
	set theHexList to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
	set theFirstItem to item ((theASCIINumber div 16) + 1) of theHexList
	set theSecondItem to item ((theASCIINumber mod 16) + 1) of theHexList
	return ("%" & theFirstItem & theSecondItem) as string
end encodeCharacter

on encodeText(theText, encodeCommonSpecialCharacters, encodeExtendedSpecialCharacters)
	set theStandardCharacters to "abcdefghijklmnopqrstuvwxyz0123456789"
	set theCommonSpecialCharacterList to "$+!'/?;&@=#%><{}\"~`^\\|*"
	set theExtendedSpecialCharacterList to ".-_:"
	set theAcceptableCharacters to theStandardCharacters
	if encodeCommonSpecialCharacters is false then set theAcceptableCharacters to theAcceptableCharacters & theCommonSpecialCharacterList
	if encodeExtendedSpecialCharacters is false then set theAcceptableCharacters to theAcceptableCharacters & theExtendedSpecialCharacterList
	set theEncodedText to ""
	repeat with theCurrentCharacter in theText
		if theCurrentCharacter is in theAcceptableCharacters then
			set theEncodedText to (theEncodedText & theCurrentCharacter)
		else
			set theEncodedText to (theEncodedText & encodeCharacter(theCurrentCharacter)) as string
		end if
	end repeat
	return theEncodedText
end encodeText

on encodeURL(theText)
	set theEncodedText to encodeText(theText, true, false)
	set theEncodedText to findAndReplaceInText(theEncodedText, "%2F", "/")
	return theEncodedText
end encodeURL
