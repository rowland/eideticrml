$: << File.dirname(__FILE__) + '/../'

require 'erml_widgets'

include EideticRML::Widgets

doc = Document.new
doc.units("in")
doc.margins("1")

page1 = Page.new(doc)
p1 = Paragraph.new(page1)
p1.font_style('Bold')
p1.align('center')
p1.text("First Page")

page2 = Page.new(doc)
p2 = Paragraph.new(page2)
p2.font_style('Bold')
p2.align('center')
p2.text("Second Page")

pathname = "#{File.basename($0, '.rb')}.pdf"
File.open(pathname, 'w') { |f| f.write(doc) }
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
