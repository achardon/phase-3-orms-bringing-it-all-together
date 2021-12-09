require 'pry'
require_relative '../config/environment'


#last two methods in Dog class do not work correctly

class Dog
    attr_accessor :name, :breed, :id
    
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY, 
            name TEXT,
            breed TEXT)
        SQL
            
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
            SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
  
      DB[:conn].execute(sql, self.name, self.breed)
  
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  
      self
    end

    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        sql = "SELECT * FROM dogs"
        DB[:conn].execute(sql).map do |dog|
            self.new_from_db(dog)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name=? LIMIT 1"
        self.new_from_db(DB[:conn].execute(sql, name).first)
    end

    def self.find(id)
        sql = "SELECT * FROM dogs WHERE id=? LIMIT 1"
        self.new_from_db(DB[:conn].execute(sql, id).first)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE (dogs.name = ? AND dogs.breed = ?)
            LIMIT 1
            SQL
        current_dog = self.new_from_db(DB[:conn].execute(sql, name, breed).first)
        current_dog ? current_dog : self.create(name: name, breed: breed) 
    end

    def update
        # self.create(id: self.id, name: self.name, breed: self.breed)
        sql = <<-SQL
            UPDATE dogs
            SET name = #{self.name}
            WHERE id = #{self.id}
            SQL
        x = DB[:conn].execute(sql)
    end

end

# Dog.create(name: 'teddy', breed: 'cockapoo')
# Dog.create(name: 'teddy', breed: 'pug')

# new_dog = Dog.find_or_create_by(name: 'teddy', breed: 'irish setter')

