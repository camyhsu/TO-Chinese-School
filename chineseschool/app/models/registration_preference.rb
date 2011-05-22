class RegistrationPreference < ActiveRecord::Base
  
  SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION = 'SE'
  SCHOOL_CLASS_TYPE_SIMPLIFIED = 'S'
  SCHOOL_CLASS_TYPE_TRADITIONAL = 'T'

  belongs_to :school_year
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'
  belongs_to :entered_by, :class_name => 'Person', :foreign_key => 'entered_by_id'
  belongs_to :previous_grade, :class_name => 'Grade', :foreign_key => 'previous_grade_id'
  belongs_to :grade
  belongs_to :elective_class, :class_name => 'SchoolClass', :foreign_key => 'elective_class_id'

  validates_presence_of :school_year, :student, :entered_by

  def find_available_school_class_types
    available_school_class_types = []
    available_school_class_types << SCHOOL_CLASS_TYPE_SIMPLIFIED
    available_school_class_types << SCHOOL_CLASS_TYPE_TRADITIONAL
    if ('K' == self.grade.short_name) or ('1' == self.grade.short_name) or ('2' == self.grade.short_name)
      available_school_class_types << SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION
    end
    available_school_class_types
  end
end
