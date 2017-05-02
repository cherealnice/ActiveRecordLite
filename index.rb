require_relative './lib/associatable'
require_relative './lib/db_connection'
require_relative './lib/sql_object'
require 'sqlite3'
require 'active_support/inflector'

class Cat < SQLObject
   self.finalize!
 end

class Human < SQLObject
 self.table_name = 'humans'

 self.finalize!
end

class House < SQLObject
  self.finalize!
end

Cat.belongs_to(:owner,
  {class_name: 'Human', foreign_key: :owner_id}
)

Human.has_many(:cats, {foreign_key: :owner_id})

Human.belongs_to(:house)

House.has_many(:humans)

Cat.has_one_through(:house, :owner, :house)
