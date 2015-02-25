class TrackEventSignupsAddTrackEventTeamId < ActiveRecord::Migration
  def change
    add_column :track_event_signups, :track_event_team_id, :integer
  end
end
