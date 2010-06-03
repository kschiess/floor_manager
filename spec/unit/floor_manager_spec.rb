require 'spec_helper'

describe FloorManager do
  def self.define_object(klass_name, *attributes)
    Struct.new(klass_name, *attributes)
  end
  define_object('Spy', :name, :opposite)
  
  context "environment with singleton definition" do
    let(:env) { 
      FloorManager.define :one do |m|
        one :white, :class => :spy do
          name      'white spy'
          opposite  { |spy, env| env.black }
        end
        one :black, :class => :spy do
          name      'black spy'
          opposite  { |spy, env| env.white }
        end
      end

      FloorManager.get(:one)
    }
    
    it "should build the same object twice" do
      env.white.should == env.white
    end 
  end
  
end