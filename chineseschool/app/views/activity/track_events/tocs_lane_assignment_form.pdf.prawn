# encoding: utf-8

pdf.font "#{RAILS_ROOT}/lib/data/fonts/ArialUnicode.ttf"

@lane_assignment_blocks.each do |lane_assignment_block|
#  pdf.font_size 9 do
#    pdf.text "#{@current_school_year.name} Thousand Oaks Chinese School Fire Drill Form", :align => :right
#  end
  
#  pdf.move_down 8
  pdf.font_size 12 do
    pdf.text lane_assignment_block.program_name, :align => :left
    pdf.move_up 12
    pdf.text lane_assignment_block.grade.name, :align => :center
    pdf.move_up 12
    if lane_assignment_block.gender == Person::GENDER_FEMALE
      pdf.text 'Girls', :align => :right
    else
      pdf.text 'Boys', :align => :right
    end
  end
  
#  pdf.text "Classroom #: #{school_class.location}", :align => :right
#  pdf.move_up 10
  
#  pdf.font_size 10 do
#    assignment_hash = school_class.current_instructor_assignments
#    assignment_hash[InstructorAssignment::ROLE_PRIMARY_INSTRUCTOR].each do |instructor|
#      pdf.text "Teacher Name: #{instructor.name} 老師"
#    end
#    assignment_hash[InstructorAssignment::ROLE_ROOM_PARENT].each do |room_parent|
#      pdf.text "Room Parent Name: #{room_parent.name}"
#    end
#  end
#  pdf.move_down 10
  
  data = lane_assignment_block.create_lane_block_data_for_pdf
  data = [ lane_assignment_block.table_header_row ]
  data << lane_assignment_block.chinese_name_row
  data << lane_assignment_block.english_name_row
  data << lane_assignment_block.school_class_name_row
  data << lane_assignment_block.jersey_number_row
  data << lane_assignment_block.empty_row
  
  pdf.font_size 9 do
    pdf.table(data, :header => true) do |t|
      t.cells.style :width => 70, :height => 24, :align => :center
      t.row(0).style(:background_color => 'cccccc')
    end
  end
  
#  pdf.move_down 14
#  pdf.text 'Teacher Name:'
#  pdf.move_down 6
#  pdf.text 'Teacher Signature:'
#  pdf.start_new_page
end

#pdf.font_size 9 do
#  pdf.number_pages "Date: #{PacificDate.tomorrow}", :at => [pdf.bounds.left, 0], :align => :left, :page_filter => :all
#  pdf.number_pages "Roster Form", :at => [pdf.bounds.left, 0], :align => :right, :page_filter => :all
#end
