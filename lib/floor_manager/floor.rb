

# A single floor under the supervision of the manager. This is basically a 
# context in which unique/singleton instances and templates can coexist. 
#
class FloorManager::Floor
  class DSL
    def initialize(&block)
      instance_eval(&block)
    end
    
    def one(name, opts={}, &block) 
      
    end
    
    def object
      FloorManager::Floor.new
    end
  end
  
  def self.from_dsl(&block)
    DSL.new(&block).object
  end
end 