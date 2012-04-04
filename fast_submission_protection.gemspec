$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fast_submission_protection/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fast_submission_protection"
  s.version     = FastSubmissionProtection::VERSION
  s.authors     = ["Ian White", "Nicholas Rutherford"]
  s.email       = ["ian@i2wdev.com"]
  s.homepage    = "http://github.com/i2w/timed_spam_rejection"
  s.summary     = "Reject form submissions based on the time taken to submit them"
  s.description = "Reject form submissions based on the time taken to submit them. Version #{FastSubmissionProtection::VERSION}"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">=3"
  
  s.add_development_dependency "rspec-rails", ">=2"
  s.add_development_dependency "sqlite3"
end
