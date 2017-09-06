# encoding: utf-8
# 
# This script generates name lists for CCCA TO Journal distribution
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, pg
# 
# Command to generate report => ruby ccca_to_journal_name_list.rb
# Output would be written to ccca_toj_tearcher_name_list.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'

CURRENT_SCHOOL_YEAR_ID = 11

DB_HOST = 'localhost'
DB_USER = 'tocsorg_camyhsu'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "postgres://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"

teacher_sql_statement =<<EOSQL
SELECT people.id, people.english_first_name, people.english_last_name, people.chinese_name, 
school_classes.english_name, school_classes.chinese_name as class_chinese_name, school_classes.short_name, school_classes.location 
FROM people, instructor_assignments, school_classes 
WHERE instructor_assignments.school_year_id = #{CURRENT_SCHOOL_YEAR_ID}
AND instructor_assignments.instructor_id = people.id 
AND instructor_assignments.school_class_id = school_classes.id 
AND instructor_assignments.role LIKE '%Instructor'
EOSQL

student_sql_statement =<<EOSQL
SELECT people.id, people.english_first_name, people.english_last_name, people.chinese_name, 
school_classes.english_name, school_classes.chinese_name as class_chinese_name, school_classes.short_name, school_classes.location 
FROM people, student_class_assignments, school_classes 
WHERE student_class_assignments.school_year_id = #{CURRENT_SCHOOL_YEAR_ID}
AND student_class_assignments.student_id = people.id 
AND student_class_assignments.school_class_id = school_classes.id 
ORDER BY student_class_assignments.grade_id ASC
EOSQL

def family_already_processed(person_id, processed_family_id)
  family = DEV_DB["SELECT id, ccca_lifetime_member FROM families WHERE parent_one_id = ? OR parent_two_id = ?", person_id, person_id].first
  if family.nil?
    family = DEV_DB["SELECT id, ccca_lifetime_member FROM families JOIN families_children ON families.id = families_children.family_id WHERE families_children.child_id = ?", person_id].first
  end
  return true if family[:ccca_lifetime_member] # Skip CCCA lifetime member family
  if processed_family_id.include? family[:id]
    true
  else
    processed_family_id << family[:id]
    false
  end
end

def create_data_from(record)
  data = []
  data << record[:english_first_name]
  data << record[:english_last_name]
  data << record[:chinese_name]
  data << record[:english_name]
  data << record[:class_chinese_name]
  data << record[:short_name]
  data << record[:location]
  data
end


processed_family_id = []

teachers = DEV_DB[teacher_sql_statement]
puts teachers.count.inspect

CSV.open("ccca_toj_tearcher_name_list.csv", "wb") do |csv|
  counter = 0
  csv << ["English First Name", "English Last Name", "Chinese Name", "Class English Name", "Class Chinese Name", "Class Short Name", "Location"]
  teachers.each do |record|
    unless family_already_processed(record[:id], processed_family_id)
      csv << create_data_from(record)
      counter += 1
    end
  end
  puts "Total teacher count => #{counter}"
end

students = DEV_DB[student_sql_statement]
puts students.count.inspect

CSV.open("ccca_toj_student_name_list.csv", "wb") do |csv|
  counter = 0
  csv << ["English First Name", "English Last Name", "Chinese Name", "Class English Name", "Class Chinese Name", "Class Short Name", "Location"]
  students.each do |record|
    unless family_already_processed(record[:id], processed_family_id)
      csv << create_data_from(record)
      counter += 1
    end
  end
  puts "Total student count => #{counter}"
end

