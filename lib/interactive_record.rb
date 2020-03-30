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
      self.table_name
    end

    def self.find_by_name(name)
      sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
      DB[:conn].execute(sql, name)
    end

    def self.find_by(attribute)
      attribute.each do |k,v|
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE ? = ?", k, v)
      end
    end

end
