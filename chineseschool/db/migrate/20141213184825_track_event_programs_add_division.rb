class TrackEventProgramsAddDivision < ActiveRecord::Migration
  def change
    add_column :track_event_programs, :division, :string
  end
end
