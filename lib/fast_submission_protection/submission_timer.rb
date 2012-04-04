module FastSubmissionProtection
  class SubmissionTooFastError < RuntimeError
    attr_reader :name, :delay
    def initialize name, delay
      @name, @delay = name, delay
    end
  end
  
  class SubmissionTimer
    class_attribute :delay, :clock
    self.delay = 5
    self.clock = Time
    
    def initialize storage, key, delay = nil, clock = nil
      @storage, @key = storage, key
      @delay = delay || self.class.delay
      @clock = clock || self.class.clock
    end
      
    def start
      @storage[@key] ||= @clock.now
    end
    
    def restart
      clear
      start
    end
    
    def clear
      @storage.delete @key
    end
    
    def finish
      started = @storage[@key]
      if (started && (started + @delay <= @clock.now))
        clear
      else
        restart
        raise SubmissionTooFastError.new(@key, @delay)
      end
    end
  end
end