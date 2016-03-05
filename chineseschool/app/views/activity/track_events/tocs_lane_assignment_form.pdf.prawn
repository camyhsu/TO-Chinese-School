# encoding: utf-8

prawn_document(filename: 'lane_assignment_forms.pdf') do |pdf|
  pdf.font "#{Rails.root}/lib/data/fonts/ArialUnicode.ttf"

  first_page = true
  top_of_page = false
  total_heat_count = @track_event_programs.last.find_max_heat_run_order

  @track_event_programs.each do |program|
      program.sorted_heats.each do |heat|

          if (program.group_program? || program.name.start_with?('8x50'))
              pdf.start_new_page
              top_of_page = false
          elsif top_of_page
              pdf.move_down 120
              top_of_page = false
          else
              pdf.start_new_page unless first_page
              first_page = false
              top_of_page = true
          end

          heat_marker = "#{heat.run_order} of #{total_heat_count}"

          pdf.move_down 20

          pdf.font_size 14 do
              pdf.text "#{program.sort_key}. #{program.name}", align: :left
              pdf.move_up 14
              if program.parent_division?
                  pdf.text "#{heat_marker}", align: :right
              else
                  if program.mixed_gender?
                      pdf.text "#{heat_marker}", align: :right
                  else
                      if heat.gender == Person::GENDER_FEMALE
                          pdf.text "#{heat_marker}   Girls", align: :right
                      else
                          pdf.text "#{heat_marker}   Boys", align: :right
                      end
                  end
              end
          end

          pdf.move_down 20

          data = heat.create_heat_data_for_pdf
          pdf.font_size 8 do
              if program.group_program?
                  pdf.table(data, header: true, width: 158) do |t|
                      t.cells.style width: 79, height: 45, align: :center
                      t.row(0).style(background_color: 'cccccc', height: 24)
                      t.row(1).style(height: 24)
                  end
              elsif program.relay_program?
                  if program.sparse_lane_program?
                      pdf.table(data, header: true, width: 316) do |t|
                          t.cells.style width: 79, height: 45, align: :center
                          t.row(0).style(background_color: 'cccccc', height: 24)
                          t.row(1).style(height: 24)
                      end
                  else
                      pdf.table(data, header: true, width: 553) do |t|
                          t.cells.style width: 79, height: 45, align: :center
                          t.row(0).style(background_color: 'cccccc', height: 24)
                          t.row(1).style(height: 24)
                      end
                  end
              else
                  pdf.table(data, header: true, width: 553) do |t|
                      t.cells.style width: 79, height: 24, align: :center
                      t.row(0).style(background_color: 'cccccc')
                  end
              end
          end
      end
  end

  pdf.font_size 7 do
    pdf.number_pages "Page <page> of <total>", at: [pdf.bounds.left, 0], align: :right, page_filter: :all
  end
end








