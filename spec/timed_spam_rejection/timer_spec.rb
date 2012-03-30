require 'spec_helper'

describe TimedSpamRejection::Timer do
  describe '.new <delay>, <now service>' do
    subject { timer }
    
    let(:timer)       { described_class.new delay, now_service }
    let(:delay)       { 20 }
    let(:now_service) { double now: started_at }
    let(:started_at)  { DateTime.parse('2012-01-01 12:00:00') }
    
    it { should be_a TimedSpamRejection::Timer }
    
    describe '#start' do
      subject { timer.start }
      
      it 'should start the timer' do
        subject
        timer.started.should == started_at
      end
    end
    
    context 'when not started' do
      its(:finish) { expect{ subject }.to raise_error TimedSpamRejection::NotStartedError }
      its(:too_fast?) { should == true }
    end
      
    context 'when started' do
      before do timer.start end
      
      context 'and not enough time passes' do
        before do now_service.stub(:now).and_return(started_at + delay) end

        its(:finish) { expect{ subject }.to raise_error(TimedSpamRejection::TooFastError) }
        its(:too_fast?) { should == true }
      end
      
      context 'and enough time passes' do
        before do now_service.stub(:now).and_return(started_at + delay + 1) end
          
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
    
    describe 'when <now service> nil (ie. the default now_service)' do
      let(:now_service) { nil }
      
      it 'uses DateTime as the now_service' do
        DateTime.should_receive(:now)
        subject.start
      end
    end
  end
end
