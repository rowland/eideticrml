$: << File.dirname(__FILE__) + '/../'

require 'erml_widgets'
require 'erml_styles'

include EideticRML::Widgets
include EideticRML::Styles

doc = Document.new(nil, :units => :in)
zapf = doc.styles.add('font', :id => 'zapf', :name => 'ZapfDingbats', :size => 12)
bstar = doc.styles.add('bullet', :id => 'bstar', :font => 'zapf', :text => 0x4E.chr)
pstar = doc.styles.add('para', :id => 'pstar', :bullet => 'bstar')

page = Page.new(doc, :margin => '1')
Paragraph.new(page, :underline => true, :text => "Bullets")
Paragraph.new(page, :bullet => 'bstar', :text => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
Paragraph.new(page, :style => 'pstar', :text => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
Paragraph.new(page, :bullet => 'bstar', :font_style => 'BoldOblique', :text => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")

pathname = "#{File.basename($0, '.rb')}.pdf"
File.open(pathname, 'w') { |f| f.write(doc) }
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
