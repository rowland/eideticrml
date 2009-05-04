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
  DEFAULT_EXTENSIONS = ['.erml.haml', '.erml']

  def render(filename)
    dirname = File.dirname(filename)
    basename = File.basename(filename)
    Dir.chdir(dirname) do
      template = File.read(fix_ext(basename))
      Haml::Engine.new(template).render(binding)
    end
  end

  def render_doc(filename)
    dirname = File.dirname(filename)
    basename = File.basename(filename).gsub(/\.(erml|haml)/,'')
    pdfname = File.join(dirname, basename + '.pdf')
    xml = render(filename)
    pdf = EideticRML::XmlParser.parse(xml)
    File.open(pdfname,'w') { |f| f.write(pdf) }
    pdfname
  end

private
  def fix_ext(filename)
    DEFAULT_EXTENSIONS.each do |ext|
      return filename + ext if File.exist?(filename + ext)
    end
    return filename
  end
end

filename = File.expand_path(ARGV.shift || File.join(File.dirname(__FILE__), 'EideticRML.erml.haml'))
builder = DocumentationBuilder.new
pdfname = builder.render_doc(filename)

`open #{pdfname}`
