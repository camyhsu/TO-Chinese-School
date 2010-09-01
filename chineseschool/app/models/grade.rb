class Grade < ActiveRecord::Base

  belongs_to :next_grade, :class_name => 'Grade', :foreign_key => 'next_grade'

  has_many :school_classes
  
  has_many :student_class_assignments
  has_many :students, :through => :student_class_assignments
  
end
