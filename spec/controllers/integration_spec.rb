require 'spec_helper'

describe 'A controller with protect_from_fast_submission' do
  controller do
    self.allow_fast_submission_protection = true # test mode turns this off be default
    
    protect_from_fast_submission :name => 'a_submission'
    
    def new
      render_new
    end
  
    def create
      if params[:create_failed]
        render_new
      else
        created
        render_create
      end
    end
    
    def index
      render :nothing => true
    end
    
    def render_new
      render :nothing => true
    end
    
    def render_create
      render :nothing => true
    end
    
    def created
    end
  end
  
  context 'post :create' do
    subject { do_post }
    
    def do_post *args
      post :create, *args
    end
    
    # The only thing we're stubbing in this integration spec is the time
    let(:clock) { double :now => Time.now }
    before do FastSubmissionProtection::SubmissionTimer.clock = clock end
    
    def seconds_pass amount
      now = clock.now + amount.seconds
      clock.stub(:now).and_return now
    end
    
    shared_examples_for 'a spammy form posting' do
      it 'should render the fast_submission_protection error page' do
        subject
        controller.should render_template('fast_submission_protection/error')
      end
      
      it 'should not have created' do
        controller.should_not_receive :created
        subject
      end
    end
    
    shared_examples_for 'a non spammy form posting' do
      it 'should have created successfully' do
        controller.should_receive :created
        subject
      end
    end
    
    context 'when get :new is not the previous action' do
      it_should_behave_like 'a spammy form posting'
    end
    
    context 'after get :new' do
      before do
        get :new
      end
      
      context 'when enough time has passed' do
        before do seconds_pass(6) end

        it_should_behave_like 'a non spammy form posting'
        
        context 'but the create fails for another reason, and new is rendered' do
          before do
            do_post :create_failed => true
          end
            
          context 'and enough time passes' do
            before do seconds_pass(6) end
            
            it_should_behave_like 'a non spammy form posting'  
          end
        end
      end
      
      context 'and another action is requested in the meantime' do
        before do
          get :index
        end

        context 'and enough time has passed' do
          before do seconds_pass(6) end

          it_should_behave_like 'a non spammy form posting'
        end
      end
      
      context 'when not enough time has passed' do
        before do seconds_pass(4) end
        
        it_should_behave_like 'a spammy form posting'
        
        context 'and not enough time passes again' do
          before do
            do_post rescue FastSubmissionProtection::SubmissionTooFastError
            seconds_pass(4)
          end
          
          it_should_behave_like 'a spammy form posting'
          
          context 'but then enough time passes' do
            before do
              do_post rescue FastSubmissionProtection::SubmissionTooFastError
              seconds_pass(6)
            end
            
            it_should_behave_like 'a non spammy form posting'
            
            context 'but then I post again immediately' do
              before do
                do_post rescue FastSubmissionProtection::SubmissionTooFastError
                seconds_pass(1)
              end
              
              it_should_behave_like 'a spammy form posting'
            end
          end
        end
      end
    end 
  end
end