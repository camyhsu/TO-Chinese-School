# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#


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
create_role(Role::ROLE_NAME_REGISTRATION_OFFICER)
create_role(Role::ROLE_NAME_INSTRUCTOR)
create_role(Role::ROLE_NAME_ROOM_PARENT)


#
# Create rights
#
Right.delete_all
grades_index = Right.create(:name => 'List Grades', :controller => 'admin/grades', :action => 'index')

registration_school_classes_index = Right.create(:name => 'List School Classes', :controller => 'admin/school_classes', :action => 'index')
registration_school_classes_new = Right.create(:name => 'Create New School Class', :controller => 'admin/school_classes', :action => 'new')
registration_school_classes_edit = Right.create(:name => 'Edit School Class', :controller => 'admin/school_classes', :action => 'edit')
registration_school_classes_enable = Right.create(:name => 'Enable School Class', :controller => 'admin/school_classes', :action => 'enable')
registration_school_classes_disable = Right.create(:name => 'Disable School Class', :controller => 'admin/school_classes', :action => 'disable')

active_school_classes_index = Right.create(:name => 'List Active School Classes', :controller => 'registration/active_school_classes', :action => 'index')

people_index = Right.create(:name => 'List People', :controller => 'registration/people', :action => 'index')
people_show = Right.create(:name => 'Show Person Details', :controller => 'registration/people', :action => 'show')
people_edit = Right.create(:name => 'Edit Person Basic Data', :controller => 'registration/people', :action => 'edit')
people_edit_address = Right.create(:name => 'Edit Personal Address', :controller => 'registration/people', :action => 'edit_address')
people_new_address = Right.create(:name => 'Create Personal Address', :controller => 'registration/people', :action => 'new_address')
people_select_grade = Right.create(:name => 'Select Grade On Person Details', :controller => 'registration/people', :action => 'select_grade')
people_select_school_class = Right.create(:name => 'Select School Class On Person Details', :controller => 'registration/people', :action => 'select_school_class')
people_select_elective_class = Right.create(:name => 'Select Elective Class On Person Details', :controller => 'registration/people', :action => 'select_elective_class')
people_add_instructor_assignment = Right.create(:name => 'Add Instructor Assignment On Person Details', :controller => 'registration/people', :action => 'add_instructor_assignment')

families_show = Right.create(:name => 'Show Family Details', :controller => 'registration/families', :action => 'show')
families_new = Right.create(:name => 'Create New Family', :controller => 'registration/families', :action => 'new')
families_edit_address = Right.create(:name => 'Edit Family Address', :controller => 'registration/families', :action => 'edit_address')
families_add_parent = Right.create(:name => 'Add Parent To Family', :controller => 'registration/families', :action => 'add_parent')
families_add_child = Right.create(:name => 'Add Child To Family', :controller => 'registration/families', :action => 'add_child')

student_class_assignments_list_by_grade = Right.create(:name => 'Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'list_by_grade')
student_class_assignments_select_school_class = Right.create(:name => 'Select School Class On Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'select_school_class')
student_class_assignments_select_elective_class = Right.create(:name => 'Select Elective Class On Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'select_elective_class')
student_class_assignments_destroy = Right.create(:name => 'Remove Student From Grade On Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'destroy')

instructor_assignments_select_school_class = Right.create(:name => 'Select School Class For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_school_class')
instructor_assignments_select_start_date = Right.create(:name => 'Select Start Date For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_start_date')
instructor_assignments_select_end_date = Right.create(:name => 'Select End Date For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_end_date')
instructor_assignments_select_role = Right.create(:name => 'Select Role For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_role')
instructor_assignments_destroy = Right.create(:name => 'Destroy Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'destroy')


instruction_school_classes_show = Right.create(:name => 'Student List For One School Class', :controller => 'instruction/school_classes', :action => 'show')



#
# Assign rights to Registration Officer
#
registration_officer = Role.find_by_name(Role::ROLE_NAME_REGISTRATION_OFFICER)
registration_officer.rights << grades_index

registration_officer.rights << registration_school_classes_index
registration_officer.rights << registration_school_classes_new
registration_officer.rights << registration_school_classes_edit
registration_officer.rights << registration_school_classes_enable
registration_officer.rights << registration_school_classes_disable

registration_officer.rights << active_school_classes_index

registration_officer.rights << people_index
registration_officer.rights << people_show
registration_officer.rights << people_edit
registration_officer.rights << people_edit_address
registration_officer.rights << people_new_address
registration_officer.rights << people_select_grade
registration_officer.rights << people_select_school_class
registration_officer.rights << people_select_elective_class
registration_officer.rights << people_add_instructor_assignment

registration_officer.rights << families_show
registration_officer.rights << families_new
registration_officer.rights << families_edit_address
registration_officer.rights << families_add_parent
registration_officer.rights << families_add_child

registration_officer.rights << student_class_assignments_list_by_grade
registration_officer.rights << student_class_assignments_select_school_class
registration_officer.rights << student_class_assignments_select_elective_class
registration_officer.rights << student_class_assignments_destroy

registration_officer.rights << instructor_assignments_select_school_class
registration_officer.rights << instructor_assignments_select_start_date
registration_officer.rights << instructor_assignments_select_end_date
registration_officer.rights << instructor_assignments_select_role
registration_officer.rights << instructor_assignments_destroy

registration_officer.rights << instruction_school_classes_show


#
# Assign rights to Instructor
#
instructor = Role.find_by_name(Role::ROLE_NAME_INSTRUCTOR)
instructor.rights << instruction_school_classes_show


#
# Assign rights to Room Parent
#
room_parent = Role.find_by_name(Role::ROLE_NAME_ROOM_PARENT)
room_parent.rights << instruction_school_classes_show
