
require 'active_support'

class FloorManager::Employee
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