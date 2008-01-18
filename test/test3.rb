$: << File.dirname(__FILE__) + '/../'

require 'erml_widgets'

include EideticRML::Widgets

doc = Document.new
page = Page.new(doc)
page.units("in")
page.margins("1")
p = Paragraph.new(page)
p.text("Hello, World!")

pathname = "#{File.basename($0, '.rb')}.pdf"
File.open(pathname, 'w') { |f| f.write(doc) }
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
