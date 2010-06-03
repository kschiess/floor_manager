require 'spec_helper'

describe FloorManager do  
  context "environment with singleton definition" do
    let(:env) { 
      FloorManager.define :one do |m|
        one :white, :class => "Spy" do
          name      'white spy'
          opposite  { |spy, env| env.black }
        end
        one :black, :class => "Spy" do
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
  
  context "environment with template definition" do
    let(:env) {
      FloorManager.define :any do |m|
        any :spy do
          name      'white spy'
        end
      end
      
      FloorManager.get(:any)
    }
    
    it "should return a new instance each time called" do
      env.spy.should_not == env.spy
    end 
  end
  
end