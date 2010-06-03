

class Spy < Struct.new(:name, :opposite)
  def self.build(attrs={})
    new.tap { |instance|
      attrs.each do |a,v|
        if respond_to?("#{a}=")
          instance.send("#{a}=", v)
        end
      end
    }
  end
end