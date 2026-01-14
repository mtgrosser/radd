require_relative '../lib/radd/db'

  DB.create_table? :records do
    String    :name, primary_key: true
    String    :password_hash
    String    :ip
    DateTime  :updated_at
  end
  