class StudentStatusFlag < ActiveRecord::Base
  
  belongs_to :student, class_name: 'Person', foreign_key: 'student_id'
  belongs_to :school_year
  
  validates :student, :school_year, presence: true
  
  def self.find_all_registered_flags(school_year = SchoolYear.current_school_year)
    self.all conditions: ["school_year_id = ? AND registered = true", school_year.id]
  end

  def self.find_registration_in_date_range(start_date, end_date, school_year = SchoolYear.current_school_year)
    self.all conditions: ["school_year_id = ? AND registered = true AND last_status_change_date >= ? AND last_status_change_date <= ?", school_year.id, start_date, end_date]
  end
end
