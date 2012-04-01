module TimedSpamRejection
  module ActionController
    extend ActiveSupport::Concern
    
    module ClassMethods
      def reject_fast_create options = {}
        include RejectFastCreateMethods unless self < RejectFastCreateMethods
        
        timer_creator = TimerCreator.new options[:delay]
        rejector      = Rejector.new timer_creator, options[:message]
        
        before_filter timer_creator, :only => :new
        before_filter rejector, :only => :create
      end
    end
    
    module RejectFastCreateMethods
      extend ActiveSupport::Concern
      
      included do
        hide_action *RejectFastCreateMethods.public_instance_methods
      end
      
      # this method is responsible only for telling the user that
      # their submission is rejected because it was too fast.
      # Override this in your controller to customise the behaviour
      def reject_fast_create message = nil
        flash.now.alert = message
        new
        render :new unless performed?
      end

      def timed_spam_rejection_timer
        timed_spam_rejection_storage[controller_name]
      end
      
      def timed_spam_rejection_timer= timer
        timed_spam_rejection_storage[controller_name] = timer
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
        @timer_creator, @message = timer_creator, message || I18n.translate('timed_spam_rejection.error')
      end
      
      def reject_fast_create_on controller
        timer = controller.timed_spam_rejection_timer
        if !timer || timer.too_fast?
          @timer_creator.create_timer_on controller
          controller.reject_fast_create @message
        else
          controller.timed_spam_rejection_timer = nil
        end
      end
      alias_method :filter, :reject_fast_create_on
    end
  end
end