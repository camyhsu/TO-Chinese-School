class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :english_last_name
      t.string :english_first_name
      t.string :chinese_name
      t.string :gender
      t.integer :birth_year
      t.integer :birth_month
      t.string :native_language
      t.integer :address_id

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
