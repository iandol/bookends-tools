#!/usr/bin/env ruby
require 'json'
#======class definition======
class FindReferencesAll
	attr_accessor :version, :using_alfred, :attachments_folder
	VER = '1.0.8'.freeze
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
		@title = []
		@date = []
		@uuid = []
		@attachments = []
		@key = []
		@BEVersion = 12
	end

	def parseSearch(input)
		input = input[0].split(' ') if input.length == 1
		@raw = input
		input.each do |my_input|
			if my_input =~ /^-?\d{1,4}$/
				@year = my_input.to_s
			elsif my_input =~ /^\S+$/
				@names.push(my_input)
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
		@BEVersion = 13 if rec[1].match(/^13/)
	end

	def getRecords
		return unless @cansearch
		return if @list.empty?
		mylist = @list.join(',')
		rec = osascript <<-APPL
		tell application "Bookends"
			return «event RubyRJSN» "#{mylist}" given string:"title,authors,thedate,attachments,user1"
		end tell
		APPL
		rec = JSON.parse(rec)
		rec.each_with_index do |thisrec, i|
			@title[i] = thisrec['title'].chomp.strip
			@title[i] = 'Blank' if @title[i].nil? || @title[i].empty?

			@authors[i] = parseAuthors(thisrec['authors'])

			@date[i] = thisrec['thedate'].chomp.strip.split(/[\s\/-]/)[0]
			@date[i] = '????' if @date[i].nil? || @date[i].empty?

			@uuid[i] = thisrec['uniqueID'].to_s.chomp.strip
			@uuid[i] = '-1' if @uuid[i].nil? || @uuid[i].empty?

			@attachments[i] = thisrec['attachments'].to_s.chomp.strip
			@attachments[i] = @attachments_folder + @attachments[i] unless @attachments[i].nil? || @attachments[i].empty? 

			@key[i] = thisrec['user1'].to_s.chomp.strip
			@key[i] = '' if @uuid[i].nil? || @uuid[i].empty?
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
		if @uuid.empty?
			returnNullResults; return
		end
		jsonin = []
		@uuid.each_with_index do |uuid, i|
			icon = 'file.png'
			# icon = 'file+attachment.png' unless @attachments[i].empty?
			if @attachments[i].empty?
				jsonin[i] = {
					uid: uuid,
					arg: uuid,
					title: @authors[i] + '  (' + @date[i] + ')',
					subtitle: @title[i],
					icon: { path: icon.to_s }
				}
			else
				jsonin[i] = {
					uid: uuid,
					arg: uuid,
					title: @authors[i] + '  (' + @date[i] + ')  📎',
					quicklookurl: @attachments[i],
					subtitle: @title[i],
					icon: { path: icon.to_s }
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
				comment: 'No Results!',
				items: [],
				length: 0
			}
			puts JSON.generate(jsono)
		else
			puts 'No results found!'
		end
	end

	#=== set up et al., etc based on author numbers
	def parseAuthors(myInput)
		return 'Unknown' if myInput.nil? || myInput.empty?
		authors = myInput.chomp.strip.split("\n")
		if authors.length == 1
			return processAuthor(authors[0])
		elsif authors.length == 2
			return processAuthor(authors[0]) + ' & ' + processAuthor(authors[1])
		else
			return processAuthor(authors[0]) + '  …  ' + processAuthor(authors[-1])
		end
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

	def doSearch
		constructSQL
		doSQLSearch
		if @BEVersion == 13
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
fR.attachments_folder = ENV['attachmentsFolder'] unless ENV['attachmentsFolder'].nil?

if ARGV.nil?
	fR.returnNullResults
else
	fR.parseSearch(ARGV)
	fR.doSearch
end
