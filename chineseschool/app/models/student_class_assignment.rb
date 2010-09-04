class StudentClassAssignment < ActiveRecord::Base

  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'
  belongs_to :grade
  belongs_to :school_class
  belongs_to :elective_class, :class_name => 'SchoolClass', :foreign_key => 'elective_class_id'

  validates_presence_of :student, :grade

end
