module TimedSpamRejection
  module ActionController
    extend ActiveSupport::Concern
    
    module ClassMethods
      def reject_fast_create options = {}
        include TimerMethods unless self < TimerMethods
        
        timer_creator = TimerCreator.new options[:delay]
        rejector      = Rejector.new timer_creator, options[:message]
        
        before_filter timer_creator, :only => :new
        before_filter rejector, :only => :create
      end
    end
    
    module TimerMethods
      extend ActiveSupport::Concern
      
      included do
        hide_action *TimerMethods.instance_methods
      end
      
      def timed_spam_rejection_timer
        timed_spam_rejection_storage[controller_name]
      end
      
      def timed_spam_rejection_timer=(timer)
        timed_spam_rejection_storage[controller_name] = timer
      end
      
      def timed_spam_rejection_error=(error)
        flash.now.alert = error
      end
      
    private
      def timed_spam_rejection_storage
        session[:timed_spam_rejection] ||= {}
      end
    end
        
    class TimerCreator
      def initialize delay = nil, timer_class = nil
        @delay, @timer_class = delay, timer_class || Timer
      end
      
      def create_timer_on controller
        controller.timed_spam_rejection_timer = @timer_class.new(@delay)
      end
      alias_method :filter, :create_timer_on
    end
    
    class Rejector
      def initialize timer_creator, message = nil
        @timer_creator = timer_creator
        @message = message || I18n.translate('timed_spam_rejection.error')
      end
      
      def reject_fast_create_on controller
        timer = controller.timed_spam_rejection_timer
        if !timer || timer.too_fast?
          @timer_creator.create_timer_on controller
          controller.timed_spam_rejection_error = @message
          controller.new
        else
          controller.timed_spam_rejection_timer = nil
        end
      end
      alias_method :filter, :reject_fast_create_on
    end
  end
end