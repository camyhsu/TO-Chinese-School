class StaffAssignment < ActiveRecord::Base

  attr_accessible :end_date, :person_id, :role, :school_year_id, :start_date

  belongs_to :school_year
  belongs_to :person

  validates :school_year, :person, :start_date, :end_date, presence: true

end
