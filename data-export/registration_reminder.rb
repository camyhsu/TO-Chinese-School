# encoding: utf-8
# 
# This script pulls family emails for a parent who has a user account and has 
# at least one student completing Chinese School previous school year that was 9th 
# grade or under, and has not registered for the coming school year.
# 
# Required dependencies:
# Ruby
# Ruby gems => sequel, mysql
# 
# Command to generate report => ruby registration_reminder.rb
# Output would be written to registration_reminder_emails.csv
# 
require 'rubygems'
require 'sequel'
require 'csv'


DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "mysql://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"
DEV_DB.run "SET NAMES 'utf8' COLLATE 'utf8_unicode_ci'"

student_ids_sql_statement =<<EOSQL
SELECT student_id
FROM student_class_assignments
WHERE school_year_id = 4 
AND grade_id < 12
AND student_id NOT IN (SELECT student_id FROM student_class_assignments WHERE school_year_id = 5)
ORDER BY student_id
EOSQL

emails_sql_statement =<<EOSQL
SELECT families.id, addresses.email 
FROM families, families_children, addresses 
WHERE families.id = families_children.family_id 
AND families.address_id = addresses.id 
AND families_children.child_id = ?
EOSQL


student_ids = []
DEV_DB[student_ids_sql_statement].each { |record| student_ids << record[:student_id] }

# Student id 4645 is a special case where the student is not a child of a family
student_ids.delete 4645

family_emails = {}
student_ids.each do |student_id|
  record = DEV_DB[emails_sql_statement, student_id].first
  family_emails[record[:id]] = record[:email]
end


CSV.open("registration_reminder_emails.csv", "wb") do |csv|
  csv << ["Family Id", "Family Email"]
  family_emails.each_pair do |key, value|
    csv << [key, value]
  end
end
