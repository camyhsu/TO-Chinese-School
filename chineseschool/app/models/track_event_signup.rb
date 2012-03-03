class TrackEventSignup < ActiveRecord::Base
  
  belongs_to :track_event_program
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'
  belongs_to :parent, :class_name => 'Person', :foreign_key => 'parent_id'
  
  validates_presence_of :track_event_program, :student
end
