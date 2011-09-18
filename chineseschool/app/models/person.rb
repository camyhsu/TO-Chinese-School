class Person < ActiveRecord::Base

  GENDER_MALE = 'M'
  GENDER_FEMALE = 'F'
  AVAILABLE_NATIVE_LANGUAGE = ['Mandarin', 'English', 'Cantonese', 'Other']

  has_one :user
  belongs_to :address

  has_many :student_class_assignments, :foreign_key => 'student_id', :dependent => :destroy
  has_many :instructor_assignments, :foreign_key => 'instructor_id', :dependent => :destroy

  has_many :registration_preferences, :foreign_key => 'student_id'

  validates_presence_of :gender, :english_first_name, :english_last_name
  validates_presence_of :birth_year, :if => Proc.new { |person| person.is_a_child? }
  validates_presence_of :birth_month, :if => Proc.new { |person| person.is_a_child? }

  validates_numericality_of :birth_year, :allow_nil => true, :only_integer => true, :greater_than => 1900, :less_than => Time.now.year
  validates_numericality_of :birth_month, :allow_nil => true, :only_integer => true, :greater_than => 0, :less_than => 13


  def mark_as_new_child
    @new_child = true
  end

  def name
    "#{chinese_name}(#{english_first_name} #{english_last_name})"
  end

  def birth_info
    return '' if birth_month.blank? or birth_year.blank?
    "#{birth_month}/#{birth_year}"
  end
  
  def school_age_for(school_year)
    return nil if self.birth_year.blank? or self.birth_month.blank?
    school_age = school_year.start_date.year - self.birth_year
    return (school_age - 1) if school_year.age_cutoff_month <= self.birth_month
    school_age
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
  
  def families
    find_families_as_parent + find_families_as_child
  end

  def find_families_as_parent
    Family.all :conditions => ["parent_one_id = ? or parent_two_id = ?", self.id, self.id]
  end

  def find_families_as_child
    Family.all :from => 'families, families_children', :conditions => ["families.id = families_children.family_id and families_children.child_id = ?", self.id]
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
      return nil unless student_fee_payment.registration_payment.paid
      student_fee_payment.registration_payment
    end
    registration_payments.compact!
    registration_payments.sort { |a, b| b.updated_at <=> a.updated_at}
  end

  def self.find_people_on_record(english_first_name, english_last_name, email, phone_number)
    people_found_by_name = self.find_all_by_english_first_name_and_english_last_name english_first_name, english_last_name
    people_found_by_name.find_all do |person|
      person.email_and_phone_number_correct? email, phone_number
    end
  end

  def create_student_class_assignment_based_on_registration_preference(school_year)
    registration_preference = registration_preference_for school_year
    return if registration_preference.registration_completed?
    student_class_assignment = student_class_assignment_for school_year
    if student_class_assignment.nil?
      student_class_assignment = StudentClassAssignment.new
      student_class_assignment.school_year = school_year
      student_class_assignment.student = self
    end
    student_class_assignment.grade = registration_preference.grade
    student_class_assignment.set_school_class_based_on registration_preference
    student_class_assignment.elective_class = registration_preference.elective_class
    StudentClassAssignment.transaction do
      student_class_assignment.save!
      registration_preference.registration_completed = true
      registration_preference.save!
    end
  end
  
  def current_year_registration_time
    current_year_completed_registration = self.registration_preferences.first :conditions => ['school_year_id = ? AND registration_completed = true', SchoolYear.current_school_year.id]
    return nil if current_year_completed_registration.nil?
    current_year_completed_registration.updated_at
  end
end
