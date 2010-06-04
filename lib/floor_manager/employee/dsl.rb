module FloorManager::Employee
  class DSL < BlankSlate
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
      
    # This method missing handles several magic incantations: 
    #
    # a) Setting an attribute to a value that is given: 
    #   
    #     name 'john'
    #
    # b) Setting an attribute to a value that is returned from a block: 
    #
    #     name { |obj, floor| rand()>0.5 ? 'John' : 'Peter' }
    #
    #   Note that the first argument is the +obj+ under construction (your 
    #   model instance) and the second argument is the floor the model is 
    #   being constructed in. This is useful for retrieving other objects that
    #   live in the same floor. 
    #
    # c) Access to the association magic: 
    #
    #     spouse.set :linda
    #     friends.append :frank
    #
    #   Please see +AssocProxy+ for further explanation on this. 
    #
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
end