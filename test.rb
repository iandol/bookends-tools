#!/usr/bin/env ruby

require 'net/http'
require 'open-uri'
require 'cgi'

url = 'https://api.elsevier.com/content/search/scopus'
url += '?query=DOI%28%22' + CGI.escape('10.1371/journal.pbio.2001045') + '%22%29'
url += '&apiKey=7f59af901d2d86f78a1fd60c1bf9426a'
url += '&httpAccept=application%2Fjson'

#url = "https://www.ruby-lang.org/"

response = ''
uri = URI.parse(url)
begin
	uri.open(:proxy => nil) {|f|
		response = f.read
	 }
rescue Net::ReadTimeout => exception
	response = 'error t: ' + exception.to_s
rescue OpenURI::HTTPError => exception
	response = 'error i: ' + exception.to_s
rescue => exception
	response = 'error: ' + exception.to_s
end

puts response
