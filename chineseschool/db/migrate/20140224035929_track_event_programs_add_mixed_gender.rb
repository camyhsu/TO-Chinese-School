class TrackEventProgramsAddMixedGender < ActiveRecord::Migration
  def change
    add_column :track_event_programs, :mixed_gender, :boolean, :null => false, :default => false
  end
end
