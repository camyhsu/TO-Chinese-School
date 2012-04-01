class TrackEventProgram < ActiveRecord::Base
  
  EVENT_TYPE_TOCS = 'TOCS'
  EVENT_TYPE_SOUTHERN_CA = 'Southern CA'
  
  PROGRAM_TYPE_STUDENT = 'Student'
  PROGRAM_TYPE_STUDENT_RELAY = 'Student Relay'
  PROGRAM_TYPE_PARENT = 'Parent'
  PROGRAM_TYPE_PARENT_RELAY = 'Parent Relay'
  
  belongs_to :school_year
  belongs_to :grade
  
  validates_presence_of :school_year, :grade, :name, :event_type, :program_type
  
  
  def self.find_by_grade(grade, school_year=SchoolYear.current_school_year)
    self.all :conditions => ['grade_id = ? AND school_year_id = ?', grade.id, school_year.id], :order => 'id ASC'
  end
  
  def self.find_tocs_programs_group_by_sort_keys(school_year=SchoolYear.current_school_year)
    tocs_programs = self.all :conditions => ['event_type = ? AND school_year_id = ?', EVENT_TYPE_TOCS, school_year.id], :order => 'sort_key ASC'
    tocs_programs_group_by_sort_keys = Hash.new { |hash, key| hash[key] = [] }
    tocs_programs.each { |tocs_program| tocs_programs_group_by_sort_keys[tocs_program.sort_key] << tocs_program }
    tocs_programs_group_by_sort_keys
  end
end
