require 'byebug'
class AssocOptions

  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.singularize.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name  = options[:class_name]  || name.to_s.camelcase
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || "id".to_sym
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name  = options[:class_name]  || name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] || "#{self_class_name.downcase.singularize}_id".to_sym
    @primary_key = options[:primary_key] || "id".to_sym

  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      options.model_class.find(send(options.foreign_key))
    end
    @assoc_options = {name => options}
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      params = {options.foreign_key => send(options.primary_key)}
      options.model_class.where(params)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      results = DBConnection.execute(<<-SQL, self.id)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{source_options.table_name}
        JOIN
          #{through_options.table_name}
        ON
          #{through_options.table_name}.#{source_options.foreign_key} = #{source_options.table_name}.#{source_options.primary_key}
        JOIN
          #{self.class.table_name}
        ON
          #{self.class.table_name}.#{through_options.foreign_key} = #{through_options.table_name}.#{through_options.primary_key}
        WHERE
          #{self.class.table_name}.#{through_options.primary_key} = ?
      SQL

    source_options.model_class.parse_all(results).first
    end
  end
end
