class StudentStatusFlag < ActiveRecord::Base
  
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'
  belongs_to :school_year
  
  validates_presence_of :student, :school_year
  
end
