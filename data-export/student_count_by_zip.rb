# encoding: utf-8
# 
# This script counts students by zipcode
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, mysql
# 
# Command to generate report => ruby student_count_by_zip.rb
# Output would be written to student_count_by_zip.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'

CURRENT_SCHOOL_YEAR_ID = 7

DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "mysql2://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"
DEV_DB.run "SET NAMES 'utf8' COLLATE 'utf8_unicode_ci'"


student_sql_statement =<<EOSQL
SELECT student_class_assignments.student_id, addresses.zipcode
FROM student_class_assignments
JOIN families_children ON families_children.child_id = student_class_assignments.student_id
JOIN families ON families.id = families_children.family_id
JOIN addresses ON families.address_id = addresses.id
WHERE school_year_id = #{CURRENT_SCHOOL_YEAR_ID}
EOSQL


student_records = DEV_DB[student_sql_statement]
puts "Total Student Count => #{student_records.count.inspect}"

count_map = Hash.new {|hash, key| hash[key] = 0}
student_records.each do |record|
  count_map[record[:zipcode][0..4]] += 1
end


CSV.open("student_count_by_zip.csv", "wb") do |csv|
  counter = 0
  csv << ["Zipcode", "Student Count"]
  count_map.each_pair do |key, value|
    csv << [key, value]
    counter += value
  end
  puts "Total Zipcode Record Count => #{counter}"
end

