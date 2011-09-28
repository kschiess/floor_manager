require 'blankslate'

module FloorManager::Employee
  class DSL < BlankSlate
    # A proxy that is the receiver of #set and #append in a construct like this: 
    #
    #   one :spy do
    #     relationship.set :gun
    #   end
    #
    class AssocProxy < ::Struct.new(:employee, :field, :dsl)
      def set(*create_args)
        dsl._add_attribute AttributeAction::AssocSet.new(field, create_args)
      end
      def append(*create_args)
        dsl._add_attribute AttributeAction::AssocAppend.new(field, create_args)
      end
      def string(chars=10)
        dsl._add_attribute AttributeAction::Block.new(field, proc {
          (0...chars).map{ ('a'..'z').to_a[rand(26)] }.join
        })
      end
      def integer(range)
        dsl._add_attribute AttributeAction::Block.new(field, proc {
          range.first + rand(range.last-range.first)
        })
      end
    end

    def initialize(employee, filter=:none, &block)
      @employee = employee
      @filter = filter
      
      instance_eval(&block)
    end
      
    # Register actions to be taken if the object gets saved (floor#create)
    #
    def after_create(&block)
      DSL.new(@employee, :after_create, &block)
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
        _add_attribute AttributeAction::Immediate.new(sym, value)
      elsif block
        # Lazy attribute
        _add_attribute AttributeAction::Block.new(sym, block)
      elsif args.empty?
        # Maybe: #set / #append proxy?
        AssocProxy.new(@employee, sym, self)
      else
        super
      end
    end

    def _add_attribute(action)
      @employee.add_attribute @filter, action
    end
  end
end