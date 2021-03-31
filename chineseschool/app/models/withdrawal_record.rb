class WithdrawalRecord < ActiveRecord::Base
  
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'
  belongs_to :school_year
  belongs_to :grade
  belongs_to :school_class
  belongs_to :elective_class, class_name: 'SchoolClass', foreign_key: 'elective_class_id'

  def self.find_withdraw_record_by_student_and_school_year(student, school_year)
    WithdrawalRecord.first :conditions => ["student_id = ? and school_year_id = ? ", student.id, school_year.id], :order => 'id DESC'
  end

end
