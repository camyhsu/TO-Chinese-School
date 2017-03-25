# encoding: utf-8
# 
# This script generates email list to be imported by Mail Chimp for CCCA
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, pg
# 
# Command to generate report => ruby mail_chimp_export.rb
# Output would be written to mail_chimp_export.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'

CURRENT_SCHOOL_YEAR_ID = 9

DB_HOST = 'localhost'
DB_USER = 'tocsorg_camyhsu'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "postgres://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"

FAMILY_SQL_STATEMENT =<<EOSQL
SELECT families.id, families.parent_one_id, families.parent_two_id, families.ccca_lifetime_member, addresses.email
FROM families
JOIN addresses ON families.address_id = addresses.id
WHERE addresses.email IS NOT NULL
AND addresses.email <> ''
AND ((families.parent_one_id IS NOT NULL) OR (families.parent_two_id IS NOT NULL))
EOSQL

ENROLLMENT_SQL_STATEMENT =<<EOSQL
SELECT DISTINCT families.id
FROM student_class_assignments, families_children, families
WHERE student_class_assignments.school_year_id = #{CURRENT_SCHOOL_YEAR_ID}
AND student_class_assignments.student_id = families_children.child_id
AND families_children.family_id = families.id
EOSQL


def add_parent_name(data, family_record)
  parent_id = family_record[:parent_one_id]
  parent_id = family_record[:parent_two_id] if parent_id.nil?
  parent_record = DEV_DB['SELECT english_first_name, english_last_name FROM people WHERE id = ?', parent_id].first
  data << parent_record[:english_first_name]
  data << parent_record[:english_last_name]
end

def add_current_state_flags(data, family_record, enrolled_family_ids)
  if enrolled_family_ids.include? family_record[:id]
    data << 'Y'
    data << 'Y'
  elsif family_record[:ccca_lifetime_member]
    data << 'Y'
    data << 'N'
  else
    data << 'N'
    data << 'N'
  end
end

def create_data_from(family_record, enrolled_family_ids)
  data = []
  add_parent_name(data, family_record)
  data << family_record[:email]
  add_current_state_flags(data, family_record, enrolled_family_ids)
  data
end


families = DEV_DB[FAMILY_SQL_STATEMENT]
puts families.count.inspect

enrolled_family_ids = DEV_DB[ENROLLMENT_SQL_STATEMENT].collect { |record| record[:id] }
puts "Total enrolled family count => #{enrolled_family_ids.size}"

CSV.open("mail_chimp_export.csv", "wb") do |csv|
  counter = 0
  csv << ["English First Name", "English Last Name", "Email Address", "Current CCCA Member", "Current TOCS family"]
  families.each do |family_record|
    csv << create_data_from(family_record, enrolled_family_ids)
    counter += 1
  end
  puts "Total family count => #{counter}"
end
