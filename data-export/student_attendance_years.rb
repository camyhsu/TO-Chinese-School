# encoding: utf-8
# 
# This script extracts student attendance data based on student age
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, pg
# 
# Command to generate report => ruby student_attendance_years.rb
# Output would be written to student_attendance_years.csv
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

STUDENT_BY_AGE_SQL =<<EOSQL
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

def find_school_year_attendance_records(student_id)
  class_assignment_sql_statement = "SELECT school_year_id FROM student_class_assignments WHERE student_id = #{student_id}"
  DEV_DB[class_assignment_sql_statement].collect { |class_assignment_record| class_assignment_record[:school_year_id] }
end

def name_for(person_record)
  return '' if person_record.nil?
  "#{person_record[:chinese_name]}(#{person_record[:english_first_name]} #{person_record[:english_last_name]})"
end

def append_attendance_flags(data, school_year_attendance_records)
  # current implementation works specifically for school_year_id from 4 to 7 in sequence
  (4..7).each do |school_year_id|
    if school_year_attendance_records.include?(school_year_id)
      data << 'YES'
    else
      data << 'NO'
    end
  end
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
potential_student_records = DEV_DB[STUDENT_BY_AGE_SQL]
puts "Total Potential Student Count => #{potential_student_records.count.inspect}"

student_map = {}
potential_student_records.each do |potential_student|
  if age_in_range?(potential_student)
    school_year_attendance_records = find_school_year_attendance_records(potential_student[:id])
    if school_year_attendance_records.nil? || school_year_attendance_records.empty?
      puts "Student ID => #{potential_student[:id]} DID NOT registered"
    else
      student_map[potential_student] = school_year_attendance_records
      puts "Student ID => #{potential_student[:id]}, attended school years => #{student_map[potential_student]}"
    end
  else
    puts "Student ID => #{potential_student[:id]} NOT in age range"
  end
end


CSV.open('student_attendance_years.csv', 'wb') do |csv|
  counter = 0
  csv << ['Student Name', 'Attended 2011-2012', 'Attended 2012-2013', 'Attended 2013-2014', 'Attended 2014-2015']
  student_map.each_pair do |student, school_year_attendance_records|
    data = []
    data << name_for(student)
    append_attendance_flags(data, school_year_attendance_records)
    csv << data
    counter += 1
  end
  puts "Total Student Count => #{counter}"
end

