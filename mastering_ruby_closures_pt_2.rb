# Implement Array#map using Array#each
class Array
  def map
    self.each { |a| yield a }
  end
end

%w(look ma no for loops).map do |x|
  puts x.upcase
end

# Implement String#each_word
class String
  def each_word
    self.split.each { |w| yield w }
  end
end

"Nothing lasts forever but cold November Rain".each_word do |x|
  puts x
end

# Implement File.open
class File
  def self.open(*args)
    file = File.new(*args)
    yield file
  ensure
    file.close if file
  end
end

File.open('test.txt', 'w') do |f|
  f << "Manage resources idiomatically"
end

File.open('test.txt', 'r') do |f|
  puts f.gets
end

`rm test.txt`

puts "\nImplement ActiveRecord Schema DSL"
module ActiveRecord
  class Schema
    def self.define(version, &block)
      instance_eval(&block)
    end

    def self.create_table(table_name, options = {}, &block)
      t = Table.new(table_name, options, &block)
    end
  end

  class Table
    def initialize(name, options)
      puts "Create table #{name}"
      yield self
    end

    def string(value)
      puts "Creating column of type string named #{value}"
    end

    def integer(value)
      puts "Creating column of type integer named #{value}"
    end

    def datetime(value)
      puts "Creating column of type datetime named #{value}"
    end
  end
end

ActiveRecord::Schema.define(version: 201806102201) do
  create_table "microposts", force: true do |t|
    t.string "content"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
