module TimedSpamRejection
  Delay = 5
  
  class Error < RuntimeError; end
  class NotStartedError < Error; end
  class TooFastError < Error; end
  
  class Timer
    attr_reader :started, :delay
    
    def initialize delay = nil, timer = nil
      @delay = delay || Delay
      @timer = timer || DateTime
    end
    
    def start
      @started = @timer.now
    end
    
    def finish
      if started
        earliest_finish_time = started + delay
        @timer.now > earliest_finish_time or raise TooFastError
      else
        raise NotStartedError
      end
    end
    
    def too_fast?
      finish && false
    rescue TimedSpamRejection::Error
      true
    end
  end
end