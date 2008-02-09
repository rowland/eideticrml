$: << File.dirname(__FILE__) + '/../'

require 'erml'

doc = EideticRML::Builder.new do
  styles do
    layout :id => 'vbox', :padding => '18'
    pen :id => 'blue_dash', :color => 'Blue', :width => 2, :pattern => 'dashed'
    pen :id => 'red_dash',  :color => 'Red',  :width => 2, :pattern => 'dashed'
  end
  pages do
    page :units => 'in', :margin => 1, :layout => 'vbox' do
      p :underline => true, :align => 'top', :text => "VBox Layout"
      p :border => 'dotted', :text_align => :justify, :align => 'top', :padding => '5pt' do
        text "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      end
      p :border => 'dashed', :text_align => :justify, :padding => '5pt' do
        text "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      end
      rect :height => 0.5, :border => 'blue_dash', :corners => 0.2
      rect :height => 1.0, :border => 'red_dash',  :corners => 0.2
      rect :height => 1.0, :border => 'blue_dash', :corners => 0.2
      rect :height => 0.5, :border => 'red_dash',  :corners => 0.2, :align => 'bottom'
    end
  end
end

pathname = "#{File.basename($0, '.rb')}.pdf"
doc.print(:file => pathname)
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
