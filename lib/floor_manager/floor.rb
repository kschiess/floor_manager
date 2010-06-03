

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
    if args.size == 0 && employees.has_key?(sym)
      employees[sym].build(self)
    else
      super
    end
  end

  def create(something)
    employees[something.to_sym].create(self)
  end
  def build(something)
    employees[something.to_sym].build(self)
  end
end 