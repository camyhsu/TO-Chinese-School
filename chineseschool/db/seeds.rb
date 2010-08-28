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
grades_index = Right.create(:name => 'List Grades', :controller => 'admin/grades', :action => 'index')

school_classes_index = Right.create(:name => 'List School Classes', :controller => 'admin/school_classes', :action => 'index')
school_classes_enable = Right.create(:name => 'Enable School Classes', :controller => 'admin/school_classes', :action => 'enable')
school_classes_disable = Right.create(:name => 'Disable School Classes', :controller => 'admin/school_classes', :action => 'disable')

people_index = Right.create(:name => 'List People', :controller => 'registration/people', :action => 'index')
people_show = Right.create(:name => 'Show Person Details', :controller => 'registration/people', :action => 'show')
people_edit = Right.create(:name => 'Edit Person Basic Data', :controller => 'registration/people', :action => 'edit')
people_find_family_for = Right.create(:name => 'Find The Family For A Person', :controller => 'registration/people', :action => 'find_families_for')

family_show = Right.create(:name => 'Show Family Details', :controller => 'registration/families', :action => 'show')
family_new = Right.create(:name => 'Create New Family', :controller => 'registration/families', :action => 'new')
family_add_parent = Right.create(:name => 'Add Parent To Family', :controller => 'registration/families', :action => 'add_parent')
family_add_child = Right.create(:name => 'Add Child To Family', :controller => 'registration/families', :action => 'add_child')

#
# Assign rights to Registration Officer
#
registration_officer = Role.find_by_name(ROLE_NAME_REGISTRATION_OFFICER)
registration_officer.rights << grades_index

registration_officer.rights << school_classes_index
registration_officer.rights << school_classes_enable
registration_officer.rights << school_classes_disable

registration_officer.rights << people_index
registration_officer.rights << people_show
registration_officer.rights << people_edit
registration_officer.rights << people_find_family_for

registration_officer.rights << family_show
registration_officer.rights << family_new
registration_officer.rights << family_add_parent
registration_officer.rights << family_add_child
