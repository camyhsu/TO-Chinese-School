class TrackEventProgramsAddRelayTeamSize < ActiveRecord::Migration
  def self.up
    add_column :track_event_programs, :relay_team_size, :integer
    add_column :track_event_programs, :sort_key, :integer
  end

  def self.down
    remove_column :track_event_programs, :relay_team_size
    remove_column :track_event_programs, :sort_key
  end
end
