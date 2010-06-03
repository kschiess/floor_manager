
class FloorManager
  class <<self
    attr_reader :floors
    
    # Defines a new environment under the supervision of the floor manager. 
    #
    def define(environment_name, &block)
      @floors ||= {}
      
      @floors[environment_name] = FloorManager::Floor.from_dsl(&block)
    end
    
    # Returns an instance of the environment.
    #
    def get(environment_name)
      floors[environment_name]
    end
  end
end

require 'floor_manager/floor'
require 'floor_manager/employee'