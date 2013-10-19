# Required dependencies:
# Ruby
# Ruby gems => sequel, mysql
# 
require 'rubygems'
require 'sequel'


DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''

DEV_DB = Sequel.connect "mysql://#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}/chineseschool_development"

sql_statement =<<EOSQL
SELECT username from users
EOSQL

records = DEV_DB[sql_statement]
puts records.count.inspect

#family = DEV_DB["SELECT id FROM families WHERE parent_one_id = ? OR parent_two_id = ?", 2321, 2321].first
#family = DEV_DB["SELECT id FROM families WHERE parent_one_id = ? OR parent_two_id = ?", 3255, 3255].first
family = DEV_DB["SELECT family_id as id FROM families_children WHERE child_id = ?", 3255].first
puts family.inspect
