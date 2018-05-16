#!/usr/bin/env ruby
require 'json'
#======class definition======
class FindReferencesTitle
	attr_accessor :version, :using_alfred
	VER = '1.0.5'.freeze
	#--------------------- constructor
	def initialize # set up class
		@version = VER
		@using_alfred = false
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
			if my_input.match(/^-?\d{1,4}$/)
				@year = my_input.to_s
			elsif my_input.match(/^\S+$/)
				@names.push(my_input)
			end
		end
		@cansearch = true unless @names.empty?
	end

	def constructSQL()
		return unless @cansearch
		@names.each do |name|
			if @SQL.empty?
				@SQL = "(title REGEX '(?i)#{name}' OR keywords REGEX '(?i)#{name}')"
			else
				@SQL += " AND (title REGEX '(?i)#{name}' OR keywords REGEX '(?i)#{name}')"
			end
		end
		unless @year.empty?
			@SQL = "(" + @SQL + ") AND thedate REGEX '#{@year}'"
		end
	end

	def doSQLSearch()
		return unless @cansearch
		rec = osascript <<-EOT
		tell application "Bookends"
			set mynull to ASCII character 30
			set results to «event RubySQLS» "#{@SQL}"
			set BEversion to "12"
			try
				set BEversion to «event RubyVERS»
			end try
			return results & mynull & BEversion
		end tell
		EOT
		rec = rec.split("\u001E")
		@list = rec[0].chomp.split("\r")
		@BEVersion = 13 if rec[1].match(/^13/)
	end

		def getRecords()
		return unless @cansearch
		return if @list.empty?
		mylist = @list.join(",")
		rec = osascript <<-EOT
		tell application "Bookends"
			return «event RubyRJSN» "#{mylist}" given string:"title,authors,thedate,attachments,user1"
		end tell
		EOT
		rec = JSON.parse(rec)
		rec.each_with_index do |thisrec, i|
			@title[i] = thisrec['title'].chomp.strip
			@title[i] = 'Blank' if @title[i].nil? || @title[i].empty?

			@authors[i] = thisrec['authors'].chomp.strip.split(',')[0]
			@authors[i] = 'Unknown' if @authors[i].nil? || @authors[i].empty?

			@date[i] = thisrec['thedate'].chomp.strip.split(/[\s\/-]/)[0]
			@date[i] = '????' if @date[i].nil? || @date[i].empty?

			@uuid[i] = thisrec['uniqueID'].to_s.chomp.strip
			@uuid[i] = '-1' if @uuid[i].nil? || @uuid[i].empty?

			@attachments[i] = thisrec['attachments'].to_s.chomp.strip
			@attachments[i] = '📎' unless @attachments[i].empty?

			@key[i] = thisrec['user1'].to_s.chomp.strip
			@key[i] = '' if @uuid[i].nil? || @uuid[i].empty?
		end
	end

	def getRecordsLegacy()
		return unless @cansearch
		return if @list.empty?
		mylist = @list.join(",")
		myorder = ['title','authors','date','uniqueid']
		rec = osascript <<-EOT
		tell application "Bookends"
			set mynull to ASCII character 30
			set ti to «event RubyRFLD» "#{mylist}" given string:"title"
			set au to «event RubyRFLD» "#{mylist}" given string:"authors"
			set da to «event RubyRFLD» "#{mylist}" given string:"thedate"
			set uid to «event RubyRFLD» "#{mylist}" given string:"uniqueID"
			return ti & mynull & au & mynull & da & mynull & uid
		end tell
		EOT
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
			#icon = 'file+attachment.png' unless @attachments[i].empty?
			jsonin[i] = {
				uid: uuid,
				arg: uuid,
				title: @authors[i] + ' ' + @date[i] + '   ' + @attachments[i],
				subtitle: @title[i],
				icon: {path: "#{icon}"}
			}
		end
		jsono= { comment: "NAMES=#{@names.join(' & ')} | YEAR=#{@year} | SQL=#{@SQL}",
			items: jsonin,
			length: jsonin.length }
		puts JSON.generate(jsono)
	end

	def returnNullResults
		if @using_alfred
			jsono = { comment: "No Results!", 
			items: [ ],
			length: 0 }
			puts JSON.generate(jsono)
		else
			puts 'No results found!'
		end
	end

	def doSearch
		self.constructSQL
		self.doSQLSearch
		if @BEVersion == 13
			self.getRecords
		else
			self.getRecordsLegacy
		end
		self.returnResults
	end

	# this converts to -e line format so osascript can run, pass in a heredoc
	# beware this splits on \n so can't include them in the applescript itself
	def osascript(script)
		cmd = ['osascript'] + script.split(/\n/).map { |line| ['-e', line] }.flatten
		IO.popen(cmd) { |io| return io.read }
	end
end #====== end Class ======

#=== Create object and run it ===
fR = FindReferencesTitle.new

# check if running under alfred
fR.using_alfred = true unless ENV['alfred_version'].nil?

if ARGV.nil?
	fR.returnNullResults
else
	fR.parseSearch(ARGV)
	fR.doSearch
end
