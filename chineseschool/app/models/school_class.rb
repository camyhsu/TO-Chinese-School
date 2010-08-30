class SchoolClass < ActiveRecord::Base
  
  belongs_to :grade
  belongs_to :room_parent, :class_name => 'Person', :foreign_key => 'room_parent_id'

  validates_presence_of :english_name, :chinese_name

  validates_numericality_of :max_size, :only_integer => true, :greater_than => 0, :allow_blank => true
  validates_numericality_of :min_age, :only_integer => true, :greater_than => 0, :allow_blank => true
  validates_numericality_of :max_age, :only_integer => true, :greater_than => 0, :allow_blank => true

  
  def instructor_assignment_history
    @instructor_assignment_history ||= InstructorAssignmentHistory.new(self.id)
  end
end
