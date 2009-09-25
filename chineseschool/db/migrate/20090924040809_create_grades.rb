class CreateGrades < ActiveRecord::Migration
  def self.up
    create_table :grades do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :short_name
      t.integer :next_grade

      t.timestamps
    end
  end

  def self.down
    drop_table :grades
  end
end
