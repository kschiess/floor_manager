

class Spy
  attr_accessor :name, :opposite
  
  def self.build(attrs={})
    new.tap { |instance|
      attrs.each do |a,v|
        if respond_to?("#{a}=")
          instance.send("#{a}=", v)
        end
      end
    }
  end

  def initialize
    @saved = false
  end
  def save!; @saved = true; end
  def saved?; @saved; end
end