require 'rails/all'
require 'rspec/rails'
require 'spec_helper'

module TimedSpamRejection
  class Application < Rails::Application
  end
end

class ApplicationController < ActionController::Base
end

describe 'A controller with reject_fast_create' do
  
  controller do
    include Rails.application.routes.url_helpers
    
    reject_fast_create
  
    def new
      render :nothing => true
    end
  
    def create
      render :nothing => true
    end
  end

  context 'get :new' do
    before do end
    
    it 'should make a new timer' do
      get :new 
      flash[:timed_spam_rejection_timer].should be_a TimedSpamRejection::Timer
    end
    
    it 'should make a new timer each time' do
      get :new
      first_timer = flash[:timed_spam_rejection_timer]
      get :new
      flash[:timed_spam_rejection_timer].should_not == first_timer
    end
  end
end