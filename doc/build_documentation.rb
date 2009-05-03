require 'rubygems'
#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

$:.unshift File.expand_path(File.dirname(__FILE__))
$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), '..')
require 'haml'
require 'erml'

class DocumentationBuilder
  def render(filename)
    @dirname ||= begin
      if File.exist?(filename)
        File.expand_path(File.dirname(filename))
      else
        File.expand_path(File.dirname(__FILE__))
      end
    end
    basename = File.basename(filename)
    template = File.read(File.join(@dirname, basename))
    Haml::Engine.new(template).render(binding)
  end
end

filename = File.expand_path(ARGV.shift || File.join(File.dirname(__FILE__), 'EideticRML.erml.haml'))
dirname = File.dirname(filename)
pdfname = File.join(dirname, 'EideticRML.pdf')
xml = DocumentationBuilder.new.render(filename)
pdf = EideticRML::XmlParser.parse(xml)
File.open(pdfname,'w') { |f| f.write(pdf) }
`open #{pdfname}`
