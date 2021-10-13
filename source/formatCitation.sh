#!/usr/bin/env zsh
# This script creates plain text, or 
# RTF with a comment holding a link back to bookends.
# Scrivener can make comments annotation by setting:
# defaults write com.literatureandlatte.scrivener3 KBRTFImportCommentsInline 1

UUID=$1
USERTF=$citeUsesRTF
LINKTEXT=$commentText
USEANNOTATION='false' # will use $scrivenerUsesAnnotation, but this is still WIP

if [[ $usePandocFormat -lt 1 ]]; then
	CITEMARKER='#'
else
	CITEMARKER='@'
fi

BIBKEY=$(/usr/bin/osascript << EOT
tell application "Bookends"
		return «event ToySRFLD» "$UUID" given string:"user1"
end tell
EOT
)

URL="bookends://sonnysoftware.com/$UUID"
LINKT=$(echo $LINKTEXT | iconv --unicode-subst="\'%02X" -f UTF8 -t ascii)

if [[ $linkOnly  -gt 0 ]]; then
	echo $URL  | tr -d '\n' | pbcopy -Prefer txt
	return
fi

URL="\"$URL\""

RTF1=$(cat << EOT
{\rtf1\ansi\ansicpg1252\cocoartf1561\cocoasubrtf200
[$CITEMARKER$BIBKEY]{\chatn{\*\annotation{\field{\*\fldinst{HYPERLINK $URL}}{\fldrslt $LINKT}}}}   }
EOT
)

# we can't reset the pref just yet
if [[ $USEANNOTATION == 'true' ]]; then
	PREFVAL=$(defaults read com.literatureandlatte.scrivener3 KBRTFImportCommentsInline 2> /dev/null) 
	if [[ $? -ne 0 ]]; then #there was no pref set
		REMOVEPREF=1
	else
		REMOVEPREF=0
	fi
	defaults write com.literatureandlatte.scrivener3 KBRTFImportCommentsInline 1 > /dev/null 2>&1
fi

if [[ $USERTF == 'true' ]]; then
	echo $RTF1 | tr -d '\n' | pbcopy -Prefer rtf
else
	echo "[$CITEMARKER$BIBKEY]" | tr -d '\n' | pbcopy -Prefer txt
fi

# we can't reset the pref just yet
if [[ $USEANNOTATION == 'true' ]]; then
	if [[ $REMOVEPREF -gt 0 ]]; then #there was no pref set
		defaults delete com.literatureandlatte.scrivener3 KBRTFImportCommentsInline > /dev/null 2>&1
	else
		defaults write com.literatureandlatte.scrivener3 KBRTFImportCommentsInline $PREFVAL > /dev/null 2>&1
	fi
fi
