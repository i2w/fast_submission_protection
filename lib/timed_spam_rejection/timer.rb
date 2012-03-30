module TimedSpamRejection
  Delay = 5
  
  class Error < RuntimeError; end
  class TooFastError < Error; end
  
  class Timer
    attr_reader :started, :delay
    
    def initialize delay = nil, timer = nil
      @delay = delay || Delay
      @timer = timer || DateTime
      start
    end
    
    def finish
      earliest_finish_time = started + delay
      @timer.now > earliest_finish_time or raise TooFastError
    end
    
    # wrapper for #finish which returns a boolean
    def too_fast?
      finish && false
    rescue TimedSpamRejection::Error
      true
    end
    
  private
    def start
      @started = @timer.now
    end
  end
end