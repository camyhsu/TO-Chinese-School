class Student::RegistrationController < ApplicationController

  def display_registration_options
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    @possible_students = find_possible_students
    @available_elective_classes = SchoolClass.find_available_elective_classes_for_registration @registration_school_year
  end
  
  def display_tuition
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    @registration_entries = extract_selected_registration_options
  end

  def display_legal
    
  end

  def payment_entry
    
  end
  
  def cancel_registration
    # TODO - remove session data about registration
    redirect_to :controller => '/home', :action => 'index'
  end

  private
  
  def find_possible_students
    possible_students = []
    @user.person.families.each do |family|
      possible_students += family.children
    end
    possible_students
  end

  def extract_selected_registration_options
    registration_entries = []
    find_possible_students.each do |student|
      student_register_flag = params["#{student.id}_register".to_sym]
      if (not student_register_flag.nil?) and (student_register_flag == "true")
        registration_entry = {}
        registration_entry[:student] = student
        next_grade_id = params["#{student.id}_next_grade".to_sym]
        unless next_grade_id.blank?
          registration_entry[:next_grade] = Grade.find_by_id next_grade_id.to_i
        end
        elective_class_id = params["#{student.id}_elective".to_sym][:elective_class]
        unless elective_class_id.blank?
          registration_entry[:elective_class] = SchoolClass.find_by_id elective_class_id.to_i
        end
        registration_entries << registration_entry
      end
    end
    registration_entries
  end
end
