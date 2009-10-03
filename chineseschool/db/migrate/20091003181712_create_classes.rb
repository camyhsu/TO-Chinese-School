class CreateClasses < ActiveRecord::Migration
  def self.up
    create_table :classes do |t|
      t.string :english_name
      t.string :chinese_name
      t.string :description
      t.string :location
      t.integer :max_size
      t.integer :min_age
      t.integer :max_age
      t.boolean :active, :null => false, :default => true
      t.integer :grade_id
      t.integer :room_parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :classes
  end
end
