require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if !@columns.nil?
    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    col_names = data[0].map!(&:to_sym)
    @columns = col_names
  end

  def self.finalize!
    self.columns.each do |name|
      define_method(name) { self.attributes[name] }
      define_method("#{name}=") { |value| self.attributes[name] = value }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    return @table_name if !@table_name.nil?
    self.name.tableize
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
   params.each do |attr_name, value|
      # make sure to convert keys to symbols
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
