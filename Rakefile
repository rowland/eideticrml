require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rcov/rcovtask'

spec = Gem::Specification.new do |s|
  s.name = "eideticrml"
  s.version = "0.0.1"
  s.date = "2008-01-08"
  s.summary = "Report Markup Language"
  s.requirements = "Ruby 1.8.x, eideticpdf"
  s.require_path = '.'
  s.autorequire = 'erml'
  s.email = "brent.rowland@eideticsoftware.com"
  s.homepage = "http://www.eideticsoftware.com"
  # s.rubyforge_project = "eideticrml"
  # s.test_file = "test/pdf_tests.rb"
  s.has_rdoc = false
  # s.extra_rdoc_files = ['README']
  # s.rdoc_options << '--title' << 'Eidetic RML' << '--main' << 'README' << '-x' << 'test'
  s.files = ['erml.rb', 'erml_layout_managers.rb', 'erml_styles.rb', 'erml_support.rb', 'erml_widgets.rb', 'Rakefile'] + 
    FileList["test/test*.rb"] + FileList["test/test*.erml"] + ['test/testimg.jpg']
  s.platform = Gem::Platform::RUBY
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end

Rake::TestTask.new do |t|
  # t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

Rcov::RcovTask.new do |t|
  # t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end