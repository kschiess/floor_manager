

class Spy
  attr_accessor :name, :opposite, :int
  
  def self.build(attrs={})
    new.tap { |instance|
      attrs.each do |a,v|
        if instance.respond_to?("#{a}=")
          instance.send("#{a}=", v)
        end
      end
    }
  end

  def initialize
    @saved = false
  end
  def save; @saved = true; end
  def saved?; @saved; end
  
  class Builder < Array
    def build(attrs)
      self << Spy.build(attrs)
    end
  end
  
  def enemies
    @builder ||= Builder.new
  end
  
  def attributes
    {
      :name => name, 
      :opposite => opposite, 
      :enemies => enemies
    }
  end
end