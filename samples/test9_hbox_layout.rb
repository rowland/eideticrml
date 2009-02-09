$: << File.dirname(__FILE__) + '/../'

require 'erml_widgets'
require 'erml_styles'

include EideticRML::Widgets
include EideticRML::Styles

doc = Document.new
doc.styles.add('layout', :id => 'hbox', :padding => '18')

page = Page.new(doc, :units => 'in', :margin => '1')
Paragraph.new(page, :underline => true, :align => 'top', :text => "HBox Layout")
div = Container.new(page, :layout => 'hbox', :padding => '5pt', :border => 'solid')
Lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
Paragraph.new(div, :align => 'left', :border => 'dotted', :text_align => :left, :width => 2, :padding => '5pt', :text => Lorem)
Paragraph.new(div, :text_align => :justify, :padding_top => '5pt', :width => '100%', :text => Lorem)
Paragraph.new(div, :align => 'right', :border => 'dashed', :text_align => :right, :width => 2, :padding => '5pt', :text => Lorem)

pathname = "#{File.basename($0, '.rb')}.pdf"
File.open(pathname, 'w') { |f| f.write(doc) }
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
