class CreateTrackEventPrograms < ActiveRecord::Migration
  def self.up
    create_table :track_event_programs do |t|
      t.string :name
      t.string :description
      t.string :event_type
      t.string :program_type
      t.integer :school_year_id
      t.integer :grade_id

      t.timestamps
    end
  end

  def self.down
    drop_table :track_event_programs
  end
end
