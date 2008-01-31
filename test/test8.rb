$: << File.dirname(__FILE__) + '/../'

require 'erml_widgets'
require 'erml_styles'

include EideticRML::Widgets
include EideticRML::Styles

doc = Document.new
doc.styles.add('layout', :id => 'vbox', :manager => 'vbox', :padding => '18')
doc.styles.add('pen', :id => 'blue_dash', :color => 'Blue', :width => 2, :pattern => 'dashed')
doc.styles.add('pen', :id => 'red_dash', :color => 'Red', :width => 2, :pattern => 'dashed')

page = Page.new(doc, :units => 'in', :margins => '1', :layout => 'vbox')
Paragraph.new(page, :underline => true, :align => 'top', :text => "VBox Layout")
Paragraph.new(page, :borders => 'dotted', :text_align => :justify, :align => 'top', :text => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
Paragraph.new(page, :borders => 'dashed', :text_align => :justify, :text => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
Rectangle.new(page, :height => '0.5', :borders => 'blue_dash', :corners => '0.2')
Rectangle.new(page, :height => '1.0', :borders => 'red_dash', :corners => '0.2')
Rectangle.new(page, :height => '1.0', :borders => 'blue_dash', :corners => '0.2')
Rectangle.new(page, :height => '0.5', :borders => 'red_dash', :corners => '0.2', :align => 'bottom')

pathname = "#{File.basename($0, '.rb')}.pdf"
File.open(pathname, 'w') { |f| f.write(doc) }
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
