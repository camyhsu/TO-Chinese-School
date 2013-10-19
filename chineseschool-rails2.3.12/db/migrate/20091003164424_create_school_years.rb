class CreateSchoolYears < ActiveRecord::Migration
  def self.up
    create_table :school_years do |t|
      t.string :name
      t.string :description
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end

  def self.down
    drop_table :school_years
  end
end
