# encoding: utf-8
# 
# This script generates name lists for CCCA Lifetime members who has children currently enrolled
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, pg
# 
# Command to generate report => ruby ccca_lifetime_with_student.rb
# Output would be written to ccca_lifetime_with_student.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'

SCHOOL_YEAR_ID = 11

DB_HOST = 'localhost'
DB_USER = 'tocsorg_camyhsu'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "postgres://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"

FAMILY_SQL_STATEMENT =<<EOSQL
SELECT distinct families.id
FROM student_class_assignments, families_children, families
WHERE student_class_assignments.school_year_id = #{SCHOOL_YEAR_ID}
AND student_class_assignments.student_id = families_children.child_id
AND families_children.family_id = families.id
AND families.ccca_lifetime_member = TRUE
EOSQL


def find_name(person_id)
  person_record = DEV_DB['SELECT id, chinese_name, english_first_name, english_last_name FROM people WHERE id = ?', person_id].first
  "#{person_record[:chinese_name]}(#{person_record[:english_first_name]} #{person_record[:english_last_name]})"
end

def create_data_for(family_id)
  family_record = DEV_DB['SELECT id, parent_one_id, parent_two_id, address_id FROM families WHERE id = ?', family_id].first
  data = []
  if family_record[:parent_one_id].nil?
    data << ''
  else
    data << find_name(family_record[:parent_one_id])
  end
  if family_record[:parent_two_id].nil?
    data << ''
  else
    data << find_name(family_record[:parent_two_id])
  end
  data
end


CSV.open("ccca_lifetime_with_student.csv", "wb") do |csv|
  counter = 0
  csv << ['Parent One Name', 'Parent Two Name']
  DEV_DB[FAMILY_SQL_STATEMENT].each do |record|
    csv << create_data_for(record[:id])
    counter += 1
  end
  puts "Total family count => #{counter}"
end

