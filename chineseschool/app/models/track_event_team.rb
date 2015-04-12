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

  def team_age
    # Current implementation agreement is that team age is determined by the team name
    # For new we grab the first digital string in name, which tends to be the starting age
    # This would not be a problem in heat arrangement as long as age groups are not overlapping
    # The potential issue with grabbing the second digital string in name is that it may not exist,
    # particularly for the 12 & over teams
    self.name.match(/^\d+/)[0].to_i
  end

  def save_score(score)
    self.track_event_signups.each do |signup|
      signup.score = score
      signup.save
    end
  end
end
