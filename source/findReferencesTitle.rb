#!/usr/bin/env ruby
require 'json'
#======class definition======
class FindReferencesTitle
	attr_accessor :version, :using_alfred
	VER = '1.0.3'.freeze
	
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
		list = osascript <<-EOT
		tell application "Bookends"
			return «event RubySQLS» "#{@SQL}"
		end tell
		EOT
		@list = list.chomp.split("\r")
	end

	def getRecords()
		return unless @cansearch
		return if @list.empty?
		mylist = @list.join(",")
		myorder = ['title','authors','date','myid']
		rec = osascript <<-EOT
		tell application "Bookends"
			set mynull to ASCII character 30
			set ti to «event RubyRFLD» "#{mylist}" given string:"title"
			set au to «event RubyRFLD» "#{mylist}" given string:"authors"
			set da to «event RubyRFLD» "#{mylist}" given string:"thedate"
			set myid to «event RubyRFLD» "#{mylist}" given string:"uniqueID"
			return ti & mynull & au & mynull & da & mynull & myid
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
			when 'myid'
				thisrec.each_with_index do |myid, j|
					myid = '0' if myid.to_s.empty?
					@uuid[j] = myid.chomp.strip
				end
			end		
		end
	end

	def returnResults
		if @uuid.empty?
			returnNullResults;return
		end
		if @using_alfred
			jsonin = []
			@uuid.each_with_index do |uuid, i|
				jsonin[i] = {
					uid: uuid,
					arg: uuid,
					title: @authors[i] + ' ' + @date[i],
					subtitle: @title[i],
					icon: {path: "file.png"}
				}
			end
			jsono= { comment: "RAW=#{@raw} | NAMES=#{@names} | YEAR=#{@year} | SQL=#{@SQL}",
				items: jsonin,
				length: jsonin.length }
			puts JSON.pretty_generate(jsono)
		else
			puts "UUIDS: #{uuid.join(',')}"
		end
	end

	def returnNullResults
		if @using_alfred
			jsono = { comment: "Null Results", 
			items: [ ],
			length: 0 }
			puts JSON.pretty_generate(jsono)
		else
			puts 'No results found!'
		end
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
	fR.constructSQL
	fR.doSQLSearch
	fR.getRecords
	fR.returnResults
end
