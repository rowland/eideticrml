$: << File.dirname(__FILE__) + '/../'

require 'erml'

doc = EideticRML::Builder.new do
  styles do
    layout :id => 'vbox', :padding => '18'
    pen :id => 'blue_dash', :color => 'Blue', :width => 2, :pattern => 'dashed'
    pen :id => 'red_dash',  :color => 'Red',  :width => 2, :pattern => 'dashed'
  end
  pages do
    tag_alias :b,   :span, 'font.style' => 'Bold'
		tag_alias :i,   :span, 'font.style' => "Oblique"
		tag_alias :bi,  :span, 'font.style' => "BoldOblique"
		tag_alias :u,   :span, :underline => true
		tag_alias :red, :span, 'font.color' => "Red"
    page :units => 'in', :margin => 1 do
      p :underline => true, :text => "Rich Text"
      p :text_align => :justify do
        text "Lorem "
        b "ipsum"
        text " dolor sit amet, "
        i "consectetur"
        text " adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
        red "Ut enim ad minim veniam"
        text ", quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      end
      p :text_align => :justify do
        u "Lorem ipsum dolor sit amet"
        text ", consectetur adipisicing elit, sed do eiusmod "
        bi "tempor incididunt"
        text " ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      end
    end
  end
end

pathname = "#{File.basename($0, '.rb')}.pdf"
doc.print(:file => pathname)
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
