$: << File.dirname(__FILE__) + '/../'

require 'erml'

doc = EideticRML::Builder.new do
  styles do
		layout :id => "flow", :padding => 12
		pen :id => "blue_dash", :color => "Blue", :width => 2, :pattern => "dashed"
		pen :id => "red_dash",  :color => "Red",  :width => 2, :pattern => "dashed"
  end
  pages do
    page :units => 'in', :margin => 1 do
			p :underline => "true", :text => "Flow Layout"
			p :border => "dotted", :text_align => "justify" do
			  text "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
		  end
			p :border_right => "dashed", :width => 3, :text_align => "justify" do
			  text "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
		  end
			p :width => 3.3, :text_align => "justify" do
			  text "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
		  end			  
			rect :width => 2, :height => 1.0, :border => "blue_dash" 
			rect :width => 2, :height => 2.0, :border => "red_dash" 
			rect :width => 2, :height => 1.0, :border => "blue_dash" 
			rect :width => 4, :height => 0.5, :border => "red_dash" 
			rect :width => 4, :height => 0.5, :border => "blue_dash" 
    end
  end
end

pathname = "#{File.basename($0, '.rb')}.pdf"
doc.print(:file => pathname)
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
