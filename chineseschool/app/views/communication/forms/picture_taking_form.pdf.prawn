# encoding: utf-8

prawn_document(filename: 'picture_taking_form.pdf') do |pdf|
  pdf.font "#{Rails.root}/lib/data/fonts/ArialUnicode.ttf"

  header = [ 'No', 'Student Name', 'Gender', 'Picture ID', 'Notes' ]

  @sorted_school_classes.each do |school_class|
    pdf.font_size 16 do
      pdf.text "#{school_class.name} : #{school_class.location}", align: :center
    end

    pdf.move_down 10

    pdf.font_size 10 do
      instructor = school_class.current_primary_instructor
      pdf.text "Teacher Name: #{instructor.name} 老師"
    end

    pdf.move_up 10
    pdf.font_size 10 do
      pdf.text "Room Parent Name: #{school_class.current_room_parent_name}", align: :right
    end

    pdf.move_down 10

    one_twenty_spaces = ''.ljust 120, ' '

    data = [ header ]
    @class_lists[school_class].each_with_index do |student, i|
      row = []
      row << (i + 1)
      row << student.name
      row << student.gender
      row << ''
      row << one_twenty_spaces
      data << row
    end

    pdf.font_size 9 do
      pdf.table(data, :header => true) do
        row(0).style(:background_color => 'cccccc')
      end
    end

    pdf.start_new_page
  end

  pdf.font_size 9 do
    pdf.number_pages "Printed Date: #{PacificDate.today}", at: [pdf.bounds.left, 0], align: :left, page_filter: :all
    pdf.number_pages "TO Chinese School Student List", at: [pdf.bounds.left, 0], align: :right, page_filter: :all
  end
end
