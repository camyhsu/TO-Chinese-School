class CreateStudentFinalMarks < ActiveRecord::Migration
  def change
    create_table :student_final_marks do |t|
      t.integer :school_year_id, null: false
      t.integer :school_class_id, null: false
      t.integer :student_id, null: false
      t.integer :top_three
      t.boolean :progress_award, null: false, default: false
      t.boolean :spirit_award, null: false, default: false
      t.boolean :attendance_award, null: false, default: false
      t.float :total_score

      t.timestamps
    end
  end
end
