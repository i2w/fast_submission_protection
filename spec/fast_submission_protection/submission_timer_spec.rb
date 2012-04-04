require 'spec_helper'

describe FastSubmissionProtection::SubmissionTimer do
  describe '.new <storage>, <key>, <delay>, <clock>' do
    subject { timer }
    
    let(:timer)   { FastSubmissionProtection::SubmissionTimer.new storage, key, delay, clock }
    let(:storage) { Hash.new }
    let(:key)     { 'the_key' }
    let(:delay)   { 10 }
    let(:clock)   { double :now => now }
    let(:now)     { Time.now }
    
    describe '#start' do
      subject { timer.start }
      
      it 'starts the timer (stores the clock\'s current time (#now) for the key)' do
        subject
        storage[key].should == now
      end
      
      context 'when the timer is started' do
        before { timer.start }
        
        it "doesn\'t do anything (it doesn't store a later time)" do
          earlier = now
          clock.stub(:now).and_return now + 1.hour
          subject
          storage[key].should == earlier
        end
      end
    end
    
    describe '#clear' do
      it 'clears the timer (clears any time stored for the key)' do
        timer.start
        timer.clear
        storage.should_not have_key(key)
      end
    end
    
    describe '#restart' do
      it 'clears and starts the timer (clears any storage and stores the clock\'s current time for the key)' do
        timer.start
        clock.stub(:now).and_return(later = now + 1.hour)
        timer.restart
        storage[key].should == later
      end
    end
    
    describe '#finish' do
      subject { timer.finish }
      
      context 'when the timer isn\'t started' do
        it { expect{ subject }.to raise_error(FastSubmissionProtection::SubmissionTooFastError) }
        
        it 'should start the timer' do
          subject rescue nil
          storage[key].should == now
        end
      end
      
      context 'when the timer is started' do
        before { timer.start }

        context 'and not enough time has passed' do
          before { clock.stub(:now).and_return now + delay - 1}

          it { expect{ subject }.to raise_error(FastSubmissionProtection::SubmissionTooFastError) }

          it 'should restart the timer' do
            subject rescue nil
            storage[key].should == now + delay - 1
          end
        end
        
        context 'and enough time has passed' do
          before { clock.stub(:now).and_return now + delay }
          
          it { expect{ subject }.to_not raise_error }
          
          it 'should clear the storage' do
            subject
            storage.should_not have_key(key)
          end
        end
      end
    end
    
    context 'when <delay> is nil (default)' do
      let(:delay) { nil }
      
      it 'uses the class self.delay' do
        FastSubmissionProtection::SubmissionTimer.should_receive(:delay)
        subject
      end
    end
    
    context 'when <clock> is nil (default)' do
      let(:clock) { nil }
      
      it 'uses the class self.clock' do
        FastSubmissionProtection::SubmissionTimer.should_receive(:clock)
        subject
      end
    end
  end
end
