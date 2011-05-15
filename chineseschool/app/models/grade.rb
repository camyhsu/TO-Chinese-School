class Grade < ActiveRecord::Base

  belongs_to :next_grade, :class_name => 'Grade', :foreign_key => 'next_grade'

  has_many :school_classes
  
  has_many :student_class_assignments
  has_many :students, :through => :student_class_assignments

  def name
    "#{self.chinese_name}(#{self.english_name})"
  end

  def current_year_student_class_assignments
    self.student_class_assignments.all :conditions => ['school_year_id = ?', SchoolYear.current_school_year.id]
  end

  def active_school_classes
    self.school_classes.reject { |school_class| !school_class.active_in?(SchoolYear.current_school_year) }
  end
end
