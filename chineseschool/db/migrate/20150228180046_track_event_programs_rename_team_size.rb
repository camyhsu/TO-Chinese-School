class TrackEventProgramsRenameTeamSize < ActiveRecord::Migration
  def change
    rename_column :track_event_programs, :relay_team_size, :team_size
  end
end
