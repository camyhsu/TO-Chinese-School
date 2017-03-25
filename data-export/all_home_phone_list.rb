# encoding: utf-8
# 
# This script generates home phone lists from the whole TOCS database.
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, mysql
# 
# Command to generate report => ruby all_home_phone_list.rb
# Output would be written to all_home_phone_list.txt
# 
require 'rubygems'
require 'sequel'


DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "mysql2://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"
DEV_DB.run "SET NAMES 'utf8' COLLATE 'utf8_unicode_ci'"


File.open('all_home_phone_list.txt', 'wb') do |file|
  counter = 0
  DEV_DB['SELECT distinct home_phone FROM addresses WHERE home_phone IS NOT NULL'].each do |record|
    file.puts record[:home_phone]
    counter += 1
  end
  puts "Total home phone count => #{counter}"
end

