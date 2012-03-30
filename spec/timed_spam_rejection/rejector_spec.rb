require 'spec_helper'

describe TimedSpamRejection::Rejector do
  describe '.new <delay>, <timer>' do
    subject { rejector }
    
    let(:rejector)    { described_class.new delay, timer }
    let(:delay)       { 20 }
    let(:timer)       { double now: started_at }
    let(:started_at)  { DateTime.parse('2012-01-01 12:00:00') }
    
    it { should be_a TimedSpamRejection::Rejector }
    
    describe '#start' do
      subject { rejector.start }
      
      it 'should start the rejector' do
        subject
        rejector.started.should == started_at
      end
    end
    
    describe '#finish' do
      subject { rejector.finish }
      
      context 'when not started' do
        it { expect{ subject }.to raise_error TimedSpamRejection::NotStartedError }
      end
      
      context 'when started' do
        before do rejector.start end
        
        context 'and not enough time passes' do
          before do timer.stub(:now).and_return(started_at + delay) end

          it { expect{ subject }.to raise_error(TimedSpamRejection::TooFastError) }
        end
        
        context 'and enough time passes' do
          before do timer.stub(:now).and_return(started_at + delay + 1) end
            
          it { expect{ subject }.to_not raise_error }
        end
      end
    end
  end
end
