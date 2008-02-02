$: << File.dirname(__FILE__) + '/../'

require 'erml_widgets'
require 'erml_styles'

include EideticRML::Widgets
include EideticRML::Styles

doc = Document.new
doc.styles.add('layout', :id => 'flow', :manager => 'flow', :padding => '12pt')
doc.styles.add('pen', :id => 'blue_dash', :color => 'Blue', :width => '2pt', :pattern => 'dashed')
doc.styles.add('pen', :id => 'red_dash', :color => 'Red', :width => '2pt', :pattern => 'dashed')

page = Page.new(doc, :units => 'in', :margin => '1', :layout => 'flow')
Paragraph.new(page, :underline => true, :text => "Flow Layout")
Paragraph.new(page, :border => 'dotted', :text_align => :justify, :text => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
Paragraph.new(page, :border_right => 'dashed', :width => "3", :text_align => :justify, :text => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
Paragraph.new(page, :width => "3.3", :text_align => :justify, :text => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
Rectangle.new(page, :width => '2', :height => '1', :border => 'blue_dash')
Rectangle.new(page, :width => '2', :height => '2', :border => 'red_dash')
Rectangle.new(page, :width => '2', :height => '1', :border => 'blue_dash')
Rectangle.new(page, :width => '4', :height => '0.5', :border => 'red_dash')
Rectangle.new(page, :width => '4', :height => '0.5', :border => 'blue_dash')

pathname = "#{File.basename($0, '.rb')}.pdf"
File.open(pathname, 'w') { |f| f.write(doc) }
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
