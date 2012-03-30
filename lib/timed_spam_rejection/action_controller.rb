module TimedSpamRejection
  module ActionController
    extend ActiveSupport::Concern
    
    module ClassMethods
      def reject_fast_create options = {}
        include TimerMethods unless self < TimerMethods
        before_filter TimedSpamRejection::ActionController::TimerFilter.new(options[:delay]), :only => :new
        before_filter TimedSpamRejection::ActionController::RejectorFilter.new(options[:message]), :only => :create
      end
    end
    
    module TimerMethods
      extend ActiveSupport::Concern
      
      included do
        hide_action *TimerMethods.instance_methods
      end
      
      def timed_spam_rejection_timer
        flash[:timed_spam_rejection_timer]
      end
      
      def timed_spam_rejection_timer=(timer)
        flash[:timed_spam_rejection_timer] = timer
      end
      
      def timed_spam_rejection_error=(error)
        flash[:error] = error
      end
    end
        
    class TimerFilter
      def initialize delay = nil
        @delay = delay
      end
      
      def filter controller
        controller.timed_spam_rejection_timer = Timer.new(@delay)
      end
    end
    
    class RejectorFilter
      def initialize message = nil
        @message = message || I18n.translate('timed_spam_rejection.error')
      end
      
      def filter controller
        timer = controller.timed_spam_rejection_timer
        if !timer || timer.too_fast?
          controller.timed_spam_rejection_error = @message
          controller.new
        end
      end
    end
  end
end