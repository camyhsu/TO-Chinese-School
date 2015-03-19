class TrackEventTeam < ActiveRecord::Base

  belongs_to :track_event_program
  has_many :track_event_signups, dependent: :nullify

  validates :name, :track_event_program, presence: true

  def filler_signups
    self.track_event_signups.select { |signup| signup.filler? }
  end

  def find_runner_identifier(i)
    signup = self.track_event_signups.sort[i]
    return '' if signup.nil?
    runner = signup.participant
    "#{runner.jersey_number_for(SchoolYear.current_school_year).jersey_number}\n#{runner.chinese_name}\n#{runner.english_name}"
  end
end
