class TrackEventTeam < ActiveRecord::Base
  attr_accessible :name

  belongs_to :track_event_program
  has_many :track_event_signups, dependent: :nullify

  validates :name, :track_event_program, presence: true

  def filler_signups
    self.track_event_signups.select { |signup| signup.filler? }
  end

end
