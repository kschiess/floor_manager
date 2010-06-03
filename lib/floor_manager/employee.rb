
require 'active_support'

module FloorManager::Employee
  class DSL
    def initialize(employee, &block)
      @employee = employee
      
      instance_eval(&block)
    end
    
    def method_missing(sym, *args, &block)
      if args.size == 1
        # Immediate attribute
        value = args.first
        @employee.add_attribute sym, Proc.new { value }
      elsif block
        # Lazy attribute
        @employee.add_attribute sym, block
      else
        super
      end
    end
  end
  
  class Base
    def self.from_dsl(klass_name, &block)
      new(klass_name).tap { |emp| DSL.new(emp, &block) }
    end

    def initialize(klass_name)
      @klass_name = klass_name
      @attributes = []
    end
    
    def add_attribute(name, callable)
      @attributes << [name, callable]
    end

    def build(floor, overrides)
      produce_instance.tap { |i| apply_attributes(i, overrides, floor) }
    end
    
    def create(floor, overrides)
      produce_instance.tap { |i| 
        apply_attributes(i, overrides, floor)
        i.save! }
    end
    
    def reset
    end
  protected
    def produce_instance
      @klass_name.to_s.
        camelcase.
        constantize.
        new
    end
    
    def apply_attributes(instance, overrides, floor)
      (@attributes + overrides.to_a).each do |name, value_producer|
        if value_producer.respond_to? :call
          instance.send("#{name}=", value_producer.call(instance, floor))
        else
          instance.send("#{name}=", value_producer)
        end
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
  end
end