#!/usr/bin/env ruby
require 'json'
# this converts to -e line format so osascript can run, pass in a heredoc
# beware this splits on \n so can't include them in the applescript itself
def osascript(script)
	cmd = ['osascript'] + script.split(/\n/).map { |line| ['-e', line] }.flatten
	IO.popen(cmd) { |io| return io.read }
end

# get our JSON record from Bookends
return if ARGV.nil?
id = ARGV[0].to_s
rec = osascript <<-APPL
tell application "Bookends"
	return «event RubyRJSN» "#{id}" given string:"authors,thedate,uniqueID,user1"
end tell
APPL
return if rec.nil? || rec.empty?
rec = JSON.parse(rec)

# parse the record
author = rec[0]['authors'].chomp.strip.split(',')[0]
author = 'Unknown' if author.to_s.empty?
date = rec[0]['thedate'].chomp.strip.split(%r{[\s\/-]})[0]
date = '????' if date.nil? || date.empty?
uuid = rec[0]['uniqueid'].to_s.chomp.strip
uuid = '-1' if uuid.nil? || uuid.empty?
key = rec[0]['user1'].to_s.chomp.strip
key = '' if key.nil? || key.empty?

# generate the output
format = 'Bookends'
unless ENV['tempCitationStyle'].nil?
	format = ENV['tempCitationStyle']
end
case format.downcase
when 'pandoc'
	out = '[@' + key + ']'
when 'mmd'
	out = '[#' + key + ']'
when 'latex'
	out = '\\\\cite[]{' + key + '}'
else
	out = '{' + author + ', ' + date + ', #' + uuid + '}'
end
exec("echo '#{out}' | tr -d '\n' | pbcopy -Prefer txt")
