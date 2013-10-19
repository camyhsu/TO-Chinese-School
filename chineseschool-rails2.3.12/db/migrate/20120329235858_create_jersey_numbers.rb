class CreateJerseyNumbers < ActiveRecord::Migration
  def self.up
    create_table :jersey_numbers do |t|
      t.integer :person_id
      t.integer :school_year_id
      t.integer :number

      t.timestamps
    end
  end
  
  def self.down
    drop_table :jersey_numbers
  end
end
