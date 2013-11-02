class StudentClassAssignment < ActiveRecord::Base

  belongs_to :school_year
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'
  belongs_to :grade
  belongs_to :school_class
  belongs_to :elective_class, class_name: 'SchoolClass', foreign_key: 'elective_class_id'

  validates :student, :grade, :school_year, presence: true

  def set_school_class_based_on(registration_preference)
    self.school_class = self.grade.find_next_assignable_school_class registration_preference.school_class_type, self.school_year, self.student.gender
  end
end
