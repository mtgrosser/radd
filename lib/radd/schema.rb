module Radd
  module Schema
    def self.create
      if DB.table_exists?(:records)
        puts "Database #{Radd.db} exists"
        exit(1)
      end
      DB.create_table?(:records) do
        String    :name, primary_key: true
        String    :password_hash
        String    :ip
        DateTime  :updated_at
      end
      puts "Created database #{Radd.db}"
    end
  end
end
