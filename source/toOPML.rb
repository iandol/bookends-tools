require 'nokogiri'

opml = Nokogiri::XML::Builder.new {
	opml(:version => '2.0') {
		head {
			title        'Bookends Exported references'
			dateCreated  Time.now.to_s
		}
		body {
			outline( 
				:text => 'Example 1', 
				:description => "blah",
				:htmlUrl => 'bookends://sonnysoftware.com/34254',
				:type => 'Bookends Reference') {
				outline( 
					:text => 'Example 2', 
					:description => "blah",
					:htmlUrl => 'bookends://sonnysoftware.com/34254',
					:type => 'Bookends Reference')
			}
		}
	}
}
puts opml.to_xml