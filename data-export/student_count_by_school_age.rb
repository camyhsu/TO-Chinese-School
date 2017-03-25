# encoding: utf-8
# 
# This script counts students by school age
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, mysql
# 
# Command to generate report => ruby student_count_by_school_age.rb
# Output would be written to student_count_by_school_age.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'

CURRENT_SCHOOL_YEAR_ID = 7
CURRENT_SCHOOL_YEAR_START = 2014
AGE_CUTOFF_MONTH = 12

DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "mysql2://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"
DEV_DB.run "SET NAMES 'utf8' COLLATE 'utf8_unicode_ci'"


student_sql_statement =<<EOSQL
SELECT student_class_assignments.student_id, people.birth_year, people.birth_month
FROM student_class_assignments
LEFT JOIN people ON people.id = student_class_assignments.student_id
WHERE student_class_assignments.school_year_id = #{CURRENT_SCHOOL_YEAR_ID}
EOSQL


def school_age_of(student_record)
  school_age = CURRENT_SCHOOL_YEAR_START - student_record[:birth_year]
  return (school_age - 1) if AGE_CUTOFF_MONTH <= student_record[:birth_month]
  school_age
end

student_records = DEV_DB[student_sql_statement]
puts "Total Student Count => #{student_records.count.inspect}"

count_map = Hash.new {|hash, key| hash[key] = 0}
student_records.each do |student_record|
  count_map[school_age_of(student_record)] += 1
end


CSV.open("student_count_by_school_age.csv", "wb") do |csv|
  counter = 0
  csv << ["School Age", "Student Count"]
  count_map.keys.sort.each do |school_age|
    csv << [school_age, count_map[school_age]]
    counter += count_map[school_age]
  end
  puts "Total Zipcode Record Count => #{counter}"
end

