class Dog
  attr_accessor :name, :breed, :id

  # CLASS METHODS ********************************
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed text
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def self.create(name:, breed:)
    new_dog = new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?;", id)[0]
    new_from_db(result)
  end

  def self.find_or_create_by(name:, breed:)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)[0]
    if result
      new_from_db(result)
    else
      new_dog = new(name: name, breed: breed)
      new_dog.save
      new_dog
    end
  end

  def self.new_from_db(attributes)
    new(name: attributes[1], breed: attributes[2], id: attributes[0])
  end

  def self.find_by_name(name)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?;", name)[0]
    new_from_db(result)
  end

  # INSTANCE METHODS ********************************
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def save
    if id
      update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end

    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
        SET name = ?,
            breed = ?
        WHERE id = ?;
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
  end
end
