
require 'active_support'

module FloorManager::Employee
  class DSL
    # A proxy that is the receiver of #set and #append in a construct like this: 
    #
    #   one :spy do
    #     relationship.set :gun
    #   end
    #
    class AssocProxy < Struct.new(:employee, :field)
      def set(*create_args)
        employee.add_attribute AttributeAction::AssocSet.new(field, create_args)
      end
      def append(*create_args)
        employee.add_attribute AttributeAction::AssocAppend.new(field, create_args)
      end
    end

    def initialize(employee, &block)
      @employee = employee
      
      instance_eval(&block)
    end
      
    def method_missing(sym, *args, &block)
      if args.size == 1
        # Immediate attribute
        value = args.first
        @employee.add_attribute AttributeAction::Immediate.new(sym, value)
      elsif block
        # Lazy attribute
        @employee.add_attribute AttributeAction::Block.new(sym, block)
      elsif args.empty?
        # Maybe: #set / #append proxy?
        AssocProxy.new(@employee, sym)
      else
        super
      end
    end
  end

  module AttributeAction
    # Base class for stored actions.
    class Base
      def initialize(name)
        @name = name
      end
      def set(obj, value)
        if obj.kind_of?(Hash)
          obj[@name] = value
        else
          obj.send("#{@name}=", value)
        end
      end
      def get(obj)
        if obj.kind_of?(Hash)
          obj[@name]
        else
          obj.send(@name)
        end
      end
    end
    
    # Stores the action of producing another employee via a collection proxy
    # stored in field.
    class AssocAppend < Base
      def initialize(field, create_args)
        super field
        @create_args = create_args
      end
      def apply(obj, floor)
        attributes = floor.attrs(*@create_args)
        get(obj).build(attributes)
      end
    end
    
    # Stores the action of producing another employee via the floor and then
    # storing that as a value. 
    class AssocSet < Base
      def initialize(field, create_args)
        super field
        @create_args = create_args
      end
      def apply(obj, floor)
        set(obj, floor.create(*@create_args))
      end
    end
    
    # Stores the action of setting an attribute to an immediate value.
    class Immediate < Base
      def initialize(name, value)
        super(name)
        @value = value
      end
      def apply(obj, floor)
        set(obj, @value)
      end
    end
    
    # Stores the action of setting an attribute to the result of a block.
    class Block < Base
      def initialize(name, block)
        super(name)
        @block = block
      end
      def apply(obj, floor)
        set(obj, @block.call(obj, floor))
      end
    end
  end
  
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