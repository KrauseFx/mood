require "sequel"

module Mood
  class Database
    def self.database
      @_db ||= Sequel.connect(ENV["DATABASE_URL"])

      unless @_db.table_exists?("moods")
        @_db.create_table :moods do
          primary_key :id
          DateTime :time
          Integer :value
        end
      end

      return @_db
    end
  end
end
