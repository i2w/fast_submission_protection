module FastSubmissionProtection
  class SubmissionTimer
    class_attribute :delay, :clock
    self.delay = 5
    self.clock = Time
    
    def initialize storage, key, delay = nil, clock = nil
      @storage, @key = storage, key
      @delay = delay || self.class.delay
      @clock = clock || self.class.clock
    end
    
    def too_fast?
      started = @storage[@key]
      !started || (started + @delay > @clock.now)
    end
      
    def start
      @storage[@key] ||= @clock.now
    end
    
    def restart
      @storage[@key] = @clock.now
    end
    
    def clear
      @storage.delete @key
    end
  end
end