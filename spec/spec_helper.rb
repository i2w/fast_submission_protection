if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start do
    add_filter "_spec.rb"
  end
end

ENV['RAILS_ENV'] = 'test'

require 'rails/all'
require 'rspec'
require 'rspec/rails'
require_relative '../lib/fast_submission_protection'
