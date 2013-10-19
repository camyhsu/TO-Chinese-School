# encoding: utf-8
# 
# This script generates track event signup list for HaiHua.
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, mysql
# 
# Command to generate report => ruby haihua_track_event_signups.rb
# Output would be written to haihua_track_event_signups.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'


DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "mysql://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"
DEV_DB.run "SET NAMES 'utf8' COLLATE 'utf8_unicode_ci'"

signup_record_sql_statement =<<EOSQL
SELECT people.id, people.english_first_name, people.english_last_name, people.chinese_name, 
people.gender, people.birth_year, program.name, signup.group_name
FROM people, track_event_programs program, track_event_signups signup
WHERE program.school_year_id = 4 
AND program.event_type = 'Southern CA'
AND signup.track_event_program_id = program.id 
AND signup.student_id = people.id 
ORDER BY people.english_last_name, people.english_first_name
EOSQL

@cached_addresses = {}

def find_address_record(student_id)
  cached_address_record = @cached_addresses[student_id]
  return cached_address_record unless cached_address_record.nil?
  address_record = DEV_DB["SELECT addresses.home_phone, addresses.email FROM addresses, families, families_children WHERE addresses.id = families.address_id AND families.id = families_children.family_id AND families_children.child_id = ?", student_id].first
  if address_record.nil?
    # Could not find address information
    {:home_phone => '', :email => ''}
  else
    @cached_addresses[student_id] = address_record
    address_record
  end
end

def create_data_from(record)
  address_record = find_address_record(record[:id])
  data = []
  data << record[:english_last_name]
  data << record[:english_first_name]
  data << record[:chinese_name]
  data << record[:gender]
  data << record[:birth_year]
  data << address_record[:home_phone]
  data << address_record[:email]
  data << record[:name]
  data << record[:group_name]
  data
end

CSV.open("haihua_track_event_signups.csv", "wb") do |csv|
  counter = 0
  csv << ["English Last Name", "English First Name", "Chinese Name", "Gender", "Birth Year", "Family Phone Number", "Family Email", "Program Name", "Relay Team Group"]
  DEV_DB[signup_record_sql_statement].each do |record|
    csv << create_data_from(record)
    counter += 1
  end
  puts "Total signup count => #{counter}"
end
