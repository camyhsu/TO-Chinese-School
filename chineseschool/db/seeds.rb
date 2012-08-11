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
create_role(Role::ROLE_NAME_ACTIVITY_OFFICER)
create_role(Role::ROLE_NAME_INSTRUCTION_OFFICER)

create_role(Role::ROLE_NAME_INSTRUCTOR)
create_role(Role::ROLE_NAME_ROOM_PARENT)
create_role(Role::ROLE_NAME_STUDENT_PARENT)

create_role(Role::ROLE_NAME_CCCA_STAFF)


#
# Create rights
#
Right.delete_all

accounting_registration_report_payments_by_date = Right.create(:name => 'Accounting Registration Report Payments By Date', :controller => 'accounting/registration_report', :action => 'registration_payments_by_date')
accounting_manual_transactions_index = Right.create(:name => 'List Manual Transaction', :controller => 'accounting/manual_transactions', :action => 'index')
accounting_manual_transactions_show = Right.create(:name => 'Show Manual Transaction', :controller => 'accounting/manual_transactions', :action => 'show')
accounting_manual_transactions_new = Right.create(:name => 'Create Manual Transaction', :controller => 'accounting/manual_transactions', :action => 'new')

grades_index = Right.create(:name => 'List Grades', :controller => 'admin/grades', :action => 'index')

school_years_index = Right.create(:name => 'List School Years', :controller => 'admin/school_years', :action => 'index')
school_years_show = Right.create(:name => 'Show School Year Details', :controller => 'admin/school_years', :action => 'show')
school_years_new = Right.create(:name => 'Create School Year', :controller => 'admin/school_years', :action => 'new')
school_years_edit = Right.create(:name => 'Edit School Year Details', :controller => 'admin/school_years', :action => 'edit')
school_years_edit_book_charge = Right.create(:name => 'Edit School Year Book Charges', :controller => 'admin/school_years', :action => 'edit_book_charge')

school_classes_index = Right.create(:name => 'List School Classes', :controller => 'admin/school_classes', :action => 'index')
school_classes_new = Right.create(:name => 'Create New School Class', :controller => 'admin/school_classes', :action => 'new')
school_classes_edit = Right.create(:name => 'Edit School Class', :controller => 'admin/school_classes', :action => 'edit')
school_classes_toggle_active = Right.create(:name => 'Toggle School Class Active Status', :controller => 'admin/school_classes', :action => 'toggle_active')

activity_forms_fire_drill_form = Right.create(:name => 'Activity Forms Fire Drill Form', :controller => 'activity/forms', :action => 'fire_drill_form')
activity_forms_students_by_class = Right.create(:name => 'Activity Forms Students By Class', :controller => 'activity/forms', :action => 'students_by_class')
activity_forms_grade_class_information = Right.create(:name => 'Activity Forms Grade Class Information', :controller => 'activity/forms', :action => 'grade_class_information')
activity_forms_elective_class_information = Right.create(:name => 'Activity Forms Elective Class Information', :controller => 'activity/forms', :action => 'elective_class_information')

activity_track_events_index = Right.create(:name => 'Manage Track Events', :controller => 'activity/track_events', :action => 'index')
activity_track_events_sign_up = Right.create(:name => 'Sign Up Track Events', :controller => 'activity/track_events', :action => 'sign_up')
activity_track_events_printable_sign_up_form = Right.create(:name => 'View Printable Track Events Sign Up Form', :controller => 'activity/track_events', :action => 'printable_sign_up_form')
activity_track_events_select_program = Right.create(:name => 'Sign Up Student Track Event By Check Box', :controller => 'activity/track_events', :action => 'select_program')
activity_track_events_select_relay_group = Right.create(:name => 'Sign Up Student Relay Track Event By Select Relay Group', :controller => 'activity/track_events', :action => 'select_relay_group')
activity_track_events_select_parent = Right.create(:name => 'Sign Up Parent Track Event By Check Box', :controller => 'activity/track_events', :action => 'select_parent')
activity_track_events_sign_up_result = Right.create(:name => 'Sign Up Track Events Result', :controller => 'activity/track_events', :action => 'sign_up_result')
activity_track_events_tocs_lane_assignment_form = Right.create(:name => 'TOCS Track Event Lane Assignment Form', :controller => 'activity/track_events', :action => 'tocs_lane_assignment_form')
activity_track_events_tocs_track_event_data = Right.create(:name => 'TOCS Track Event Data', :controller => 'activity/track_events', :action => 'tocs_track_event_data')

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
student_class_assignments_random_assign_class = Right.create(:name => 'Randomly Assign Students To Grade Class', :controller => 'registration/student_class_assignments', :action => 'random_assign_grade_class')

instructor_assignments_select_school_class = Right.create(:name => 'Select School Class For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_school_class')
instructor_assignments_select_start_date = Right.create(:name => 'Select Start Date For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_start_date')
instructor_assignments_select_end_date = Right.create(:name => 'Select End Date For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_end_date')
instructor_assignments_select_role = Right.create(:name => 'Select Role For Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'select_role')
instructor_assignments_destroy = Right.create(:name => 'Destroy Instructor Assignment', :controller => 'registration/instructor_assignments', :action => 'destroy')

report_daily_online_registration_summary = Right.create(:name => 'Daily Online Registration Summary Report', :controller => 'registration/report', :action => 'daily_online_registration_summary')
report_registration_integrity = Right.create(:name => 'Registration Integrity Report', :controller => 'registration/report', :action => 'registration_integrity')


instruction_school_classes_show = Right.create(:name => 'Student List For One School Class', :controller => 'instruction/school_classes', :action => 'show')
instruction_school_classes_display_room_parent_selection = Right.create(:name => 'Display Room Parent Selection', :controller => 'instruction/school_classes', :action => 'display_room_parent_selection')
instruction_active_school_classes_index = Right.create(:name => 'List Active School Classes For Instruction Officer', :controller => 'instruction/active_school_classes', :action => 'index')


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
student_transaction_history_show_registration_payment = Right.create(:name => 'Show Registration Payment Detail', :controller => 'student/transaction_history', :action => 'show_registration_payment')
student_transaction_history_show_registration_payment_for_staff = Right.create(:name => 'Show Registration Payment Detail For Staff', :controller => 'student/transaction_history', :action => 'show_registration_payment_for_staff')
student_transaction_history_show_manual_transaction = Right.create(:name => 'Show Manual Transaction Detail', :controller => 'student/transaction_history', :action => 'show_manual_transaction')

ccca_report_active_family_home_phone_numbers = Right.create(:name => 'Active Family Home Phone Numbers', :controller => 'ccca/report', :action => 'active_family_home_phone_numbers')


#
# Assign rights to Principal
#
principal = Role.find_by_name(Role::ROLE_NAME_PRINCIPAL)
principal.rights << active_school_classes_grade_class_student_count
principal.rights << active_school_classes_elective_class_student_count
principal.rights << report_daily_online_registration_summary


#
# Assign rights to Registration Officer
#
registration_officer = Role.find_by_name(Role::ROLE_NAME_REGISTRATION_OFFICER)
registration_officer.rights << grades_index

registration_officer.rights << school_years_index
registration_officer.rights << school_years_show
registration_officer.rights << school_years_new
registration_officer.rights << school_years_edit
registration_officer.rights << school_years_edit_book_charge

registration_officer.rights << school_classes_index
registration_officer.rights << school_classes_new
registration_officer.rights << school_classes_edit
registration_officer.rights << school_classes_toggle_active

registration_officer.rights << active_school_classes_index
registration_officer.rights << active_school_classes_grade_class_student_count
registration_officer.rights << active_school_classes_elective_class_student_count

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
registration_officer.rights << student_class_assignments_random_assign_class

registration_officer.rights << instructor_assignments_select_school_class
registration_officer.rights << instructor_assignments_select_start_date
registration_officer.rights << instructor_assignments_select_end_date
registration_officer.rights << instructor_assignments_select_role
registration_officer.rights << instructor_assignments_destroy

registration_officer.rights << instruction_school_classes_show

registration_officer.rights << report_daily_online_registration_summary
registration_officer.rights << report_registration_integrity

registration_officer.rights << student_transaction_history_show_registration_payment_for_staff

registration_officer.rights << accounting_manual_transactions_new
registration_officer.rights << accounting_manual_transactions_show


#
# Assign rights to Accounting Officer
#
accounting_officer = Role.find_by_name(Role::ROLE_NAME_ACCOUNTING_OFFICER)
accounting_officer.rights << active_school_classes_grade_class_student_count
accounting_officer.rights << active_school_classes_elective_class_student_count
accounting_officer.rights << report_daily_online_registration_summary
accounting_officer.rights << accounting_registration_report_payments_by_date
accounting_officer.rights << student_transaction_history_show_registration_payment_for_staff

accounting_officer.rights << accounting_manual_transactions_index
accounting_officer.rights << accounting_manual_transactions_show


#
# Assign rights to Activity Officer
#
activity_officer = Role.find_by_name(Role::ROLE_NAME_ACTIVITY_OFFICER)
activity_officer.rights << activity_forms_fire_drill_form
activity_officer.rights << instruction_active_school_classes_index
activity_officer.rights << instruction_school_classes_show
activity_officer.rights << activity_forms_students_by_class
activity_officer.rights << activity_forms_grade_class_information
activity_officer.rights << activity_forms_elective_class_information
activity_officer.rights << activity_track_events_index
activity_officer.rights << activity_track_events_sign_up
activity_officer.rights << activity_track_events_printable_sign_up_form
activity_officer.rights << activity_track_events_select_program
activity_officer.rights << activity_track_events_select_relay_group
activity_officer.rights << activity_track_events_select_parent
activity_officer.rights << activity_track_events_tocs_lane_assignment_form
activity_officer.rights << activity_track_events_tocs_track_event_data


#
# Assign rights to Instruction Officer
#
instruction_officer = Role.find_by_name(Role::ROLE_NAME_INSTRUCTION_OFFICER)
instruction_officer.rights << active_school_classes_grade_class_student_count
instruction_officer.rights << active_school_classes_elective_class_student_count
instruction_officer.rights << instruction_active_school_classes_index
instruction_officer.rights << instruction_school_classes_show


#
# Assign rights to Instructor
#
instructor = Role.find_by_name(Role::ROLE_NAME_INSTRUCTOR)
instructor.rights << instruction_school_classes_show
instructor.rights << instruction_school_classes_display_room_parent_selection
instructor.rights << activity_track_events_sign_up
instructor.rights << activity_track_events_printable_sign_up_form
instructor.rights << activity_track_events_select_program
instructor.rights << activity_track_events_select_relay_group
instructor.rights << activity_track_events_select_parent
instructor.rights << activity_track_events_sign_up_result


#
# Assign rights to Room Parent
#
room_parent = Role.find_by_name(Role::ROLE_NAME_ROOM_PARENT)
room_parent.rights << instruction_school_classes_show
room_parent.rights << activity_track_events_sign_up
room_parent.rights << activity_track_events_printable_sign_up_form
room_parent.rights << activity_track_events_select_program
room_parent.rights << activity_track_events_select_relay_group
room_parent.rights << activity_track_events_select_parent
room_parent.rights << activity_track_events_sign_up_result


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
student_parent.rights << student_transaction_history_show_registration_payment
student_parent.rights << student_transaction_history_show_manual_transaction


#
# Assign rights to CCCA Staff
#
ccca_staff = Role.find_by_name(Role::ROLE_NAME_CCCA_STAFF)
ccca_staff.rights << ccca_report_active_family_home_phone_numbers
