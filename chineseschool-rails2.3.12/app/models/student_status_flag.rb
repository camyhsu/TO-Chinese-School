class StudentStatusFlag < ActiveRecord::Base
  
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'
  belongs_to :school_year
  
  validates_presence_of :student, :school_year
  
  def self.find_all_registered_flags(school_year = SchoolYear.current_school_year)
    self.all :conditions => ["school_year_id = ? AND registered = true", school_year.id]
  end
end
