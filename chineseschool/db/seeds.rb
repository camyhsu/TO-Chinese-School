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
create_role(Role::ROLE_NAME_PRINCIPAL)
create_role(Role::ROLE_NAME_REGISTRATION_OFFICER)
create_role(Role::ROLE_NAME_ACCOUNTING_OFFICER)
create_role(Role::ROLE_NAME_INSTRUCTOR)
create_role(Role::ROLE_NAME_ROOM_PARENT)
create_role(Role::ROLE_NAME_STUDENT_PARENT)


#
# Create rights
#
Right.delete_all
grades_index = Right.create(:name => 'List Grades', :controller => 'admin/grades', :action => 'index')

school_years_index = Right.create(:name => 'List School Years', :controller => 'admin/school_years', :action => 'index')
school_years_show = Right.create(:name => 'Show School Year Details', :controller => 'admin/school_years', :action => 'show')
school_years_new = Right.create(:name => 'Edit School Year Details', :controller => 'admin/school_years', :action => 'new')
school_years_edit = Right.create(:name => 'Edit School Year Details', :controller => 'admin/school_years', :action => 'edit')

school_classes_index = Right.create(:name => 'List School Classes', :controller => 'admin/school_classes', :action => 'index')
school_classes_new = Right.create(:name => 'Create New School Class', :controller => 'admin/school_classes', :action => 'new')
school_classes_edit = Right.create(:name => 'Edit School Class', :controller => 'admin/school_classes', :action => 'edit')
school_classes_toggle_active = Right.create(:name => 'Toggle School Class Active Status', :controller => 'admin/school_classes', :action => 'toggle_active')

active_school_classes_index = Right.create(:name => 'List Active School Classes', :controller => 'registration/active_school_classes', :action => 'index')
active_school_classes_grade_class_student_count = Right.create(:name => '班級人數清單', :controller => 'registration/active_school_classes', :action => 'grade_class_student_count')
active_school_classes_elective_class_student_count = Right.create(:name => 'Elective Class 人數清單', :controller => 'registration/active_school_classes', :action => 'elective_class_student_count')

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
student_class_assignments_list_active_students_by_name = Right.create(:name => 'List Active Students By Name', :controller => 'registration/student_class_assignments', :action => 'list_active_students_by_name')
student_class_assignments_select_school_class = Right.create(:name => 'Select School Class On Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'select_school_class')
student_class_assignments_select_elective_class = Right.create(:name => 'Select Elective Class On Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'select_elective_class')
student_class_assignments_destroy = Right.create(:name => 'Remove Student From Grade On Manage Students By Grade', :controller => 'registration/student_class_assignments', :action => 'destroy')

instructor_assignments_select_school_class = Right.create(:name => 'Select School Class For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_school_class')
instructor_assignments_select_start_date = Right.create(:name => 'Select Start Date For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_start_date')
instructor_assignments_select_end_date = Right.create(:name => 'Select End Date For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_end_date')
instructor_assignments_select_role = Right.create(:name => 'Select Role For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_role')
instructor_assignments_destroy = Right.create(:name => 'Destroy Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'destroy')

report_daily_registration_summary = Right.create(:name => 'Daily Registration Summary Report', :controller => 'registration/report', :action => 'daily_registration_summary')


instruction_school_classes_show = Right.create(:name => 'Student List For One School Class', :controller => 'instruction/school_classes', :action => 'show')

student_families_add_child = Right.create(:name => 'Add Child To Family By Parent', :controller => 'student/families', :action => 'add_child')
student_families_edit_address = Right.create(:name => 'Edit Family Address By Parent', :controller => 'student/families', :action => 'edit_address')

student_people_edit = Right.create(:name => 'Edit Person Basic Data By Parent', :controller => 'student/people', :action => 'edit')
student_people_new_address = Right.create(:name => 'Create Personal Address By Parent', :controller => 'student/people', :action => 'new_address')
student_people_edit_address = Right.create(:name => 'Edit Personal Address By Parent', :controller => 'student/people', :action => 'edit_address')

student_registration_display_options = Right.create(:name => 'Display Registration Options', :controller => 'student/registration', :action => 'display_options')
student_registration_save_registration_preferences = Right.create(:name => 'Save Registration Preferences', :controller => 'student/registration', :action => 'save_registration_preferences')
student_registration_payment_entry = Right.create(:name => 'Payment Entry', :controller => 'student/registration', :action => 'payment_entry')
student_registration_remove_pending_registration_payment = Right.create(:name => 'Remove Pending Registration Payment', :controller => 'student/registration', :action => 'remove_pending_registration_payment')
student_registration_submit_payment = Right.create(:name => 'Submit Payment', :controller => 'student/registration', :action => 'submit_payment')
student_registration_payment_confirmation = Right.create(:name => 'Show Payment Confirmation', :controller => 'student/registration', :action => 'payment_confirmation')

student_transaction_history_index = Right.create(:name => 'List Transaction History', :controller => 'student/transaction_history', :action => 'index')
student_transaction_history_show = Right.create(:name => 'Show Transaction Detail', :controller => 'student/transaction_history', :action => 'show')



#
# Assign rights to Principal
#
principal = Role.find_by_name(Role::ROLE_NAME_PRINCIPAL)
principal.rights << active_school_classes_grade_class_student_count
principal.rights << active_school_classes_elective_class_student_count
principal.rights << report_daily_registration_summary


#
# Assign rights to Registration Officer
#
registration_officer = Role.find_by_name(Role::ROLE_NAME_REGISTRATION_OFFICER)
registration_officer.rights << grades_index

registration_officer.rights << school_years_index
registration_officer.rights << school_years_show
registration_officer.rights << school_years_new
registration_officer.rights << school_years_edit

registration_officer.rights << school_classes_index
registration_officer.rights << school_classes_new
registration_officer.rights << school_classes_edit
registration_officer.rights << school_classes_toggle_active

registration_officer.rights << active_school_classes_index
registration_officer.rights << active_school_classes_grade_class_student_count

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
registration_officer.rights << student_class_assignments_list_active_students_by_name
registration_officer.rights << student_class_assignments_select_school_class
registration_officer.rights << student_class_assignments_select_elective_class
registration_officer.rights << student_class_assignments_destroy

registration_officer.rights << instructor_assignments_select_school_class
registration_officer.rights << instructor_assignments_select_start_date
registration_officer.rights << instructor_assignments_select_end_date
registration_officer.rights << instructor_assignments_select_role
registration_officer.rights << instructor_assignments_destroy

registration_officer.rights << instruction_school_classes_show

registration_officer.rights << report_daily_registration_summary


#
# Assign rights to Accounting Officer
#
accounting_officer = Role.find_by_name(Role::ROLE_NAME_ACCOUNTING_OFFICER)
accounting_officer.rights << report_daily_registration_summary


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


#
# Assign rights to Student Parent
#
student_parent = Role.find_by_name(Role::ROLE_NAME_STUDENT_PARENT)
student_parent.rights << student_families_add_child
student_parent.rights << student_families_edit_address

student_parent.rights << student_people_edit
student_parent.rights << student_people_new_address
student_parent.rights << student_people_edit_address

student_parent.rights << student_registration_display_options
student_parent.rights << student_registration_save_registration_preferences
student_parent.rights << student_registration_payment_entry
student_parent.rights << student_registration_remove_pending_registration_payment
student_parent.rights << student_registration_submit_payment
student_parent.rights << student_registration_payment_confirmation

student_parent.rights << student_transaction_history_index
student_parent.rights << student_transaction_history_show
