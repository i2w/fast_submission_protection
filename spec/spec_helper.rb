if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start do
    add_filter "_spec.rb"
  end
end

require 'rails/all'
require 'rspec/rails'
require 'fast_submission_protection'