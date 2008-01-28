$: << File.dirname(__FILE__) + '/../'

require 'erml_widgets'
require 'erml_styles'

include EideticRML::Widgets
include EideticRML::Styles

doc = Document.new
blue_dash = doc.styles.add('pen', :id => 'blue_dash', :color => 'Blue', :width => '4pt', :pattern => 'dashed')
page = Page.new(doc)
page.units 'in'
page.margins '1'
rect = Rectangle.new(page, :width => '100%', :height => '2', :borders => 'blue_dash', :corners => '0.5')

pathname = "#{File.basename($0, '.rb')}.pdf"
File.open(pathname, 'w') { |f| f.write(doc) }
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
