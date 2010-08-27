class SchoolClass < ActiveRecord::Base

  belongs_to :grade
  belongs_to :room_parent, :class_name => 'Person', :foreign_key => 'room_parent_id'

  def instructor_assignment_history
    @instructor_assignment_history ||= InstructorAssignmentHistory.new(self.id)
  end
end
