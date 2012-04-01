#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'TimedSpamRejection'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md', 'CHANGELOG', 'MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc "Run the specs with simplecov"
task :simplecov => [:simplecov_env, :spec]
task :simplecov_env do ENV['SIMPLECOV'] = '1' end

task :default => :spec
