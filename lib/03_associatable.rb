require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    init_vals = {
      :class_name => name.to_s.camelcase,
      :primary_key => :id,
      :foreign_key => "#{name}_id".to_sym
    }

    init_vals.keys.each do |key|
      self.send("#{key}=",options[key] || init_vals[key])
    end
    
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    init_vals = {
      :class_name => name.to_s.singularize.camelcase,
      :primary_key => :id,
      :foreign_key => "#{self_class_name.underscore}_id".to_sym
    }

    init_vals.keys.each do |key|
      self.send("#{key}=",options[key] || init_vals[key])
    end    
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name,options)
    define_method(name) do
      options.model_class.where(options.primary_key => self.send(options.foreign_key)).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name,self.name,options)
    define_method(name) do
      options.model_class
        .where(options.foreign_key => self.send(options.primary_key))
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
