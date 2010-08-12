# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
ROLE_NAME_REGISTRATION_OFFICER = 'Registration Officer'
ROLE_NAME_INSTRUCTOR = 'Instructor'


#
# Utility methods
#
def create_role(role_name)
  role_created = Role.create(:name => role_name) if !Role.exists?(:name => role_name)
  # Cleared out existing right associations if the role is not created new
  Role.find_by_name(role_name).rights.clear if role_created.nil?
end


#
# Create roles
#
create_role(ROLE_NAME_REGISTRATION_OFFICER)
create_role(ROLE_NAME_INSTRUCTOR)

#
# Create rights
#
Right.delete_all
list_grades = Right.create(:name => 'List Grades', :controller => 'admin/grades', :action => 'index')
list_school_classes = Right.create(:name => 'List School Classes', :controller => 'admin/school_classes', :action => 'index')

list_people = Right.create(:name => 'List People', :controller => 'registration/people', :action => 'index')

#
# Assign rights to Registration Officer
#
registration_officer = Role.find_by_name(ROLE_NAME_REGISTRATION_OFFICER)
registration_officer.rights << list_grades
registration_officer.rights << list_school_classes

registration_officer.rights << list_people
