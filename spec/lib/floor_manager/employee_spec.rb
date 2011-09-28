require 'spec_helper'

describe FloorManager::Employee::Template do
  class FooBar; end
  describe '#produce_instance' do
    it "camelcases correctly" do
      described_class.new(:foo_bar).produce_instance.
        should be_instance_of(FooBar)
    end 
  end
end