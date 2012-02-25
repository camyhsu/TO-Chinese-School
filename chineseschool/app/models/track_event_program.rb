class TrackEventProgram < ActiveRecord::Base
  
  EVENT_TYPE_TOCS = 'TOCS'
  EVENT_TYPE_SOUTHERN_CA = 'Southern CA'
  
  PROGRAM_TYPE_STUDENT = 'Student'
  PROGRAM_TYPE_STUDENT_RELAY = 'Student Relay'
  PROGRAM_TYPE_PARENT = 'Parent'
  PROGRAM_TYPE_PARENT_RELAY = 'Parent Relay'
  
  belongs_to :school_year
  belongs_to :grade
  
end
