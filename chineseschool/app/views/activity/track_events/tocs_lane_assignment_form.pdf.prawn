# encoding: utf-8

pdf.font "#{RAILS_ROOT}/lib/data/fonts/ArialUnicode.ttf"

@lane_assignment_blocks.each do |lane_assignment_block|
  
  pdf.font_size 12 do
    pdf.text lane_assignment_block.sample_track_event_program.name, :align => :left
    if lane_assignment_block.gender == Person::GENDER_FEMALE
      pdf.move_up 12
      if (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT) or 
          (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY)
        pdf.text 'Women', :align => :center
      else
        pdf.text 'Girls', :align => :center
      end
    elsif lane_assignment_block.gender == Person::GENDER_MALE
      pdf.move_up 12
      if (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT) or 
          (lane_assignment_block.sample_track_event_program.program_type == TrackEventProgram::PROGRAM_TYPE_PARENT_RELAY)
        pdf.text 'Men', :align => :center
      else
        pdf.text 'Boys', :align => :center
      end
    end
  end
  
  pdf.move_down 20
  
  data = lane_assignment_block.create_lane_block_data_for_pdf
  pdf.font_size 9 do
    pdf.table(data, :header => true) do |t|
      t.cells.style :width => 70, :height => 24, :align => :center
      t.row(0).style(:background_color => 'cccccc')
    end
  end
  
#  pdf.start_new_page
end

#pdf.font_size 9 do
#  pdf.number_pages "Date: #{PacificDate.tomorrow}", :at => [pdf.bounds.left, 0], :align => :left, :page_filter => :all
#  pdf.number_pages "Roster Form", :at => [pdf.bounds.left, 0], :align => :right, :page_filter => :all
#end
