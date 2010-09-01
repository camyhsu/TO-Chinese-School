class SchoolClass < ActiveRecord::Base
  
  belongs_to :grade
  belongs_to :room_parent, :class_name => 'Person', :foreign_key => 'room_parent_id'

  # next two lines are used for regular class assignments, not elective class assignments
  has_many :student_class_assignments
  has_many :students, :through => :student_class_assignments

  validates_presence_of :english_name, :chinese_name

  validates_numericality_of :max_size, :only_integer => true, :greater_than => 0, :allow_blank => true
  validates_numericality_of :min_age, :only_integer => true, :greater_than => 0, :allow_blank => true
  validates_numericality_of :max_age, :only_integer => true, :greater_than => 0, :allow_blank => true

  
  def instructor_assignment_history
    @instructor_assignment_history ||= InstructorAssignmentHistory.new(self.id)
  end
end
