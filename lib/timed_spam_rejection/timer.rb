module TimedSpamRejection
  Delay = 5
  
  class TooFastError < RuntimeError; end
  
  class Timer
    class << self
      attr_writer :clock
      def clock
        @clock ||= Time
      end
    end
    
    attr_reader :started, :delay
    
    def initialize delay = nil, clock = nil
      @delay   = delay || Delay
      @clock   = clock || self.class.clock
      @started = @clock.now
    end
    
    def finish
      earliest_finish_time = started + delay.seconds
      @clock.now > earliest_finish_time or raise TooFastError
    end
    
    # wrapper for #finish which returns a boolean
    def too_fast?
      finish && false
    rescue TimedSpamRejection::TooFastError
      true
    end
  end
end