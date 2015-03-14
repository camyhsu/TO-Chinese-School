class Person < ActiveRecord::Base

  GENDER_MALE = 'M'
  GENDER_FEMALE = 'F'
  AVAILABLE_NATIVE_LANGUAGE = ['Mandarin', 'English', 'Cantonese', 'Other']

  attr_accessible :english_first_name, :english_last_name, :chinese_name, :gender,
                  :birth_year, :birth_month, :native_language

  has_one :user
  belongs_to :address

  has_many :jersey_numbers

  has_many :student_class_assignments, foreign_key: 'student_id', dependent: :destroy
  has_many :instructor_assignments, foreign_key: 'instructor_id', dependent: :destroy

  has_many :registration_preferences, foreign_key: 'student_id'
  has_many :student_status_flags, foreign_key: 'student_id'

  validates :gender, :english_first_name, :english_last_name, presence: true
  validates :birth_year, presence: true, if: Proc.new { |person| person.is_a_child? }
  validates :birth_month, presence: true, if: Proc.new { |person| person.is_a_child? }

  validates :birth_year, numericality: {only_integer: true, greater_than: 1900, less_than: Time.now.year, allow_nil: true}
  validates :birth_month, numericality: {only_integer: true, greater_than: 0, less_than: 13, allow_nil: true}


  def mark_as_new_child
    @new_child = true
  end

  def name
    "#{chinese_name}(#{english_name})"
  end
  
  def english_name
    "#{english_first_name} #{english_last_name}"
  end

  def birth_info
    return '' if birth_month.blank? or birth_year.blank?
    "#{birth_month}/#{birth_year}"
  end
  
  def school_age_for(school_year)
    return nil if self.birth_year.blank? or self.birth_month.blank?
    school_age = school_year.start_year - self.birth_year
    return (school_age - 1) if school_year.age_cutoff_month <= self.birth_month
    school_age
  end

  def age_in_range_for_track_event?(grade)
    # treat it as old age if no data
    return 1 if self.birth_year.blank? or self.birth_month.blank?
    age_difference = baseline_months(SchoolYear.current_school_year.start_year, SchoolYear.current_school_year.age_cutoff_month) -
        baseline_months(self.birth_year, self.birth_month) - baseline_months(grade.school_age, 0)
    if age_difference < 1
      -1
    elsif age_difference > 18
      1
    else
      0
    end
  end

  def is_a_child?
    return true if @new_child
    return false if self.id.nil? # treated as new parent
    Person.count_by_sql("SELECT COUNT(1) FROM families_children WHERE child_id = #{self.id}") > 0
  end

  def is_a_parent_of?(child_id)
    Person.count_by_sql("SELECT COUNT(1) FROM families, families_children WHERE " +
        "(families.parent_one_id = #{self.id} OR families.parent_two_id = #{self.id}) AND " +
        "families.id = families_children.family_id AND families_children.child_id = #{child_id}") > 0
  end

  def instructor_assignments_for(school_year)
    self.instructor_assignments.all :conditions => ['school_year_id = ?', school_year.id]
  end

  def student_class_assignment_for(school_year)
    self.student_class_assignments.first :conditions => ['school_year_id = ?', school_year.id]
  end
  
  def registration_preference_for(school_year)
    self.registration_preferences.first :conditions => ['school_year_id = ?', school_year.id]
  end
  
  def student_status_flag_for(school_year)
    self.student_status_flags.first :conditions => ['school_year_id = ?', school_year.id]
  end

  def jersey_number_for(school_year)
    self.jersey_numbers.first :conditions => ['school_year_id = ?', school_year.id]
  end
  
  def families
    find_families_as_parent + find_families_as_child
  end

  def find_families_as_parent
    Family.all :conditions => ["parent_one_id = ? or parent_two_id = ?", self.id, self.id]
  end

  def find_families_as_child
    Family.all :from => 'families, families_children', :conditions => ["families.id = families_children.family_id and families_children.child_id = ?", self.id]
  end
  
  def find_parents
    parents = []
    find_families_as_child.each do |family|
      parents << family.parent_one unless family.parent_one.nil?
      parents << family.parent_two unless family.parent_two.nil?
    end
    parents
  end

  def find_children
    children = []
    find_families_as_parent.each do |family|
      children << family.children
    end
    children.flatten.compact.uniq
  end

  def personal_email_address
    if self.address
      self.address.email
    else
      family_with_email = self.families.detect do |family|
        !family.address.email.blank?
      end
      return nil if family_with_email.nil?
      family_with_email.address.email
    end
  end

  def personal_home_phone
    if self.address
      self.address.home_phone
    else
      family_with_home_phone = self.families.detect do |family|
        !family.address.home_phone.blank?
      end
      return nil if family_with_home_phone.nil?
      family_with_home_phone.address.home_phone
    end
  end

  def email_and_phone_number_correct?(email, phone_number)
    if self.address
      self.addres.email_and_phone_number_correct? email, phone_number
    else
      self.families.detect do |family|
        family.address.email_and_phone_number_correct? email, phone_number
      end
    end
  end

  def phone_number_correct?(phone_number)
    if self.address
      self.address.phone_number_correct? phone_number
    else
      self.families.detect do |family|
        family.address.phone_number_correct? phone_number
      end
    end
  end
  
  def find_completed_registration_payments_as_students
    student_fee_payments = StudentFeePayment.all :conditions => ["student_id = ?", self.id]
    registration_payments = student_fee_payments.collect do |student_fee_payment|
      if student_fee_payment.registration_payment.paid
        student_fee_payment.registration_payment
      else
        nil
      end
    end
    registration_payments.compact!
    registration_payments.sort { |a, b| b.updated_at <=> a.updated_at}
  end
  
  def find_manual_transactions_as_students
    manual_transactions = ManualTransaction.all :conditions => ["student_id = ?", self.id]
    manual_transactions.sort { |a, b| b.updated_at <=> a.updated_at}
  end
  
  def find_all_non_filler_track_event_signups_as_students(school_year=SchoolYear.current_school_year)
    TrackEventSignup.all :from => 'track_event_signups, track_event_programs', :conditions => ['track_event_signups.track_event_program_id = track_event_programs.id AND track_event_signups.student_id = ? AND track_event_programs.school_year_id = ? AND track_event_signups.filler = false', self.id, school_year.id]
  end

  def self.find_people_on_record(english_first_name, english_last_name, email, phone_number)
    people_found_by_name = self.find_all_by_english_first_name_and_english_last_name english_first_name, english_last_name
    people_found_by_name.find_all do |person|
      person.email_and_phone_number_correct? email, phone_number
    end
  end

  def create_student_class_assignment_based_on_registration_preference(school_year)
    student_status_flag = student_status_flag_for school_year
    if student_status_flag.nil?
      student_status_flag = StudentStatusFlag.new
      student_status_flag.school_year = school_year
      student_status_flag.student = self
    end
    return if student_status_flag.registered?
    student_class_assignment = student_class_assignment_for school_year
    if student_class_assignment.nil?
      student_class_assignment = StudentClassAssignment.new
      student_class_assignment.school_year = school_year
      student_class_assignment.student = self
    end
    registration_preference = registration_preference_for school_year
    student_class_assignment.grade = registration_preference.grade
    student_class_assignment.set_school_class_based_on registration_preference
    student_class_assignment.elective_class = registration_preference.elective_class
    StudentClassAssignment.transaction do
      student_class_assignment.save!
      student_status_flag.registered = true
      student_status_flag.last_status_change_date = PacificDate.today
      student_status_flag.save!
    end
  end
  
  def current_year_registration_date
    student_status_flag = student_status_flag_for SchoolYear.current_school_year
    return nil if (student_status_flag.nil? or !student_status_flag.registered?)
    student_status_flag.last_status_change_date
  end

  def create_jersey_number
    return unless self.jersey_number_for(SchoolYear.current_school_year).nil?
    JerseyNumber.create_new_number_for self
  end

  def create_parent_jersey_number
    return unless self.jersey_number_for(SchoolYear.current_school_year).nil?
    JerseyNumber.create_new_parent_number_for self
  end

  private

  def baseline_months(year, month)
    year * 12 + month
  end
end
