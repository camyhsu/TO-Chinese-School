class InstructorAssignment < ActiveRecord::Base

  belongs_to :school_year
  belongs_to :school_class
  
  belongs_to :instructor, :class_name => 'Person', :foreign_key => 'instructor_id'

  validates_presence_of :school_year, :school_class, :instructor
  
end
