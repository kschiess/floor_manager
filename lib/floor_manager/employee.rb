
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
      elsif block
        # Lazy attribute
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
    end

    def build
      @klass_name.to_s.
        camelcase.
        constantize.
        build()
    end
  end
  
  # A unique employee that will be build/created only once in the given floor. 
  class Unique < Base
    def build
      @instance ||= super
    end
  end
  
  # A template for employees, you can call build/create many times.
  class Template < Base
  end
end