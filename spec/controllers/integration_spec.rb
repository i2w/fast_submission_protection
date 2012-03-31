require 'spec_helper'

module TimedSpamRejection
  class Application < Rails::Application
    config.i18n.default_locale = :en
  end
end

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
end

describe 'A controller with reject_fast_create' do
  controller do
    reject_fast_create
  
    def new
      in_new
      render :nothing => true
    end
  
    def create
      in_create
      render :nothing => true
    end
    
    def in_new; end
    def in_create; end
  end

  context 'get :new' do
    subject { get :new }
    
    it 'should make a new timer' do
      subject
      controller.timed_spam_rejection_timer.should be_a TimedSpamRejection::Timer
    end
    
    it 'should make a new timer each time' do
      subject
      first_timer = controller.timed_spam_rejection_timer
      get :new
      controller.timed_spam_rejection_timer.should_not == first_timer
    end
  end
  
  context 'post :create' do
    subject { post :create }
    
    shared_examples_for 'a spammy form posting' do
      it 'should call execute :new' do
        controller.should_receive(:in_new)
        subject
      end
      
      it 'should not execute :create' do
        controller.should_not_receive(:in_create)
        subject
      end
      
      it 'should have a timed spam message in the flash :alert' do
        subject
        flash[:alert].should =~ /This is an anti-spam measure/
      end
    end
    
    shared_examples_for 'a non spammy form posting' do
      it 'should execute :create' do
        controller.should_receive(:in_create)
        subject
      end

      it 'should not execute :new' do
        controller.should_not_receive(:in_new)
        subject
      end

      it 'should have no error message in the flash :alert' do
        subject
        flash[:alert].should == nil
      end
    end
    
    context 'when get :new is not the previous action' do
      it_should_behave_like 'a spammy form posting'
    end
    
    context 'after get :new' do
      let(:clock) { double }
      
      before do
        TimedSpamRejection::Timer.stub(:clock).and_return(clock)
        clock.stub(:now).and_return Time.now
        get :new
      end
        
      context 'when not enough time has passed' do
        before do
          now = clock.now + 4.seconds
          clock.stub(:now).and_return now
        end
        
        it_should_behave_like 'a spammy form posting'
        
        context 'and not enough time passes again' do
          before do
            post :create
            now = clock.now + 4.seconds
            clock.stub(:now).and_return now
          end
          
          it_should_behave_like 'a spammy form posting'
          
          context 'but then enough time passes' do
            before do
              post :create
              now = clock.now + 6.seconds
              clock.stub(:now).and_return now
            end
            
            it_should_behave_like 'a non spammy form posting'
          end
        end
      end
      
      context 'when enough time has passed' do
        before do
          now = clock.now + 6.seconds
          clock.stub(:now).and_return now
        end

        it_should_behave_like 'a non spammy form posting'
      end
    end 
  end
end