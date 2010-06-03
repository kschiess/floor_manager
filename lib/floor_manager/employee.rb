
class FloorManager::Employee
  class DSL
    def initialize(&block)
      instance_eval(&block)
    end
    def object
      FloorManager::Employee.new
    end
  end
  
  def self.from_dsl(&block)
    DSL.new(&block).object
  end
end