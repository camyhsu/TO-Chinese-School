class Student::RegistrationController < ApplicationController

  def display_options
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    @previous_school_year = @registration_school_year.previous_school_year
    @registration_preferences = create_registration_preferences_for_display_optioins
  end
  
  def save_registration_preferences
    # calculations here must be done in a specific order because
    # later calculations may depends on the result of earlier calculations
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    registration_preference_ids = save_registration_preferences_from_params
    # Store registration preference ids for the controller after legal consent
    session[:registration_preference_ids] = registration_preference_ids
#    @registration_pva_due_in_cents = calculate_pva_due_in_cents
#    @registration_ccca_due_in_cents = calculate_ccca_due_in_cents
#    @registration_grand_total_in_cents = calculate_grand_total_in_cents
    # store grand total in session for later verification
    #session[:registration_grand_total_in_cents] = @registration_grand_total_in_cents
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
          registration_preference.grade = age_based_grade.snap_down_to_first_active_grade @registration_school_year
          registration_preferences << registration_preference
        end
        # If age-based grade is nil, it means the student is either too young or too old - don't add to list
      else
        # Grade assignment based on previous school year
        registration_preference.previous_grade = previous_school_year_class_assignment.grade
        registration_preference.grade = registration_preference.previous_grade.next_grade.snap_down_to_first_active_grade @registration_school_year
        registration_preferences << registration_preference
      end
    end
    registration_preferences
  end
  
  def save_registration_preferences_from_params
    registration_preference_ids = []
    find_possible_students.each do |student|
      student_register_flag = params["#{student.id}_register".to_sym]
      if (!student_register_flag.nil?) and (student_register_flag == "true")
        registration_preference = find_or_create_registration_preference_for student
        registration_preference.previous_grade_id = extract_previous_grade_id_from_params student.id
        registration_preference.grade_id = extract_grade_id_from_params student.id
        registration_preference.school_class_type = params["#{student.id}_school_class_type".to_sym][:school_class_type]
        registration_preference.elective_class_id = extract_elective_class_id_from_params student.id
        if registration_preference.save
          registration_preference_ids << registration_preference.id
        end
      end
    end
    registration_preference_ids
  end

  def find_or_create_registration_preference_for(student)
    registration_preference = RegistrationPreference.first :conditions => ['school_year_id = ? AND student_id = ?', @registration_school_year.id, student.id]
    if registration_preference.nil?
      registration_preference = RegistrationPreference.new
      registration_preference.school_year = @registration_school_year
      registration_preference.student = student
    end
    registration_preference.entered_by = @user.person
    registration_preference
  end

  def extract_previous_grade_id_from_params(student_id)
    previous_grade_id = params["#{student_id}_previous_grade".to_sym]
    return nil if previous_grade_id.blank?
    previous_grade_id.to_i
  end

  def extract_grade_id_from_params(student_id)
    grade_id = params["#{student_id}_grade".to_sym]
    return nil if grade_id.blank?
    grade_id.to_i
  end

  def extract_elective_class_id_from_params(student_id)
    elective_class_hash = params["#{student_id}_elective".to_sym]
    return nil if elective_class_hash.nil?
    elective_class_id = elective_class_hash[:elective_class]
    return nil if elective_class_id.blank?
    elective_class_id.to_i
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
