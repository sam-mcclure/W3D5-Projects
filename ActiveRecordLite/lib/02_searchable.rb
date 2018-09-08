require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    attr_names = []
    values = []
    params.each do |param|
      attr_names << param.first
      values << param.last
    end


    attrs = attr_names.map{|attr_name| "#{attr_name} = ?"}.join(" AND ")
    
    result = DBConnection.execute(<<-SQL, values)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{attrs}
    SQL

    return [] if result.empty?
    self.parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
