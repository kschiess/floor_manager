
module FloorManager::Employee

  # Base class for employees. No instances of this should be created. 
  class Template
    def self.from_dsl(klass_name, namespace=nil, &block)
      new(klass_name, namespace).tap { |emp| DSL.new(emp, &block) }
    end

    def initialize(klass_name, namespace=nil)
      @klass_name = klass_name
      @namespace = namespace
      @attributes = Hash.new { |h,k| h[k] = Array.new }
    end
    
    # Build this employee in memory. 
    #
    def build(floor, overrides)
      produce_instance.tap { |i| 
        apply_attributes(i, :none, floor, overrides) }
    end
    
    # Create this employee in the database. 
    #
    def create(floor, overrides)
      produce_instance.tap { |i| 
        apply_attributes(i, :none, floor, overrides)
        
        i.save or fail "Could not create instance of #{@klass_name.inspect}."
        
        unless @attributes[:after_create].empty?
          apply_attributes(i, :after_create, floor) 
          i.save or fail "Could not save after_create."
        end
      }
    end
    
    # Returns just the attributes that would be used.
    #
    def attrs(floor, overrides)
      build(floor, overrides).attributes
    end
    
    # Reset this employee between test runs.
    #
    def reset
      # Empty, but subclasses will override this.
    end

    # Add an attribute to set. The action should implement the AttributeAction
    # interface. This method is mainly used by the DSL to store actions to
    # take.
    #
    def add_attribute filter, action
      @attributes[filter] << action
    end

    def produce_instance
      name = camelcase(@klass_name.to_s)
      (@namespace || Object).const_get(name).new
    end
    def camelcase(str)
      str.gsub(%r((^|_)\w)) { |match| match[-1].upcase }
    end
    
    # Modify attribute values in +instance+, setting them to what was
    # specified in the factory for this employee and then overriding them with
    # what was given in +overrides+.
    #
    def apply_attributes(instance, filter, floor, overrides={})
      # First apply all attributes that were given in the factory definition. 
      @attributes[filter].
        each do |action|
          action.apply(instance, floor, self)
        end

      # Then override with what the user just gave us.
      overrides.each do |name, value|
        AttributeAction::Immediate.new(name, value).apply(instance, floor, self)
      end
    end
  end
  
  # A unique employee that will be build/created only once in the given floor. 
  class Unique < Template
    def reset
      @instance = nil
    end

    # Override these to shortcut attribute setting when the instance exists 
    # already. 
    def build(floor, overrides)
      @instance || super
    end
    def create(floor, overrides)
      @instance || super
    end
    def attrs(floor, overrides)
      @instance && @instance.attributes || super
    end
  protected
    # Override to produce only one instance.
    def produce_instance
      @instance ||= super
    end
  end
end

require 'floor_manager/employee/dsl'
require 'floor_manager/employee/attribute_action'