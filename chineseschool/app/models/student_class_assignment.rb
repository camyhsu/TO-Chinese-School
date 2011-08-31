class StudentClassAssignment < ActiveRecord::Base

  belongs_to :school_year
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'
  belongs_to :grade
  belongs_to :school_class
  belongs_to :elective_class, :class_name => 'SchoolClass', :foreign_key => 'elective_class_id'

  validates_presence_of :student, :grade

  def set_school_class_based_on(registration_preference)
    if RegistrationPreference::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION == registration_preference.school_class_type
      self.school_class = self.grade.find_english_instruction_school_class
    elsif RegistrationPreference::SCHOOL_CLASS_TYPE_TRADITIONAL == registration_preference.school_class_type
      self.school_class = self.grade.find_traditional_school_class
    else
      self.school_class = nil
    end
  end
end
