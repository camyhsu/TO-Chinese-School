# encoding: utf-8
# 
# This script generates name lists for CCCA TO Journal distribution
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, mysql
# 
# Command to generate report => ruby ccca_to_journal_name_list.rb
# Output would be written to ccca_toj_tearcher_name_list.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'


DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "mysql://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"
DEV_DB.run "SET NAMES 'utf8' COLLATE 'utf8_unicode_ci'"


FAMILY_SQL_STATEMENT =<<EOSQL
SELECT distinct families_children.family_id
FROM student_class_assignments, families_children
WHERE student_class_assignments.school_year_id = 4 
AND student_class_assignments.student_id = families_children.child_id 
ORDER BY student_class_assignments.grade_id ASC
EOSQL


def find_name(person_id)
  person_record = DEV_DB['SELECT * FROM people WHERE id = ?', person_id].first
  if person_record[:gender] == 'M'
    salutation = 'Mr.'
  else
    salutation = 'Mrs.'
  end
  "#{salutation} #{person_record[:chinese_name]}(#{person_record[:english_first_name]} #{person_record[:english_last_name]})"
end

def create_data_for(family_id)
  family_record = DEV_DB['SELECT * FROM families WHERE id = ?', family_id].first
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
  if family_record[:address_id].nil?
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
  end
  data
end


CSV.open("ccca_student_family_list.csv", "wb") do |csv|
  counter = 0
  csv << ["Parent One Name", "Parent Two Name", "Street Address", "City", "State", "Zip"]
  DEV_DB[FAMILY_SQL_STATEMENT].each do |record|
    csv << create_data_for(record[:family_id])
    counter += 1
  end
  puts "Total student count => #{counter}"
end

