require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    def self.table_name
      self.to_s.downcase.pluralize
    end

    def self.column_names
      DB[:conn].results_as_hash = true
      sql = "PRAGMA table_info('#{table_name}')"
      table_info = DB[:conn].execute(sql)
      column_names = []
      table_info.each do |row|
        column_names << row["name"]
      end
      column_names.compact
    end

    def initialize(attributes = {})
      # binding.pry
      attributes.each do |prop, val|
        self.send("#{prop}=", val)
      end
    end

    def table_name_for_insert
      self.class.table_name
    end

    def col_names_for_insert
      self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def values_for_insert
      values = []
      self.class.column_names.each do |col_name|
        values << "'#{send(col_name)}'" unless send(col_name).nil?
      end
      values.join(", ")
    end

    def save
      sql = <<-SQL
        INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert})
        VALUES (#{self.values_for_insert})
      SQL
      DB[:conn].execute(sql)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
    end

    def self.find_by_name(name)
      sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
      DB[:conn].execute(sql, name)
    end

    def self.find_by(attribute)
      what_to_find = nil
      attribute.each do |k,v|
        what_to_find = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{k.to_s} = '#{v}';")
      end
      what_to_find
    end
end
