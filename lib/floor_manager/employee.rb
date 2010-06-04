
require 'active_support'
require 'blankslate'

module FloorManager::Employee

  # Base class for employees. No instances of this should be created. 
  class Base
    def self.from_dsl(klass_name, &block)
      new(klass_name).tap { |emp| DSL.new(emp, &block) }
    end

    def initialize(klass_name)
      @klass_name = klass_name
      @attributes = []
    end
    
    # Build this employee in memory. 
    #
    def build(floor, overrides)
      produce_instance.tap { |i| apply_attributes(i, overrides, floor) }
    end
    
    # Create this employee in the database. 
    #
    def create(floor, overrides)
      produce_instance.tap { |i| 
        apply_attributes(i, overrides, floor)
        i.save! }
    end
    
    # Returns just the attributes that would be used.
    #
    def attrs(floor, overrides)
      {}.tap { |h| 
        apply_attributes(h, overrides, floor) }
    end
    
    # Reset this employee between test runs.
    #
    def reset
      # Empty, but subclasses will override this.
    end

    def add_attribute action
      @attributes << action
    end
  protected
    def produce_instance
      @klass_name.to_s.
        camelcase.
        constantize.
        new
    end
    
    def apply_attributes(instance, overrides, floor)
      @attributes.each do |action|
        action.apply(instance, floor)
      end

      overrides.each do |name, value|
        AttributeAction::Immediate.new(name, value).apply(instance, floor)
      end
    end
  end
  
  # A unique employee that will be build/created only once in the given floor. 
  class Unique < Base
    # REFACTOR: Redundancy
    def build(floor, overrides)
      return @instance if @instance
      @instance = produce_instance
      apply_attributes(@instance, overrides, floor)
      
      @instance
    end
    
    # REFACTOR: Redundancy
    def create(floor, overrides)
      return @instance if @instance
      @instance = produce_instance
      apply_attributes(@instance, overrides, floor)
      @instance.save!
      
      @instance
    end

    def reset
      @instance = nil
    end
  end
  
  # A template for employees, you can call build/create many times.
  class Template < Base
    # Currently empty, see base class
  end
end

require 'floor_manager/employee/dsl'
require 'floor_manager/employee/attribute_action'