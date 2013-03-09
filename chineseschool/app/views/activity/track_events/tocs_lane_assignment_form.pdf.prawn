# encoding: utf-8

pdf.font "#{RAILS_ROOT}/lib/data/fonts/ArialUnicode.ttf"

top_of_page = true

@lane_assignment_blocks.each do |lane_assignment_block|
  
  pdf.move_down 20
  
  pdf.font_size 14 do
    pdf.text "#{lane_assignment_block.sample_track_event_program.sort_key}. #{lane_assignment_block.sample_track_event_program.name}", :align => :left
    pdf.move_up 14
    if lane_assignment_block.gender == Person::GENDER_FEMALE
      if (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT) or 
          (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY)
        pdf.text 'Women', :align => :right
      else
        pdf.text 'Girls', :align => :right
      end
    elsif lane_assignment_block.gender == Person::GENDER_MALE
      if (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT) or 
          (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY)
        pdf.text 'Men', :align => :right
      else
        pdf.text 'Boys', :align => :right
      end
    end
  end
  
  pdf.move_down 20
  
  data = lane_assignment_block.create_lane_block_data_for_pdf
  pdf.font_size 8 do
    pdf.table(data, :header => true, :width => 553) do |t|
      t.cells.style :width => 79, :height => 24, :align => :center
      t.row(0).style(:background_color => 'cccccc')
    end
  end
  
  if lane_assignment_block.sample_track_event_program.name.start_with? 'Tug'
    pdf.start_new_page
    top_of_page = true
  elsif top_of_page
    pdf.move_down 80
    top_of_page = false
  else
    pdf.start_new_page
    top_of_page = true
  end
end


pdf.font_size 7 do
  pdf.number_pages "Page <page> of <total>", :at => [pdf.bounds.left, 0], :align => :right, :page_filter => :all
end
