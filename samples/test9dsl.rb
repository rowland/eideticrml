$: << File.dirname(__FILE__) + '/../'

require 'erml'

doc = EideticRML::Builder.new do
  styles do
    layout :id => 'hbox', :padding => '18'
  end
  pages do
    page :units => 'in', :margin => '1' do
      p :underline => true, :align => 'top', :text => "HBox Layout"
      hbox :padding => '5pt', :border => 'solid' do
        p :align => 'left', :border => 'dotted', :text_align => :left, :width => 2, :padding => '5pt' do
          text "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        end
        p :text_align => :justify, :padding_top => '5pt', :width => '100%' do
          text "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        end
        p :align => 'right', :border => 'dashed', :text_align => :right, :width => 2, :padding => '5pt' do
          text "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        end
      end
    end
  end
end

pathname = "#{File.basename($0, '.rb')}.pdf"
doc.print(:file => pathname)
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
