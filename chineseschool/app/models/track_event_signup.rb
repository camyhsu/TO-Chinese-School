class TrackEventSignup < ActiveRecord::Base
  
  RELAY_GROUP_CHOICES = ['Team 1', 'Team 2', 'Team 3', 'Team 4']
  
  belongs_to :track_event_program
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'
  belongs_to :parent, :class_name => 'Person', :foreign_key => 'parent_id'
  
  validates_presence_of :track_event_program, :student
  
  def self.find_tocs_track_event_signups(school_year=SchoolYear.current_school_year)
    self.all :conditions => ['event_type = ? AND school_year_id = ?', TrackEventProgram::EVENT_TYPE_TOCS, school_year.id], :joins => :track_event_program
  end
end
