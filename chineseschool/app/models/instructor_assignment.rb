class InstructorAssignment < ActiveRecord::Base

  ROLES = ['Primary Instructor', 'Room Parent', 'Secondary Instructor', 'Teaching Assistant']
  
  belongs_to :school_year
  belongs_to :school_class
  
  belongs_to :instructor, :class_name => 'Person', :foreign_key => 'instructor_id'

  validates_presence_of :school_year, :school_class, :instructor


  def start_date_string
    self.start_date.try(:to_date)
  end

  def end_date_string
    self.end_date.try(:to_date)
  end
end
