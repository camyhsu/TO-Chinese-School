class Student::RegistrationController < ApplicationController

  def display_registration_options
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    @possible_students = find_possible_students
    @available_elective_classes = SchoolClass.find_available_elective_classes_for_registration @registration_school_year
  end
  
  def save_registration_preference
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
  
  def extract_selected_registration_options
    registration_entries = []
    find_possible_students.each do |student|
      student_register_flag = params["#{student.id}_register".to_sym]
      if (not student_register_flag.nil?) and (student_register_flag == "true")
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
