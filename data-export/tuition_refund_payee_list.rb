# encoding: utf-8
# 
# This script generates payee list for tuition refund in year 2020
#
# The list will be one registered student per row sorted by class
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, pg
# 
# Command to generate report => ruby tuition_refund_payee_list.rb
# Output would be written to tuition_refund_payee_list.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'

SCHOOL_YEAR_ID = 13

DB_HOST = 'localhost'
DB_USER = 'tocsorg_registration'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "postgres://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/registration"

STUDENT_SQL_STATEMENT =<<EOSQL
SELECT student_class_assignments.id, school_classes.id scid, school_classes.short_name, people.chinese_name, people.english_first_name, people.english_last_name, families_children.family_id
FROM student_class_assignments
JOIN people ON student_class_assignments.student_id = people.id
LEFT JOIN school_classes ON school_classes.id = student_class_assignments.school_class_id
LEFT JOIN families_children ON student_class_assignments.student_id = families_children.child_id
WHERE student_class_assignments.school_year_id = #{SCHOOL_YEAR_ID}
ORDER BY school_classes.short_name
EOSQL

# Get teacher names into a cache
TEACHER_SQL_STATEMENT =<<EOSQL
SELECT instructor_assignments.id, instructor_assignments.school_class_id, people.english_first_name, people.english_last_name
FROM instructor_assignments
JOIN people ON instructor_assignments.instructor_id = people.id
WHERE instructor_assignments.role = 'Primary Instructor' 
AND instructor_assignments.school_year_id = #{SCHOOL_YEAR_ID}
EOSQL

TEACHER_NAMES = {}
DEV_DB[TEACHER_SQL_STATEMENT].each do |record|
  TEACHER_NAMES[record[:school_class_id]] = "#{record[:english_first_name]} #{record[:english_last_name]}"
end


def add_payee_name(data, person_id)
  person_record = DEV_DB['SELECT id, chinese_name, english_first_name, english_last_name FROM people WHERE id = ?', person_id].first
  data << "#{person_record[:english_first_name]} #{person_record[:english_last_name]}"
  data << person_record[:chinese_name]
end

def create_data_for(student_record)
  family_record = DEV_DB['SELECT id, parent_one_id, address_id FROM families WHERE id = ?', student_record[:family_id]].first
  data = []
  if family_record[:parent_one_id].nil?
    data << ''
    data << ''
  else
    add_payee_name(data, family_record[:parent_one_id])
  end

  # Leave Payee Nickname blank
  data << ''

  if family_record[:address_id].nil?
    data << ''
    data << ''
    data << ''
    data << ''
    data << ''
  else
    address_record = DEV_DB['SELECT * FROM addresses WHERE id = ?', family_record[:address_id]].first
    data << address_record[:street]
    data << address_record[:city]
    data << address_record[:state]
    data << address_record[:zipcode]
    data << address_record[:home_phone]
  end

  data << student_record[:short_name]
  data << student_record[:chinese_name]
  data << "#{student_record[:english_first_name]} #{student_record[:english_last_name]}"

  data << TEACHER_NAMES[student_record[:scid]]
  data
end


CSV.open("tuition_refund_payee_list.csv", "wb") do |csv|
  counter = 0
  csv << ['Payee Name', 'Payee Chinese Name', 'Payee Nickname', 'Street Address', 'City', 'State', 'Zip Code', 'Home Phone Number', 'Class', 'Student Chinese Name', 'Student English Name', 'Teacher Name']
  DEV_DB[STUDENT_SQL_STATEMENT].each do |record|
    csv << create_data_for(record)
    counter += 1
  end
  puts "Total student count => #{counter}"
end

