class CreateTrackEventTeams < ActiveRecord::Migration
  def change
    create_table :track_event_teams do |t|
      t.string :name
      t.integer :track_event_program_id, null: false
      t.string :gender

      t.timestamps
    end
  end
end
