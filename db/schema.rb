require 'sequel'

DB = Sequel.sqlite(File.join(File.dirname(__FILE__), 'radd.db'))

DB.create_table :records do
  String :name, primary_key: true
  String :crypted_password
  String :ip
  DateTime :updated_at
end
