class CreateWithdrawalRecords < ActiveRecord::Migration
  def self.up
    create_table :withdrawal_records do |t|
      t.integer :student_id
      t.integer :school_year_id
      t.integer  :grade_id
      t.integer  :school_class_id
      t.integer  :elective_class_id
      t.datetime :registration_time
      t.datetime :withdrawal_time

      t.timestamps
    end
  end

  def self.down
    drop_table :withdrawal_records
  end
end
