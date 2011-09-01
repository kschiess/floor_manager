module FloorManager::Employee
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
      def apply(obj, floor, employee)
        instance = floor.build(*@create_args)
        get(obj) << instance
      end
    end
    
    # Stores the action of producing another employee via the floor and then
    # storing that as a value. 
    class AssocSet < Base
      def initialize(field, create_args)
        super field
        @create_args = create_args
      end
      def apply(obj, floor, employee)
        assoc_obj = floor.build(*@create_args)
        set(obj, assoc_obj)
      end
    end
    
    # Stores the action of setting an attribute to an immediate value.
    class Immediate < Base
      def initialize(name, value)
        super(name)
        @value = value
      end
      def apply(obj, floor, employee)
        set(obj, @value)
      end
    end
    
    # Stores the action of setting an attribute to the result of a block.
    class Block < Base
      def initialize(name, block)
        super(name)
        @block = block
      end
      def apply(obj, floor, employee)
        set(obj, @block.call(obj, floor))
      end
    end
  end
end