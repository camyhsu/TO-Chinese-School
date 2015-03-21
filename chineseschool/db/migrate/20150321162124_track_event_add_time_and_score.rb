class TrackEventAddTimeAndScore < ActiveRecord::Migration
  def change
    add_column :track_event_teams, :track_time, :integer
    add_column :track_event_teams, :pair_winner, :boolean
    add_column :track_event_signups, :track_time, :integer
    add_column :track_event_signups, :score, :float
  end
end
