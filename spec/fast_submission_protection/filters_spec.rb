require 'spec_helper'

describe FastSubmissionProtection::StartFilter do
  describe '.new <submission_name>' do
    subject { described_class.new('name') }
    
    it "is equal to another StartFilter with the same name (for filter chain manipulation purposes)" do
      subject.should_not == described_class.new('foo')
      subject.should == described_class.new('name')
    end
    
    it '#filter <controller> starts a submission_timer for <name>' do
      controller, timer = double, double

      controller.should_receive(:submission_timer).with('name').and_return(timer)
      timer.should_receive(:start)
      subject.filter controller
    end
  end
end

describe FastSubmissionProtection::FinishFilter do
  describe '.new <submission_name>, <delay>' do
    subject { filter }
    
    let(:filter) { described_class.new('name', 20) }
    
    it "is equal to another FinishFilter with the same name and delay (for filter chain manipulation purposes)" do
      subject.should_not == described_class.new('foo', 20)
      subject.should_not == described_class.new('name', 15)
      subject.should == described_class.new('name', 20)
    end
    
    describe '#filter <controller>' do
      subject { filter.filter controller }
      
      context 'when controller doesn\'t protect_from_fast_submission' do
        let(:controller) { double :protect_from_fast_submission? => false }
        
        it 'doesn\'t do anything' do
          subject
        end
      end
      
      context 'when controller protect_from_fast_submission?' do
        let(:controller) { double :protect_from_fast_submission? => true }
        
        it 'finishes a submission_timer for <name>, <delay>' do
          controller.should_receive(:submission_timer).with('name', 20).and_return(timer = double)
          timer.should_receive(:finish)
          subject
        end
      end
    end
  end
end