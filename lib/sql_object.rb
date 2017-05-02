class SQLObject
  extend Associatable

  def self.columns
    table = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    table.first.map(&:to_sym)
    end

  def self.finalize!

    self.columns.each do |col|
      define_method(col) {self.attributes[col]}

      define_method("#{col}=") do |new_val|
        self.attributes[col] = new_val

      end
    end
  end

  def self.table_name=(table_name)
    @table_name
  end

  def self.table_name
    @table_name || "#{self.to_s.downcase}s"
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.first
    self.all[0]
  end

  def self.parse_all(results)
    results.map do |result|
      new result
    end
  end

  def self.find(id)
    instance = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    instance.empty? ? nil : parse_all(instance).first
  end

  def self.where(params)
    where_line = params.map {|name, val| "#{name} = ?" }.join(" AND ")
    values = params.values
    results =
    DBConnection.execute(<<-SQL, values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(results)
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_symb = ":@#{attr_name}"

      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end

      send("#{attr_name}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    col_names = self.class.columns[1..-1].join(', ')
    q_marks = (["?"] * attribute_values.length).join(', ')

    results = DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name}
        (#{col_names})
      VALUES
        (#{q_marks})

    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    attr_names = self.class.columns[1..-1].map do |attr_name|
      "#{attr_name} = ?"
    end.join(', ')

    attr_vals = attribute_values[1..-1] + [id]

    results = DBConnection.execute(<<-SQL, *attr_vals)
      UPDATE
        #{self.class.table_name}
      SET
        #{attr_names}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
