module FastSubmissionProtection
  module Controller
    extend ActiveSupport::Concern
    
    module ClassMethods
      # protects a create action from fast_submission
      #
      # This checks the time taken between the form being rendered (by new, or failed create), and
      # the form being posted to the create action.  If it is less than the specified time, an
      # error is raised, which is rescued with a basic 420 error page (enhance your calm) which 
      # invites the user to click their back button, wait 5 seconds, and try again.
      #
      # Options:
      #   * :name:    The name of the submission (default "#{controller_name}_create")
      #   * :delay:   The time to wait (default 5 seconds)
      #   * :start:   List of actions when the timer should be started (default [:new, :create])
      #   * :finish:  List of actions when the timer should be finished (default [:create])
      #   * :rescue:  Rescue SubmissionTooFast error with a 420.html error page (default true)
      # 
      # If your submission starts in one controller and finishes in another, you can start the 
      # timer wherever you like, as follows
      #
      #   # At the class level, ie specifying a filter where the submission ends
      #   before_filter FastSubmissionProtection::FinishFilter.new('abused_form_post'), :only => [:create]
      #   # and where the submission starts
      #   before_filter FastSubmissionProtection::StartFilter.new('abused_form_post'), :only => [:new]
      #   
      #   # At the instance level, wherever you want, perhaps in an action
      #   submission_timer('often_abused_form_post').start # to start
      #   
      #   # later, somewhere else
      #   submission_timer('often_abused_form_post').finish # to finsih, raises SubmissionTooFastError if too fast
      def protect_from_fast_submission options = {}
        delay  = options[:delay]
        start  = options[:start] || [:new, :create]
        finish = options[:finish] || [:create]
        name   = options[:name] || "#{controller_name}_#{Array(finish).join('_')}"

        include Rescue unless options[:rescue] == false || self < Rescue

        before_filter FinishFilter.new(name, delay), :only => finish
        before_filter StartFilter.new(name), :only => start
      end
    end
    
    included do
      hide_action :submission_timer, :protect_from_fast_submission?

      # Controls whether fast submission protection is turned on or not. Turned off by default only in test mode.
      config_accessor :allow_fast_submission_protection
      if allow_fast_submission_protection.nil?
        self.allow_fast_submission_protection = (Rails.env != 'test')
      end
    end
    
    def submission_timer name, delay = nil
      SubmissionTimer.new timed_submission_storage, name, delay
    end

    def protect_from_fast_submission?
      allow_fast_submission_protection && (request.post? || request.put?)
    end
    
  protected
    def timed_submission_storage
      session[:_fsp] ||= {}
    end
  end
  
  class StartFilter < Struct.new(:name)
    def filter controller
      controller.submission_timer(name).start
    end
  end
  
  class FinishFilter < Struct.new(:name, :delay)
    def filter controller
      if controller.protect_from_fast_submission?
        controller.submission_timer(name, delay).finish
      end
    end
  end

  module Rescue
    extend ActiveSupport::Concern

    included do
      rescue_from FastSubmissionProtection::SubmissionTooFastError, :with => :render_fast_submission_protection_error
    end

  protected
    def render_fast_submission_protection_error exception
      render :template => 'fast_submission_protection/error', :locals => {:exception => exception}, :layout => false, :status => 420
    end
  end
end