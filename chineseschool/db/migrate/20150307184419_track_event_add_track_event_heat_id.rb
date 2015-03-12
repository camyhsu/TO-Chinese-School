class TrackEventAddTrackEventHeatId < ActiveRecord::Migration
  def change
    add_column :track_event_teams, :track_event_heat_id, :integer
    add_column :track_event_signups, :track_event_heat_id, :integer
  end
end
