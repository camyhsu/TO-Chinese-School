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
school_classes_new = Right.create(:name => 'Create New School Class', :controller => 'admin/school_classes', :action => 'new')
school_classes_edit = Right.create(:name => 'Edit School Class', :controller => 'admin/school_classes', :action => 'edit')
school_classes_enable = Right.create(:name => 'Enable School Class', :controller => 'admin/school_classes', :action => 'enable')
school_classes_disable = Right.create(:name => 'Disable School Class', :controller => 'admin/school_classes', :action => 'disable')

people_index = Right.create(:name => 'List People', :controller => 'registration/people', :action => 'index')
people_show = Right.create(:name => 'Show Person Details', :controller => 'registration/people', :action => 'show')
people_edit = Right.create(:name => 'Edit Person Basic Data', :controller => 'registration/people', :action => 'edit')
people_select_grade = Right.create(:name => 'Select Grade On Person Details', :controller => 'registration/people', :action => 'select_grade')
people_select_school_class = Right.create(:name => 'Select School Class On Person Details', :controller => 'registration/people', :action => 'select_school_class')
people_select_elective_class = Right.create(:name => 'Select Elective Class On Person Details', :controller => 'registration/people', :action => 'select_elective_class')

families_show = Right.create(:name => 'Show Family Details', :controller => 'registration/families', :action => 'show')
families_new = Right.create(:name => 'Create New Family', :controller => 'registration/families', :action => 'new')
families_add_parent = Right.create(:name => 'Add Parent To Family', :controller => 'registration/families', :action => 'add_parent')
families_add_child = Right.create(:name => 'Add Child To Family', :controller => 'registration/families', :action => 'add_child')

student_class_assignments_grade = Right.create(:name => 'Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'grade')
student_class_assignments_select_school_class = Right.create(:name => 'Select School Class On Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'select_school_class')
student_class_assignments_select_elective_class = Right.create(:name => 'Select Elective Class On Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'select_elective_class')
student_class_assignments_remove_from_grade = Right.create(:name => 'Remove Student From Grade On Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'remove_from_grade')


#
# Assign rights to Registration Officer
#
registration_officer = Role.find_by_name(ROLE_NAME_REGISTRATION_OFFICER)
registration_officer.rights << grades_index

registration_officer.rights << school_classes_index
registration_officer.rights << school_classes_new
registration_officer.rights << school_classes_edit
registration_officer.rights << school_classes_enable
registration_officer.rights << school_classes_disable

registration_officer.rights << people_index
registration_officer.rights << people_show
registration_officer.rights << people_edit
registration_officer.rights << people_select_grade
registration_officer.rights << people_select_school_class
registration_officer.rights << people_select_elective_class

registration_officer.rights << families_show
registration_officer.rights << families_new
registration_officer.rights << families_add_parent
registration_officer.rights << families_add_child

registration_officer.rights << student_class_assignments_grade
registration_officer.rights << student_class_assignments_select_school_class
registration_officer.rights << student_class_assignments_select_elective_class
registration_officer.rights << student_class_assignments_remove_from_grade
