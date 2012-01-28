class RegistrationPreference < ActiveRecord::Base
  
  belongs_to :school_year
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'
  belongs_to :entered_by, :class_name => 'Person', :foreign_key => 'entered_by_id'
  belongs_to :previous_grade, :class_name => 'Grade', :foreign_key => 'previous_grade_id'
  belongs_to :grade
  belongs_to :elective_class, :class_name => 'SchoolClass', :foreign_key => 'elective_class_id'

  validates_presence_of :school_year, :student, :entered_by

end
