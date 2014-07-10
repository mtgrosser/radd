require_relative '../radd'

if DB.tables.include?(:records)
  puts "Schema exists, skipping"
else
  DB.create_table :records do
    String    :name, primary_key: true
    String    :password_hash
    String    :ip
    DateTime  :updated_at
  end
  puts "Created schema"
end
