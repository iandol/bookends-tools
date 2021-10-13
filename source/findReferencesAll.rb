#!/usr/bin/env ruby
require 'json'
#======class definition======
class FindReferencesAll
	attr_accessor :version, :using_alfred, :attachments_folder
	VER = '1.1.3'.freeze
	#--------------------- constructor
	def initialize
		@version = VER
		@using_alfred = false
		@attachments_folder = ''
		@cansearch = false
		@comment = ''
		@raw = ''
		@names = []
		@year = ''
		@SQL = ''
		@list = []
		@authors = []
		@editors = []
		@title = []
		@date = []
		@uuid = []
		@attachments = []
		@key = []
		@BEVersion = 12
	end

	def parseSearch(input)
		return if input.nil? || input.empty?

		@raw = input
		input.each do |my_input|
			next if my_input.nil? || my_input.empty?
			phrase = my_input.match(/'([^']+)'/) # is there a quoted phrase?
			unless phrase.nil?
				@names.push(phrase[1])
				my_input = phrase.post_match # add only the post match to the input for parsing
			end
			my_input = my_input.gsub(/^'/, '') # possibly didn't close the quote; remove the opening quote
			next if my_input.nil? || my_input.empty?
			my_input = my_input.split(' ')
			my_input.each do |fragment|
				fragment = fragment.chomp.strip
				if fragment =~ /\A-?\d{1,4}\z/
					@year = fragment.to_s
				elsif fragment =~ /[\w]+/
					@names.push(fragment)
				end
			end
		end
		@cansearch = true unless @names.empty?
	end

	def constructSQL
		return unless @cansearch

		@names.each do |name|
			if @SQL.empty?
				@SQL = "(allFields REGEX '(?i)#{name}')"
			else
				@SQL += " AND (allFields REGEX '(?i)#{name}')"
			end
		end
		@SQL = '(' + @SQL + ") AND thedate REGEX '#{@year}'" unless @year.empty?
	end

	def doSQLSearch
		return unless @cansearch
		rec = osascript <<-APPL
		tell application "Bookends"
			set mynull to ASCII character 30
			set results to «event RubySQLS» "#{@SQL}"
			set BEversion to "12"
			try
				set BEversion to «event RubyVERS»
			end try
			return results & mynull & BEversion
		end tell
		APPL
		rec = rec.split("\u001E")
		@list = rec[0].chomp.split("\r")
		@BEVersion = rec[1].chomp.strip.to_f unless rec[1].nil? || rec[1].empty?
	end

	def getRecords
		return unless @cansearch
		return if @list.empty?

		mylist = @list.join(',')
		rec = osascript <<-APPL
		tell application "Bookends"
			return «event RubyRJSN» "#{mylist}" given string:"title,authors,editors,thedate,attachments,user1"
		end tell
		APPL
		rec = JSON.parse(rec)
		rec.each_with_index do |thisrec, i|
			@title[i] = thisrec['title'].chomp.strip
			@title[i] = 'Blank' if @title[i].nil? || @title[i].empty?

			@authors[i] = parseAuthors(thisrec['authors'])
			@editors[i] = parseAuthors(thisrec['editors'])

			@date[i] = thisrec['thedate'].chomp.strip.split(/[\s\/-]/)[0]
			@date[i] = '????' if @date[i].nil? || @date[i].empty?

			@uuid[i] = thisrec['uniqueID'].to_s.chomp.strip
			@uuid[i] = '-1' if @uuid[i].nil? || @uuid[i].empty?

			@attachments[i] = parseAttachments(thisrec['attachments'])

			@key[i] = thisrec['user1'].to_s.chomp.strip
			@key[i] = '' if @key[i].nil? || @key[i].empty?
		end
	end

	def getRecordsLegacy
		return unless @cansearch
		return if @list.empty?

		mylist = @list.join(',')
		myorder = ['title', 'authors', 'date', 'uniqueid']
		rec = osascript <<-APPL
		tell application "Bookends"
			set mynull to ASCII character 30
			set ti to «event RubyRFLD» "#{mylist}" given string:"title"
			set au to «event RubyRFLD» "#{mylist}" given string:"authors"
			set da to «event RubyRFLD» "#{mylist}" given string:"thedate"
			set uid to «event RubyRFLD» "#{mylist}" given string:"uniqueID"
			return ti & mynull & au & mynull & da & mynull & uid
		end tell
		APPL
		rec = rec.split("\u001E")
		rec.each_with_index do |thisrec, i|
			thisrec = thisrec.split("\u0000")
			case myorder[i]
			when 'title'
				thisrec.each_with_index do |ti, j|
					ti = 'Unknown' if ti.to_s.empty?
					@title[j] = ti.chomp.strip
					@attachments[j] = ''
					@key[j] = ''
				end
			when 'authors'
				thisrec.each_with_index do |au, j|
					au = 'Unknown' if au.to_s.empty?
					@authors[j] = au.chomp.strip.split(',')[0]
				end
			when 'date'
				thisrec.each_with_index do |da, j|
					da = 'Unknown' if da.to_s.empty?
					@date[j] = da.chomp.strip.split(/[\s\/-]/)[0]
				end
			when 'uniqueid'
				thisrec.each_with_index do |uid, j|
					uid = '0' if uid.to_s.empty?
					@uuid[j] = uid.chomp.strip
				end
			end
		end
	end

	def returnResults
		returnNullResults if @uuid.empty?
		return if @uuid.empty?

		jsonin = []
		@uuid.each_with_index do |uuid, i|
			icon = 'file.png' # icon = 'file+attachment.png' unless @attachments[i].empty?
			@authors[i] =~ /Unknown/ ? name=@editors[i] : name=@authors[i]
			name = 'Unknown' if name.nil? || name.empty?
			if @attachments[i].nil? || @attachments[i].empty?
				title = name + '  (' + @date[i] + ')'
				jsonin[i] = {
					uid: uuid,
					arg: uuid,
					title: title,
					subtitle: @title[i],
					icon: { path: icon.to_s }
				}
			else
				title = name + '  (' + @date[i] + ')  📎'
				jsonin[i] = {
					uid: uuid,
					arg: uuid,
					title: title,
					quicklookurl: @attachments[i],
					subtitle: @title[i],
					icon: { path: icon.to_s },
					variables: { PDF: @attachments[i] }
				}
			end
		end
		jsono = {
			comment: "NAMES=#{@names.join(' & ')} | YEAR=#{@year} | SQL=#{@SQL}",
			items: jsonin,
			length: jsonin.length
		}
		puts JSON.generate(jsono)
	end

	def returnNullResults
		if @using_alfred
			jsono = {
				comment: "NO RESULTS! NAMES=#{@names.join(' & ')} | YEAR=#{@year} | SQL=#{@SQL}",
				items: [],
				length: 0
			}
			puts JSON.generate(jsono)
		else
			puts "No results found! NAMES=#{@names.join(' & ')} | YEAR=#{@year} | SQL=#{@SQL}"
		end
	end

	#=== set up et al., etc based on author numbers
	def parseAuthors(myInput)
		return 'Unknown' if myInput.nil? || myInput.empty?

		authors = myInput.chomp.strip.split("\n")
		return processAuthor(authors[0]) if authors.length == 1
		return processAuthor(authors[0]) + ' & ' + processAuthor(authors[1]) if authors.length == 2
		return processAuthor(authors[0]) + '  …  ' + processAuthor(authors[-1])
	end

	def processAuthor(authorName)
		familyName = 'Unknown'
		initial = ''
		unless authorName.nil?
			s = authorName.split(',')
			if s.length == 1 && !s[0].empty?
				familyName = s[0].chomp.strip
			elsif s.length == 2 && !s[0].empty?
				familyName = s[0].chomp.strip
				unless s[1].nil? || s[1].empty?
					ini = s[1].gsub(/^\s*(\w{1})(.*)/, '\1')
					initial = ' ' + ini unless ini.nil? || ini.empty?
				end
			else
				familyName = 'Unknown'
			end
		end
		return familyName + initial
	end

	def parseAttachments(att)
		att = att.split("\n")
		out = @attachments_folder + att[0] unless att.nil? || att.empty?
		#attachment.each do | att |
		#	 out = out + ',' + @attachments_folder + att unless att.nil? || att.empty?
		#end
		return out
	end

	def doSearch
		constructSQL
		doSQLSearch
		if @BEVersion >= 13
			getRecords
		else
			getRecordsLegacy
		end
		returnResults
	end

	# this converts to -e line format so osascript can run, pass in a heredoc
	# beware this splits on \n so can't include them in the applescript itself
	def osascript(script)
		cmd = ['osascript'] + script.split(/\n/).map { |line| ['-e', line] }.flatten
		IO.popen(cmd) { |io| return io.read }
	end
end
#====== end Class ======

#=== Create object and run it ===
fR = FindReferencesAll.new
# check if running under alfred
fR.using_alfred = true unless ENV['alfred_version'].nil?
# check if we were passed the attachment folder path
fR.attachments_folder = ENV['attachmentsFolder'] + '/' unless ENV['attachmentsFolder'].nil?

if ARGV.nil? || ARGV.empty?
	fR.returnNullResults
else
	fR.parseSearch(ARGV)
	fR.doSearch
end
