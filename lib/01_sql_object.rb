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
    columns = data[0].map(&:to_sym)
    @columns = columns
  end

  def self.finalize!
    self.columns.each do |col_name|
      define_method(col_name) { self.attributes[col_name] }
      define_method("#{col_name}=") { |set_val| self.attributes[col_name] = set_val }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = #{id}
      LIMIT 1
    SQL
    parse_all(data)[0]
  end

  def initialize(params = {})
    params.each do |attr_name,value|
      name = attr_name.to_sym
      if self.class.columns.include?(name)
        self.send("#{attr_name}=",value)
      else
        raise "unknown attribute '#{name}'"
      end
    end
    
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col|
      self.send(col)
    end
  end

  def insert
    columns = self.class.columns
    col_names = columns.join(',')
    question_marks = columns.count.times { [] << "?" }

    data = DBConnection.execute(<<-SQL,col_names,*attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (?)
      VALUES
        (#{question_marks})
    SQL
    data
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
