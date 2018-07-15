FactoryGirl.define do
  factory :student_final_mark do
    school_year_id 1
    school_class_id 1
    student_id 1
    top_three 1
    progress_award false
    spirit_award false
    attendance_award false
    total_score 1.5
  end
end
