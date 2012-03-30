module TimedSpamRejection
  Delay = 5
  
  class Error < RuntimeError; end
  class NotStartedError < Error; end
  class TooFastError < Error; end
  
  class Rejector
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
  end
end