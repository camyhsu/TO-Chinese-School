# encoding: utf-8
# 
# This script generates family list for CCCA regular member voting
#
# This list excludes lifttime members.
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, pg
# 
# Command to generate report => ruby ccca_regular_voter_list.rb
# Output would be written to ccca_regular_voter_list.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'

CURRENT_SCHOOL_YEAR_ID = 11

DB_HOST = 'localhost'
DB_USER = 'tocsorg_camyhsu'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "postgres://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"

student_sql_statement =<<EOSQL
SELECT people.id
FROM people, student_class_assignments, school_classes 
WHERE student_class_assignments.school_year_id = #{CURRENT_SCHOOL_YEAR_ID}
AND student_class_assignments.student_id = people.id 
AND student_class_assignments.school_class_id = school_classes.id
EOSQL


def add_family_to_voter_collection(student, voter_family_ids)
  family = DEV_DB["SELECT id, ccca_lifetime_member FROM families JOIN families_children ON families.id = families_children.family_id WHERE families_children.child_id = ?", student[:id]].first
  return if family[:ccca_lifetime_member] # Skip CCCA lifetime member family
  voter_family_ids << family[:id] unless voter_family_ids.include?(family[:id])
end

def format_full_name(english_first_name, english_last_name, chinese_name)
  if (english_last_name.nil? || english_last_name.empty?)
    ''
  else
    "#{chinese_name} (#{english_first_name} #{english_last_name})"
  end
end

def create_data_from(family_data)
  data = []
  data << format_full_name(family_data[:parentone_english_first_name], family_data[:parentone_english_last_name], family_data[:parentone_chinese_name])
  data << format_full_name(family_data[:parenttwo_english_first_name], family_data[:parenttwo_english_last_name], family_data[:parenttwo_chinese_name])
  data << "#{family_data[:street]}, #{family_data[:city]}, #{family_data[:state]} #{family_data[:zipcode]}"
  data << family_data[:email]
  data
end


## start of main script body
voter_family_ids = []

students = DEV_DB[student_sql_statement]
puts students.count.inspect

students.each do |student|
  add_family_to_voter_collection(student, voter_family_ids)
end

family_sql_statement =<<EOSQL
SELECT parentone.english_first_name AS parentone_english_first_name, 
parentone.english_last_name AS parentone_english_last_name, 
parentone.chinese_name AS parentone_chinese_name, 
parenttwo.english_first_name AS parenttwo_english_first_name, 
parenttwo.english_last_name AS parenttwo_english_last_name, 
parenttwo.chinese_name AS parenttwo_chinese_name,
addresses.street, addresses.city, addresses.state, addresses.zipcode, addresses.email
FROM families
LEFT JOIN people parentone ON parentone.id = families.parent_one_id
LEFT JOIN people parenttwo ON parenttwo.id = families.parent_two_id
LEFT JOIN addresses ON addresses.id = families.address_id
WHERE families.id IN (#{voter_family_ids.join(',')})
ORDER BY addresses.street
EOSQL


CSV.open("ccca_regular_voter_list.csv", "wb") do |csv|

  csv << ["Parent One Name", "Parent Two Name", "Address", "email"]
  counter = 0
  DEV_DB[family_sql_statement].each do |family_data|
    csv << create_data_from(family_data)
    counter += 1
  end

  puts "Total family count => #{counter}"
end

