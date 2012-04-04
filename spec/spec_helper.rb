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

class Rails::Application::Configuration
  def database_configuration
    {'test' => {'adapter' => 'sqlite3', 'database' => ":memory:"}}
  end
end

module FastSubmissionProtection
  class Application < Rails::Application
    config.active_support.deprecation = :stderr
  end
end

class ApplicationController < ActionController::Base
end

FastSubmissionProtection::Application.initialize!
