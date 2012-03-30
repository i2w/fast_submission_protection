require 'spec_helper'

describe TimedSpamRejection::ActionController do
  describe 'included into a controller class' do
    subject { klass }
    
    let(:klass) { Class.new.tap do |c| 
                    c.stub(:before_filter)
                    c.stub(:hide_action)
                    c.send :include, TimedSpamRejection::ActionController
                  end }
    
    describe 'with#reject_fast_create delay: <delay>, message: <message>' do
      subject { with_reject_fast_create }
      
      let(:with_reject_fast_create) { klass.tap do |c| c.reject_fast_create delay: delay, message: message end }
      let(:delay)                   { 20 }
      let(:message)                 { 'Oh yeah!' }
      
      it 'should create a before_filter on :new with a new TimerFilter for the delay' do
        TimedSpamRejection::ActionController::TimerFilter.should_receive(:new).with(delay).and_return(filter = double)
        klass.should_receive(:before_filter).with(filter, :only => :new)
        subject
      end
      
      it 'should create a before_filter on :create with a new RejectorFilter for the message' do
        TimedSpamRejection::ActionController::RejectorFilter.should_receive(:new).with(message).and_return(filter = double)
        klass.should_receive(:before_filter).with(filter, :only => :create)
        subject
      end
      
      it 'should hide_action for all TimerMethods, only once' do
        klass.should_receive(:hide_action).with(*TimedSpamRejection::ActionController::TimerMethods.instance_methods).once
        subject
        klass.reject_fast_create
      end

      describe 'a controller instance' do
        subject { controller }

        let(:controller) { with_reject_fast_create.new.tap do |c| c.stub(:flash).and_return(flash) end }
        let(:flash)      { Hash.new }

        it '#timed_spam_rejection_timer looks in the controller\'s flash[:timed_spam_rejection_timer]' do
          flash.should_receive(:[]).with(:timed_spam_rejection_timer).and_return(timer = double)
          controller.timed_spam_rejection_timer.should == timer
        end
        
        it '#timed_spam_rejection_timer= sets the controller\'s flash[:timed_spam_rejection_timer]' do
          controller.timed_spam_rejection_timer = (timer = double)
          flash[:timed_spam_rejection_timer].should == timer
        end
        
        it '#timed_spam_rejection_error= sets the controller\'s flash[:error]' do
          controller.timed_spam_rejection_error = 'Bad shiz'
          flash[:error].should == "Bad shiz"
        end
      end
    end
  end
  
  describe 'TimerFilter' do
    describe ".new <delay>" do
      subject { filter }
      
      let(:filter)  { TimedSpamRejection::ActionController::TimerFilter.new delay }
      let(:delay)   { double }
      
      it { should be_a TimedSpamRejection::ActionController::TimerFilter }
      
      describe '#filter(controller)' do
        subject { filter.filter controller }
        
        let(:controller) { double :timed_spam_rejection_timer= => nil }
        let(:timer)      { double }

        before do TimedSpamRejection::Timer.stub(:new).and_return timer end
          
        it 'should create a Timer using the <delay>' do
          TimedSpamRejection::Timer.should_receive(:new).with(delay)
          subject
        end
        
        it 'should store the timer as the controller\'s #timed_span_rejection_timer' do
          controller.should_receive(:timed_spam_rejection_timer=).with(timer)
          subject
        end
      end
    end
  end
  
  describe 'RejectorFilter' do
    describe '.new <message>' do
      subject { filter }
      
      let(:filter)  { TimedSpamRejection::ActionController::RejectorFilter.new message }
      let(:message) { 'Too FAST!' }
      
      describe '#filter <controller>' do
        subject { filter.filter controller }
        
        let(:controller) { double timed_spam_rejection_timer: nil, :timed_spam_rejection_error= => nil, new: nil }
        
        shared_examples_for 'a spammy submission' do
          it 'should call #new on controller' do
            controller.should_receive(:new)
            subject
          end
          
          it 'should add a timed_spam_rejection_error on the controller' do
            controller.should_receive(:timed_spam_rejection_error=).with(message)
            subject
          end
        end
        
        context 'when no timer is set' do
          it_should_behave_like 'a spammy submission'
        end
        
        context 'when a timer is set' do
          let(:timer) { double }
          
          before do controller.stub(:timed_spam_rejection_timer).and_return(timer) end
            
          context 'and the timer says too_fast' do
            before do timer.stub(:too_fast?).and_return(true) end
              
            it_should_behave_like 'a spammy submission'
          end
          
          context 'and the timer says not too_fast' do
            before do timer.stub(:too_fast?).and_return(false) end
            
            it 'the controller should not contain an timed_spam_rejection_error' do
              controller.should_not_receive(:timed_spam_rejection_error)
              subject
            end
            
            it 'the controller should not have #new called on it' do
              controller.should_not_receive :new
              subject
            end
          end
        end
      end
      
      context 'when <message> is nil (the default)' do
        let(:message) { nil }
        
        it 'should use the I18n translation for "timed_spam_rejection.error"' do
          I18n.should_receive(:translate).with('timed_spam_rejection.error')
          subject
        end
      end
    end
  end
end