class StudentStatusFlag < ActiveRecord::Base
  
  belongs_to :student, :class_name => 'Person', :foreign_key => 'student_id'
  belongs_to :school_year
  
end
