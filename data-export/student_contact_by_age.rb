# encoding: utf-8
# 
# This script extracts contact info based on student age for all students ever enrolled
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, pg
# 
# Command to generate report => ruby student_contact_by_age.rb
# Output would be written to student_contact_by_age.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'

AGE_RANGE_START_YEAR_INCLUSIVE = 1998
AGE_RANGE_START_MONTH_INCLUSIVE = 12
AGE_RANGE_END_YEAR_INCLUSIVE = 1999
AGE_RANGE_END_MONTH_INCLUSIVE = 12

DB_HOST = 'localhost'
DB_USER = 'tocsorg_camyhsu'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "postgres://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"

age_sql_statement =<<EOSQL
SELECT id, birth_year, birth_month, english_last_name, english_first_name, chinese_name
FROM people
WHERE people.birth_year >= #{AGE_RANGE_START_YEAR_INCLUSIVE}
AND people.birth_year <= #{AGE_RANGE_END_YEAR_INCLUSIVE}
EOSQL


def age_in_range?(potential_student)
  if potential_student[:birth_year] == AGE_RANGE_START_YEAR_INCLUSIVE
    return false if potential_student[:birth_month] < AGE_RANGE_START_MONTH_INCLUSIVE
  elsif potential_student[:birth_year] == AGE_RANGE_END_YEAR_INCLUSIVE
    return false if potential_student[:birth_month] > AGE_RANGE_END_MONTH_INCLUSIVE
  end
  true
end

def find_last_registered_school_year_id_record(student_id)
  class_assignment_sql_statement = "SELECT school_year_id FROM student_class_assignments WHERE student_id = #{student_id} ORDER BY school_year_id DESC LIMIT 1"
  DEV_DB[class_assignment_sql_statement].first
end

def find_family_record_for(student)
  family_id = DEV_DB["SELECT family_id FROM families_children WHERE child_id = #{student[:id]}"].first[:family_id]
  DEV_DB["SELECT parent_one_id, parent_two_id, address_id FROM families WHERE id = #{family_id}"].first
end

def find_parent_record(parent_id)
  return nil if parent_id.nil?
  DEV_DB["SELECT english_last_name, english_first_name, chinese_name FROM people WHERE id = #{parent_id}"].first
end

def find_address_record(address_id)
  DEV_DB["SELECT home_phone, email FROM addresses WHERE id = #{address_id}"].first
end

def name_for(person_record)
  return '' if person_record.nil?
  "#{person_record[:chinese_name]}(#{person_record[:english_first_name]} #{person_record[:english_last_name]})"
end


#
# Get School Year names into cache first
#
school_years = {}
DEV_DB['SELECT id, name FROM school_years'].each do |school_year_record|
  school_years[school_year_record[:id]] = "School Year #{school_year_record[:name]}"
end

#
# Potential students are people with birth year in the right range
#
potential_student_records = DEV_DB[age_sql_statement]
puts "Total Potential Student Count => #{potential_student_records.count.inspect}"

student_map = {}
potential_student_records.each do |potential_student|
  if age_in_range?(potential_student)
    last_registered_school_year_id_record = find_last_registered_school_year_id_record(potential_student[:id])
    unless last_registered_school_year_id_record.nil?
      student_map[potential_student] = last_registered_school_year_id_record[:school_year_id]
      puts "Student ID => #{potential_student[:id]}, last registered school year => #{student_map[potential_student]}"
    else
      puts "Student ID => #{potential_student[:id]} DID NOT registered"
    end
  else
    puts "Student ID => #{potential_student[:id]} NOT in age range"
  end
end


CSV.open("student_contact_by_age.csv", "wb") do |csv|
  counter = 0
  csv << ['Student Name', 'Parent One Name', 'Parent Two Name', 'Family Email', 'Family Home Phone', 'Last Registered School Year']
  student_map.each_pair do |student, last_registered_school_year_id|
    family_record = find_family_record_for(student)
    address_record = find_address_record(family_record[:address_id])
    csv << [name_for(student), name_for(find_parent_record(family_record[:parent_one_id])), name_for(find_parent_record(family_record[:parent_two_id])), address_record[:email], address_record[:home_phone], school_years[last_registered_school_year_id]]
    counter += 1
  end
  puts "Total Student Count => #{counter}"
end

