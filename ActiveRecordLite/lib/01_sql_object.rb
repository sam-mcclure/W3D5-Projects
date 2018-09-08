require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
   info = DBConnection.execute2(<<-SQL)
  SELECT
    *
  FROM
    #{self.table_name}
    SQL
  info = info[0].map(&:to_sym)
  @columns = info
  end

  def self.finalize!
    self.columns.each do |name|
      define_method(name) { attributes[name] }
      define_method("#{name}=") {|value| attributes[name] = value}
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || @table_name = self.to_s.tableize
  end

  def self.all
    hash = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    self.parse_all(hash)
  end

  def self.parse_all(results)
    objects = []
    results.each do |row|
      objects << self.new(row)
    end
    objects
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      id = ?
    SQL
    return nil if result.empty?
    self.new(result.first)
  end

  def initialize(params = {})
    self.class.finalize!
    columns = self.class.columns


    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless columns.include?(attr_name)
      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    return @attributes unless @attributes.nil?
    @attributes = {}
  end

  def attribute_values
    columns = self.class.columns
    columns.map do |attr_name|
      self.send(attr_name)
    end
  end

  def insert
    columns = self.class.columns
    col_names = columns.join(", ")
    question_marks = (["?"] * columns.length).join(", ")
    values = attribute_values

    result = DBConnection.execute(<<-SQL, *values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    columns = self.class.columns
    set = columns.map {|attr_name| "#{attr_name} = ?"}.join(", ")
    values = attribute_values

    DBConnection.execute(<<-SQL, values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id.nil?
      insert
    else
      update
    end
  end
end
