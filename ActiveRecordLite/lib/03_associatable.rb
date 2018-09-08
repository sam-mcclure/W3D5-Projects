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
    @class_name.to_s.constantize
  end

  def table_name
    @class_name.to_s.downcase + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @primary_key = options[:primary_key] || @primary_key = :id
    @foreign_key = options[:foreign_key] || @foreign_key = (name.to_s.underscore + "_id").to_sym
    @class_name = options[:class_name] || @class_name = name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @primary_key = options[:primary_key] || @primary_key = :id
    @foreign_key = options[:foreign_key] || @foreign_key = (self_class_name.to_s.downcase.underscore + "_id").to_sym
    @class_name = options[:class_name] || @class_name = name.to_s.singularize.camelcase
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})

  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
