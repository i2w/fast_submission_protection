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
      
      it 'should create a before_filter on :new with a new TimerCreator for the delay' do
        TimedSpamRejection::ActionController::TimerCreator.should_receive(:new).with(delay).and_return(filter = double)
        klass.should_receive(:before_filter).with(filter, :only => :new)
        subject
      end
      
      it 'should create a before_filter on :create with a new Rejector for the timer creator & message' do
        TimedSpamRejection::ActionController::TimerCreator.should_receive(:new).with(delay).and_return(timer_creator = double)
        TimedSpamRejection::ActionController::Rejector.should_receive(:new).with(timer_creator, message).and_return(rejector = double)
        klass.should_receive(:before_filter).with(rejector, :only => :create)
        subject
      end
      
      it 'should hide_action for all RejectFastCreateMethods, only once' do
        klass.should_receive(:hide_action).with(*TimedSpamRejection::ActionController::RejectFastCreateMethods.public_instance_methods).once
        subject
        klass.reject_fast_create
      end

      describe 'a controller instance' do
        subject { controller }

        let(:controller) { with_reject_fast_create.new.tap do |c|
                             c.stub(:session).and_return(session)
                             c.stub(:controller_name).and_return('the_controller_name')
                           end }
        let(:session) { Hash.new }
        
        it '#timed_spam_rejection_timer retrieves a timer from the session, using the controller_name' do
          session[:timed_spam_rejection] = {'the_controller_name' => (timer = double)}
          controller.timed_spam_rejection_timer.should == timer
        end
        
        it '#timed_spam_rejection_timer= sets the session using the controller_name' do
          controller.timed_spam_rejection_timer = (timer = double)
          session[:timed_spam_rejection]['the_controller_name'].should == timer
        end
        
        describe '#reject_fast_create <error>' do
          subject { controller.reject_fast_create message }
          
          let(:message) { 'Bad Shiz' }
          let(:flash)   { double(:now => double(:alert= => nil)) }
          
          before do 
            controller.stub(:performed?)
            controller.stub(:new)
            controller.stub(:render)
            controller.stub(:flash).and_return(flash)
          end
            
          it 'sets flash.alert.now to the error' do
            flash.now.should_receive(:alert=).with(message)
            subject
          end
          
          it 'calls the #new method' do
            controller.should_receive(:new)
            subject
          end
          
          it 'renders :new' do
            controller.should_receive(:render).with(:new)
            subject
          end
          
          context 'when #new performs a render or redirect' do
            before do controller.stub(:performed?).and_return(true) end
            
            it 'does not render :new' do
              controller.should_not_receive(:render)
              subject
            end
          end
        end
      end
    end
  end
  
  describe 'TimerCreator' do
    describe ".new <delay>" do
      subject { filter }
      
      let(:filter)  { TimedSpamRejection::ActionController::TimerCreator.new delay }
      let(:delay)   { double }
      
      describe '#filter(controller)' do
        subject { filter.filter controller }
        
        let(:controller) { double :timed_spam_rejection_timer= => nil }
        let(:timer)      { double }

        before do TimedSpamRejection::Timer.stub(:new).and_return timer end
          
        it 'should create a Timer using the <delay>' do
          TimedSpamRejection::Timer.should_receive(:new).with(delay)
          subject
        end
        
        it 'should store the timer as the controller\'s #timed_spam_rejection_timer' do
          controller.should_receive(:timed_spam_rejection_timer=).with(timer)
          subject
        end
      end
    end
  end
  
  describe 'Rejector' do
    describe '.new <message>' do
      subject { filter }
      
      let(:filter)        { TimedSpamRejection::ActionController::Rejector.new timer_creator, message }
      let(:timer_creator) { double(:create_timer_on => nil) }
      let(:message)       { 'Too FAST!' }
      
      describe '#filter <controller>' do
        subject { filter.filter controller }
        
        let(:controller) { double timed_spam_rejection_timer: nil, :timed_spam_rejection_timer= => nil, :reject_fast_create => nil }
        
        shared_examples_for 'a spammy submission' do
          it 'should ask the timer creator to create a new timer on the controller' do
            timer_creator.should_receive(:create_timer_on).with(controller)
            subject
          end
          
          it 'should call #reject_fast_create co the controller, with its error message' do
            controller.should_receive(:reject_fast_create).with(message)
            subject
          end
        end
        
        context 'when no timer is set' do
          it_should_behave_like 'a spammy submission'
        end
        
        context 'when a timer is set' do
          let(:timer) { double reset: nil }
          
          before do controller.stub(:timed_spam_rejection_timer).and_return(timer) end
            
          context 'and the timer says too_fast' do
            before do timer.stub(:too_fast?).and_return(true) end
              
            it_should_behave_like 'a spammy submission'
          end
          
          context 'and the timer says not too_fast' do
            before do timer.stub(:too_fast?).and_return(false) end
            
            it 'the controller should not reject_fast_create' do
              controller.should_not_receive(:reject_fast_create)
              subject
            end
            
            it 'the controller\'s timer should be cleared' do
              controller.should_receive(:timed_spam_rejection_timer=).with(nil)
              subject
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
end