# encoding: utf-8
#
# This script generates name lists for CCCA "friend" which are families
# with registered student last school year but not this school year.
#
# Required dependencies:
# Ruby
# Ruby gems => sequel, mysql
#
# Command to generate report => ruby ccca_recent_friend_list.rb
# Output would be written to ccca_recent_friend_list.csv
#
require 'rubygems'
require 'sequel'
require 'csv'

LAST_SCHOOL_YEAR_ID = 5
CURRENT_SCHOOL_YEAR_ID = 6

DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "mysql://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"
DEV_DB.run "SET NAMES 'utf8' COLLATE 'utf8_unicode_ci'"


STUDENT_IDS_SQL =<<EOSQL
SELECT student_id
FROM student_class_assignments
WHERE school_year_id = #{LAST_SCHOOL_YEAR_ID}
AND student_id NOT IN (SELECT student_id FROM student_class_assignments WHERE school_year_id = #{CURRENT_SCHOOL_YEAR_ID})
ORDER BY student_id
EOSQL

SIBLING_SQL =<<EOSQL
SELECT child_id
FROM families_children
WHERE family_id = ?
AND child_id <> ?
EOSQL

FAMILY_SQL =<<EOSQL
SELECT families.id, families.parent_one_id, families.parent_two_id, families.ccca_lifetime_member, 
addresses.street, addresses.city, addresses.state, addresses.zipcode, addresses.home_phone, addresses.email
FROM families, families_children, addresses
WHERE families.id = families_children.family_id
AND families.address_id = addresses.id
AND families_children.child_id = ?
EOSQL

PARENT_SQL =<<EOSQL
SELECT people.english_first_name, people.english_last_name, people.chinese_name
FROM people
WHERE id = ?
EOSQL


def sibling_still_in_school?(student_id)
  family_id = DEV_DB['SELECT family_id FROM families_children WHERE child_id = ?', student_id].first[:family_id]
  sibling_ids = []
  DEV_DB[SIBLING_SQL, family_id, student_id].each { |record| sibling_ids << record[:child_id] }
  return false if sibling_ids.empty?
  class_assignment_count = DEV_DB["SELECT count(1) AS count FROM student_class_assignments WHERE student_id IN (#{sibling_ids.join(',')}) AND school_year_id = #{CURRENT_SCHOOL_YEAR_ID}"].first[:count]
  return true if class_assignment_count > 0
  false
end

def find_parent_name(parent_id)
  parent_record = DEV_DB[PARENT_SQL, parent_id].first
  if parent_record.nil?
    ''
  else
    "#{parent_record[:chinese_name]} (#{parent_record[:english_first_name]} #{parent_record[:english_last_name]})"
  end
end

def create_data_from(record)
  data = []
  data << find_parent_name(record[:parent_one_id])
  data << find_parent_name(record[:parent_two_id])
  data << record[:street]
  data << record[:city]
  data << record[:state]
  data << record[:zipcode]
  data << record[:home_phone]
  data << record[:email]
  data
end


student_ids = []
DEV_DB[STUDENT_IDS_SQL].each { |record| student_ids << record[:student_id] }

# Student id 4645 is a special case where the student is not a child of a family
student_ids.delete 4645

student_ids.reject! { |student_id| sibling_still_in_school?(student_id) }

processed_family_ids = {}
CSV.open("ccca_recent_friend_list.csv", "wb") do |csv|
  counter = 0
  csv << ["Parent One Name", "Parent Two Name", "Street", "City", "State", "Zipcode", "Home Phone", "Email"]
  student_ids.each do |student_id|
    family_record = DEV_DB[FAMILY_SQL, student_id].first
    if (!family_record[:ccca_lifetime_member]) && processed_family_ids[family_record[:id]].nil?
      csv << create_data_from(family_record)
      processed_family_ids[family_record[:id]] = 1
      counter += 1
    end
  end
  puts "Total family count => #{counter}"
end
