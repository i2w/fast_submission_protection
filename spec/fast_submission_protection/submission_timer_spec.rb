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
      
      it 'stores the clock\'s current time (#now) for the key' do
        subject
        storage[key].should == now
      end
      
      context 'when already started' do
        before { timer.start }
        
        it "it doesn't store a later time" do
          earlier = now
          clock.stub(:now).and_return now + 1.hour
          subject
          storage[key].should == earlier
        end
      end
    end
    
    it '#clear clears any time stored for the key' do
      timer.start
      timer.clear
      storage.should_not have_key(key)
    end
    
    it '#restart clears any storage and stores the clock\'s current time for the key' do
      timer.start
      clock.stub(:now).and_return(later = now + 1.hour)
      timer.restart
      storage[key].should == later
    end
    
    describe '#too_fast?' do
      subject { timer.too_fast? }
      
      context 'when the timer isn\'t started' do
        it { should == true }
      end
      
      context 'when the timer is started' do
        before { timer.start }
        
        context 'and enough time has passed' do
          before { clock.stub(:now).and_return now + delay }
          
          it { should == false }
        end
        
        context 'and not enough time has passed' do
          before { clock.stub(:now).and_return now + delay - 1}
          
          it { should == true }
        end
      end
    end
  end
end
