#!/usr/bin/env ruby

require 'benchmark/ips'
require_relative 'findReferences.rb'

#----we monkey patch to add alternative getResults for comparison
class FindReferences
    def getRecords2() #original version, no batching
    return unless @cansearch
    @list.each_with_index do |uuid, i|
      ti = osascript <<-EOT
      tell application "Bookends"
        return «event RubyRFLD» #{uuid} given string:"title"
      end tell
      EOT
      @title[i] = ti.chomp.strip

      au = osascript <<-EOT
      tell application "Bookends"
        return «event RubyRFLD» #{uuid} given string:"authors"
      end tell
      EOT
      @authors[i] = au.split(',')[0]

      da = osascript <<-EOT
      tell application "Bookends"
        return «event RubyRFLD» #{uuid} given string:"thedate"
      end tell
      EOT
      @date[i] = da.chomp.strip.split(' ')[0]
    end
    @uuid = @list
  end

  def getRecords3() #batch into one call per reference
    return unless @cansearch
    @list.each_with_index do |uuid, i|
      rec = osascript <<-EOT
      tell application "Bookends"
        set mynull to ASCII character 30
        set ti to «event RubyRFLD» "#{uuid}" given string:"title"
        set au to «event RubyRFLD» "#{uuid}" given string:"authors"
        set da to «event RubyRFLD» "#{uuid}" given string:"thedate"
        set myid to «event RubyRFLD» "#{uuid}" given string:"uniqueID"
        return ti & mynull & au & mynull & da & mynull & myid
      end tell
      EOT
      rec = rec.split("\u001E")
      @title[i] = rec[0].chomp.strip
      @authors[i] = rec[1].chomp.strip.split(',')[0]
      @date[i] = rec[2].chomp.strip.split(' ')[0]
      @uuid[i] = rec[3].chomp.strip
    end
  end

  def getRecords4() #batch references and call for each item
    return unless @cansearch
    mylist = @list.join(",")
    ti = osascript <<-EOT
    tell application "Bookends"
      return «event RubyRFLD» "#{mylist}" given string:"title"
    end tell
    EOT
    titleII = ti.split("\u0000") unless ti.nil?
    titleII.map! { |ti| ti.gsub(/[\n\r]/,'') }

    da = osascript <<-EOT
    tell application "Bookends"
      return «event RubyRFLD» "#{mylist}" given string:"thedate"
    end tell
    EOT
    dateII = da.split("\u0000") unless da.nil?
    dateII.map! { |da| da.split(' ')[0] }

    aut = osascript <<-EOT
    tell application "Bookends"
      return «event RubyRFLD» "#{mylist}" given string:"authors"
    end tell
    EOT
    authorsII = aut.split("\u0000") unless aut.nil?
    authorsII.map! { |author| author.split(',')[0] }
  end
end

searchterm = ARGV[0]
searchterm = 'Zipser' if searchterm.nil?
puts "===>>> Benchmarking #{searchterm}"

Benchmark.ips do |x|
  x.config(:time => 5, :warmup => 2)

  x.report('getRecords') do
    ss = FindReferences.new
    ss.using_alfred = true
    ss.parseSearch(["#{searchterm}"])
    ss.constructSQL
    ss.doSQLSearch
    ss.getRecords
  end

  x.report('getRecords2') do
    ss = FindReferences.new
    ss.using_alfred = true
    ss.parseSearch(["#{searchterm}"])
    ss.constructSQL
    ss.doSQLSearch
    ss.getRecords2
  end

  x.report('getRecords3') do
    ss = FindReferences.new
    ss.using_alfred = true
    ss.parseSearch(["#{searchterm}"])
    ss.constructSQL
    ss.doSQLSearch
    ss.getRecords3
  end

  x.report('getRecords4') do
    ss = FindReferences.new
    ss.using_alfred = true
    ss.parseSearch(["#{searchterm}"])
    ss.constructSQL
    ss.doSQLSearch
    ss.getRecords3
  end
  x.compare!
end
