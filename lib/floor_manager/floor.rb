

# A single floor under the supervision of the manager. This is basically a 
# context in which unique/singleton instances and templates can coexist. 
#
class FloorManager::Floor
  class DSL
    def initialize(&block)
      @floor = FloorManager::Floor.new
      instance_eval(&block)
    end
    
    def one(name, opts={}, &block) 
      klass_name = opts[:class] || name
      @floor.employees[name.to_sym] = FloorManager::Employee::Unique.from_dsl(klass_name, &block)
    end
    
    def any(name, opts={}, &block)
      klass_name = opts[:class] || name
      @floor.employees[name.to_sym] = FloorManager::Employee::Template.from_dsl(klass_name, &block)
    end
    
    def object
      @floor
    end
  end
  def self.from_dsl(&block)
    DSL.new(&block).object
  end
  
  attr_reader :employees
  def initialize
    @employees = {}
  end
  
  def method_missing(sym, *args, &block)
    if args.size <= 1 && employees.has_key?(sym)
      attribute_overrides = {}
      attribute_overrides = args.first unless args.empty?
      employees[sym].build(self, attribute_overrides)
    else
      super
    end
  end

  def create(something, overrides={})
    employees[something.to_sym].create(self, overrides)
  end
  def build(something, overrides={})
    employees[something.to_sym].build(self, overrides)
  end

  def reset
    employees.values.each do |employee|
      employee.reset
    end
  end
end 