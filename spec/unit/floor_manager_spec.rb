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
    
    context "white spy" do
      subject { env.white }
      
      its(:name) { should == 'white spy'}
      its(:opposite) { should == env.black }
    end
    context "black spy" do
      subject { env.black }

      its(:name) { should == 'black spy'}
      its(:opposite) { should == env.white }
    end
    
    describe "<- #create(:white)" do
      let(:white) { env.create(:white) }
      
      it "should return a saved object" do
        white.should be_saved
      end 
    end
    describe "<- #build(:white)" do
      let(:white) { env.build(:white) }
      
      it "should not return a saved object" do
        white.should_not be_saved
      end 
      it "should return the same object through method missing" do
        white.should == env.white
      end 
      context "when accessing the same object with #create" do
        let(:created) { env.create(:white) }
        subject { created }
        it "should return the same object still" do
          white.should == created
        end 
        it { should be_saved } 
      end
      context "after a reset" do
        before(:each) { 
          @old_white = white
          FloorManager.reset }
        
        it "should produce a new white spy (forget about white)" do
          @old_white.should_not == env.white
        end 
      end
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
    
    context "spy" do
      subject { env.spy }
      
      its(:name) { should == 'white spy'}
    end
  end
  context "environment with any/overrides" do
    let(:env) {
      FloorManager.define :any do |m|
        any :spy do
          name      'white spy'
        end
      end
      
      FloorManager.get(:any)
    }
    
    let(:blue_spy) { env.spy(:name => 'blue') }
    subject { blue_spy }
    
    its(:name) { should == 'blue' } 
  end
  context "environment with association" do
    let(:env) {
      FloorManager.define :any do |m|
        one :green, :class => Spy do
          name 'green'
        end
        one :white, :class => Spy do
          name 'white'
        end
        one :black, :class => Spy do
          name 'black'
        end
        any :spy do
          # A shortcut for association sets 
          # (like { |inst, floor| floor.create(...) })
          opposite.set :green

          # has and belongs to many (uses association.create)
          enemies.append :black
          enemies.append :white
        end
      end
      
      FloorManager.get(:any)
    }

    context "produced spy (from any rule)" do
      let(:any_spy) { env.spy }
      subject { any_spy }

      its(:enemies) { should have(2).entries }
      it "should have green in #opposite" do
        any_spy.opposite.should == env.green
      end 
    end
  end
end