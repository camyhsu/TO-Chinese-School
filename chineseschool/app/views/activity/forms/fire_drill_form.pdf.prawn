# encoding: utf-8

pdf.font "#{RAILS_ROOT}/lib/data/fonts/ArialUnicode.ttf"

header = [ 'No', '姓名', 'First Name', 'Last Name', '當日出席/class check-in', '參與演習/event check-in' ]

@sorted_school_classes.each do |school_class|
  pdf.font_size 9 do
    pdf.text "#{@current_school_year.name} Thousand Oaks Chinese School Fire Drill Form", :align => :right
  end
  
  pdf.move_down 8
  pdf.font_size 16 do
    pdf.text school_class.name, :align => :center
  end
  
  pdf.text "Classroom #: #{school_class.location}", :align => :right
  pdf.move_up 10
  
  pdf.font_size 10 do
    assignment_hash = school_class.current_instructor_assignments
    assignment_hash[InstructorAssignment::ROLE_PRIMARY_INSTRUCTOR].each do |instructor|
      pdf.text "Teacher Name: #{instructor.name} 老師"
    end
    assignment_hash[InstructorAssignment::ROLE_ROOM_PARENT].each do |room_parent|
      pdf.text "Room Parent Name: #{room_parent.name}"
    end
  end
  pdf.move_down 10
  
  data = [ header ]
  @class_lists[school_class].each_with_index do |student, i|
    row = []
    row << i
    row << student.chinese_name
    row << student.english_first_name
    row << student.english_last_name
    row << ''
    row << ''
    data << row
  end
  pdf.font_size 9 do
    pdf.table(data, :header => true) do
      row(0).style(:background_color => 'cccccc')
    end
  end
  
  pdf.move_down 14
  pdf.text 'Teacher Name:'
  pdf.move_down 6
  pdf.text 'Teacher Signature:'
  pdf.start_new_page
end

pdf.font_size 9 do
  pdf.number_pages "Date: #{PacificDate.tomorrow}", :at => [pdf.bounds.left, 0], :align => :left, :page_filter => :all
  pdf.number_pages "Roster Form", :at => [pdf.bounds.left, 0], :align => :right, :page_filter => :all
end
