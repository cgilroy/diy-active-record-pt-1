class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) { self.instance_variable_get("@#{name}") }
      define_method("#{name}=") { |set_val| self.instance_variable_set("@#{name}", set_val) }
    end
  end
end
