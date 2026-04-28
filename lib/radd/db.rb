require 'sequel'

DB = Sequel.connect("sqlite://#{Radd.db}")
