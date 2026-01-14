namespace :radd do

  namespace :db do
    desc 'Create database'
    task :create do
      load './db/schema.rb'
    end
  end
  
  desc 'Add record'
  task :add do
    require_relative 'lib/radd'
    
    print "Enter name: "
    name = STDIN.gets.chomp
    print "Password: "
    password = STDIN.gets.chomp
    print "Re-type password: "
    password_confirmation = STDIN.gets.chomp
    raise "Password mismatch!" unless password == password_confirmation
    record = Radd::Record.new(password: password)
    record.name = name
    record.save
    puts "Added record '#{name}'\n"
  end
  
  desc 'List all records'
  task :list do
    require_relative 'lib/radd'
    
    puts
    records = Radd::Record.all
    tab = [records.map(&:name).map(&:size).max, 24].compact.max
    records.each do |record|
      puts "#{record.name.ljust(tab)}  #{record.ip.to_s.ljust(15)}  #{record.updated_at || 'never updated'}\n"
    end
    puts
  end
  
end
