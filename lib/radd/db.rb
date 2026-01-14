require 'sequel'

DB = Sequel.connect("sqlite://#{Pathname.new(__FILE__).dirname.join('..', '..', 'db', 'radd.sqlite3')}")
