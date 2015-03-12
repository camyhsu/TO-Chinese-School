class TrackEventHeat < ActiveRecord::Base

  LANE_COUNT = 7

  attr_accessible :track_event_program

  belongs_to :track_event_program
  has_many :track_event_signups, dependent: :nullify
  has_many :track_event_teams, dependent: :nullify

  validates :track_event_program, presence: true

  def full?
    (track_event_signups.size >= LANE_COUNT) || (track_event_teams.size >= LANE_COUNT)
  end

  def max_student_school_age
    max_student_school_age = 1
    self.track_event_signups.each do |signup|
      school_age = signup.student.school_age_for(SchoolYear.current_school_year)
      max_student_school_age = school_age if school_age > max_student_school_age
    end
    max_student_school_age
  end
end
