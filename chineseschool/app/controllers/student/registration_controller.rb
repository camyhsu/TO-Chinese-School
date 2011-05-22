class Student::RegistrationController < ApplicationController

  def display_options
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    @registration_preferences = create_registration_preferences_for_display_optioins
    @available_elective_classes = SchoolClass.find_available_elective_classes_for_registration @registration_school_year
  end
  
  def save_registration_preferences
    # calculations here must be done in a specific order because
    # later calculations may depends on the result of earlier calculations
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    @registration_entries = extract_selected_registration_options
    @registration_pva_due_in_cents = calculate_pva_due_in_cents
    @registration_ccca_due_in_cents = calculate_ccca_due_in_cents
    @registration_grand_total_in_cents = calculate_grand_total_in_cents
    # store grand total in session for later verification
    session[:registration_grand_total_in_cents] = @registration_grand_total_in_cents
  end

  def display_legal
    
  end

  def payment_entry
    
  end
  
  def cancel_registration
    # TODO - remove session data about registration
    session[:registration_grand_total_in_cents] = nil
    redirect_to :controller => '/home', :action => 'index'
  end

  private

  def create_registration_preferences_for_display_optioins
    # Registration preferences created here are not saved - only used to help rendering display options view
    registration_preferences = []
    find_possible_students.each do |student|
      registration_preference = RegistrationPreference.new
      registration_preference.student = student
      previous_school_year_class_assignment = student.student_class_assignment_for @registration_school_year.previous_school_year
      if previous_school_year_class_assignment.nil?
        # No class assignment in the previous school year - go for age-based grade assignment
        age_based_grade = Grade.find_by_school_age(student.school_age_for(@registration_school_year))
        unless age_based_grade.nil?
          registration_preference.grade = age_based_grade
          registration_preferences << registration_preference
        end
        # If age-based grade is nil, it means the student is either too young or too old - don't add to list
      else
        # Grade assignment based on previous school year
        registration_preference.previous_grade = previous_school_year_class_assignment.grade
        registration_preference.grade = registration_preference.previous_grade.next_grade
        registration_preferences << registration_preference
      end
    end
    registration_preferences
  end
  
  def extract_selected_registration_options
    registration_entries = []
    find_possible_students.each do |student|
      student_register_flag = params["#{student.id}_register".to_sym]
      if (not student_register_flag.nil?) and (student_register_flag == "true")
#        registration_preference = RegistrationPreference.new
#        registration_preference.school_year = @registration_school_year
#        registration_preference.student = student
#        registration_preference.entered_by = @user.person
        registration_entry = {}
        registration_entry[:student] = student
        registration_entry[:next_grade] = extract_next_grade_from_params student.id
        registration_entry[:elective_class] = extract_elective_class_from_params student.id
        registration_entry[:tuition_in_cents] = calculate_tuition_in_cents registration_entries.size
        registration_entries << registration_entry
      end
    end
    registration_entries
  end

  def extract_next_grade_from_params(student_id)
    next_grade_id = params["#{student_id}_next_grade".to_sym]
    return nil if next_grade_id.blank?
    Grade.find_by_id next_grade_id.to_i
  end

  def extract_elective_class_from_params(student_id)
    elective_class_hash = params["#{student_id}_elective".to_sym]
    return nil if elective_class_hash.nil?
    elective_class_id = elective_class_hash[:elective_class]
    return nil if elective_class_id.blank?
    SchoolClass.find_by_id elective_class_id.to_i
  end

  def calculate_tuition_in_cents(existing_registration_count)
    # 3rd student and beyond from the same family gets fixed amount discount on tuition
    # TODO - pre-K discount
    # TODO - pre-registraiton tuition
    if existing_registration_count < 2
      @registration_school_year.tuition_in_cents
    else
      @registration_school_year.tuition_in_cents #- discount
    end
  end

  def calculate_pva_due_in_cents
    # PVA membership due is up to 2 parents per family
    if @registration_entries.size < 2
      @registration_school_year.pva_membership_due_in_cents
    else
      @registration_school_year.pva_membership_due_in_cents * 2
    end
  end

  def calculate_ccca_due_in_cents
    return 0 if @user.person.families.detect { |family| family.ccca_lifetime_member? }
    @registration_school_year.ccca_membership_due_in_cents
  end

  def calculate_grand_total_in_cents
    grand_total_in_cents = 0
    grand_total_in_cents += @registration_school_year.registration_fee_in_cents * @registration_entries.size
    @registration_entries.each { |registration_entry| grand_total_in_cents += registration_entry[:tuition_in_cents] }
    grand_total_in_cents += @registration_school_year.book_charge_in_cents * @registration_entries.size
    grand_total_in_cents += @registration_pva_due_in_cents
    grand_total_in_cents += @registration_ccca_due_in_cents
    grand_total_in_cents
  end
end
