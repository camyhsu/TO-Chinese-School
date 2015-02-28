class TrackEventAddFillerFlags < ActiveRecord::Migration
  def change
    add_column :track_event_teams, :filler, :boolean, null: false, default: false
    add_column :track_event_signups, :filler, :boolean, null: false, default: false
  end
end
