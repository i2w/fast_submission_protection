require 'spec_helper'

describe TimedSpamRejection::Timer do
  describe '.new <delay>, <clock>' do
    subject { timer }
    
    let(:timer)      { described_class.new delay, clock }
    let(:delay)      { 20 }
    let(:clock)      { double now: started_at }
    let(:started_at) { Time.now }
    
    it { should be_a TimedSpamRejection::Timer }
    
    it '#started should give the time it was created' do
      subject.started.should == started_at
    end
    
    describe 'after creation' do
      before do timer end
        
      context 'and not enough time passes' do
        before do clock.stub(:now).and_return(started_at + delay) end

        its(:finish) { expect{ subject }.to raise_error(TimedSpamRejection::TooFastError) }
        its(:too_fast?) { should == true }
      end
      
      context 'and enough time passes' do
        before do clock.stub(:now).and_return(started_at + delay + 1) end
        
        its(:finish) { expect{ subject }.to_not raise_error }
        its(:too_fast?) { should == false }
      end
    end
    
    describe 'when <delay> nil (ie. the default delay)' do
      let(:delay) { nil }
      
      it 'uses TimedSpamRejection::Delay as the delay' do
        subject.delay.should == TimedSpamRejection::Delay
      end
    end
    
    describe 'when <clock> nil (ie. the default clock)' do
      let(:clock) { nil }
      
      it 'uses Timer.clock as the clock' do
        TimedSpamRejection::Timer.clock.should_receive(:now)
        subject
      end
    end
  end
  
  it ".clock is read/writeable" do
    saved = described_class.clock
    described_class.clock = :clock
    described_class.clock.should == :clock
    described_class.clock = saved
    described_class.clock.should == saved
  end
end