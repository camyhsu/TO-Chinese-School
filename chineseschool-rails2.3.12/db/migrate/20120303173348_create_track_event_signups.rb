class CreateTrackEventSignups < ActiveRecord::Migration
  def self.up
    create_table :track_event_signups do |t|
      t.integer :track_event_program_id
      t.integer :student_id
      t.integer :parent_id
      t.string :group_name

      t.timestamps
    end
  end

  def self.down
    drop_table :track_event_signups
  end
end
