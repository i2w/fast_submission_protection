$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "timed_spam_rejection/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "timed_spam_rejection"
  s.version     = TimedSpamRejection::VERSION
  s.authors     = ["Ian White", "Nicholas Rutherford"]
  s.email       = ["ian@i2wdev.com"]
  s.homepage    = "http://github.com/i2w/timed_spam_rejection"
  s.summary     = "Reject form submissions based on the time taken to submit them"
  s.description = "Reject form submissions based on the time taken to submit them. Version #{TimedSpamRejection::VERSION}"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails"
  
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "simplecov"
end
