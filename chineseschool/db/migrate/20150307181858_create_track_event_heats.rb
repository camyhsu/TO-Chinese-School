class CreateTrackEventHeats < ActiveRecord::Migration
  def change
    create_table :track_event_heats do |t|
      t.integer :track_event_program_id, null: false
      t.string :gender
      t.integer :run_order

      t.timestamps
    end
  end
end
