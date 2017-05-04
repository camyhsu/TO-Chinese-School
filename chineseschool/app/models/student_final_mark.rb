class StudentFinalMark < ActiveRecord::Base
  attr_accessible :attendance_award, :progress_award, :school_class_id, :school_year_id, :spirit_award, :student_id, :top_three, :total_score

  belongs_to :school_year
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'
  belongs_to :school_class

  validates :top_three, numericality: {only_integer: true, greater_than: 0, less_than: 4, allow_nil: true}
  validates :total_score, numericality: {greater_than: 0, allow_nil: true}

end
