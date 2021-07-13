#!/usr/bin/env ruby

# This script copies a selection and converts formatted author-date citations back to LaTeX citekeys for rescanning, e.g. this:
# (Chichilnisky and Kalmar, 2002; Zaghloul et al., 2003; Liang and Freed, 2010, 2012; Freed, 2017)
# gets turned into this:
# [chichilnisky2002; zaghloul2003; liang2010; liang2012; freed2017]
#
# It can handle smae name, multiple year citations but cannot handle ambiguous citation; to solve this it
# basically puts all possible citation keys in so (Li et al., 2020) becomes [li2020a; li2020] - it is up to the
# user to manually solve these, but they will at least be flagged by Bookends scan.

# converts to -e line format so osascript can run, pass in a heredoc
# beware this splits on \n so can't include them in the applescript itself
def osascript(script)
	cmd = ['osascript'] + script.split(/\n/).map { |line| ['-e', line] }.flatten
	IO.popen(cmd) { |io| return io.read }
end

# (Chichilnisky and Kalmar, 2002; Li et al., 2020; Zaghloul et al., 2003; Liang and Freed, 2010, 2012; Freed, 2017)

#t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
rec = osascript <<-APPL
tell application "System Events"
	keystroke "c" using command down
	delay 0.25
end tell
APPL
#t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
#puts "Ruby ran applescript 1 in #{t2 - t1} seconds"
clip = %x(pbpaste)
return if clip.nil? || clip.empty?

cite = /([^\(\)\;]+)/
final = ""
keys = []
clip.scan(cite) {|c|
	c = c[0].chomp.strip
	c.gsub!(/ and /, ' ')
	c.gsub!(/ et\.? al\.?/, '')
	c.gsub!(/[\(\)\[\]\{\}\;]/, '')
	parts = c.split(',')
	if parts.nil? || parts.empty? || parts.length < 2
		next
	end
	name = []
	year = []
	for i in 0..parts.length-2 do
		parts[0].gsub!(/ \w+/,'')
		name[i]= parts[0].downcase.strip.chomp
		year[i] = parts[i+1].strip.chomp
	end
	for i in 0..name.length-1
		keys = keys.push("#{name[i]}#{year[i]}")
	end
}

return if keys.nil? || keys.empty?
fkeys = []
keys.each {|key|
	res = osascript <<-APPL
	tell application "Bookends"
		set pubList to sql search "user1 REGEX '(?i)^#{key}'"
		set nlist to ""
		repeat with aPub in pubList
			set nlist to nlist & (citekey of aPub as string) & " "
		end repeat
		return nlist
	end tell
	APPL
	if res.nil? || res.empty?
		fkeys.push("?#{key}?")
	else
		fkeys.push(res.strip.chomp)
	end
}

return if fkeys.nil? || fkeys.empty?
final = "[" + fkeys.join('; ') + "]"
%x(printf "#{final}" | pbcopy)

#t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
osascript <<-APPL
tell application "System Events"
	keystroke "v" using command down
end tell
APPL
#t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
#puts "Ruby ran applescript 2 in #{t2 - t1} seconds"
