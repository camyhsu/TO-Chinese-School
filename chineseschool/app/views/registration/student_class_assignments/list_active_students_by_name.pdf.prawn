# encoding: utf-8

pdf.font "#{RAILS_ROOT}/lib/data/fonts/ArialUnicode.ttf"

header = [ 'Last Name', 'First Name', '姓名', '班級', '教室', '第三堂選修課' ]

data = [ header ]
@active_student_class_assignments.each do |student_class_assignment|
  row = []
  row << student_class_assignment.student.english_last_name
  row << student_class_assignment.student.english_first_name
  row << student_class_assignment.student.chinese_name
  row << student_class_assignment.school_class.short_name
  row << student_class_assignment.school_class.location
  if student_class_assignment.elective_class.nil?
    row << ''
  else
    row << "#{student_class_assignment.elective_class.location}  #{student_class_assignment.elective_class.chinese_name}"
  end
  puts row.inspect
  data << row
end

pdf.table(data, :header => true) do
  row(0).style(:background_color => 'cccccc')
end

pdf.number_pages "#{Date.today}   Total Student Count: #{@active_student_class_assignments.size}", [ pdf.bounds.left, 0 ]
pdf.number_pages "#{@current_school_year.name} 學年度       Page <page>/<total>", [ pdf.bounds.right - 250, 0 ]
