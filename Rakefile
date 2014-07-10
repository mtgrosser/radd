require_relative 'radd'

namespace :radd do
  
  desc 'Add record'
  task :add do
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
  
end