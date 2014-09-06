# encoding: utf-8

prawn_document(filename: @filename) do |pdf|
  pdf.font "#{Rails.root}/lib/data/fonts/ArialUnicode.ttf"

  header = [ 'No', '姓名', 'First Name', 'Last Name' ]

  @sorted_school_classes.each do |school_class|
    pdf.font_size 16 do
      pdf.text "#{school_class.name} : Classroom #{school_class.location}", align: :center
    end

    pdf.move_down 10

    pdf.font_size 10 do
      instructor = school_class.current_primary_instructor
      pdf.text "Teacher Name: #{instructor.try(:name)} 老師"
    end
    pdf.move_down 10

    data = [ header ]
    @class_lists[school_class].each_with_index do |student, i|
      row = []
      row << (i + 1)
      row << student.chinese_name
      row << student.english_first_name
      row << student.english_last_name
      data << row
    end

    pdf.font_size 9 do
      pdf.table(data, header: true) do
        row(0).style(background_color: 'cccccc')
      end
    end

    pdf.start_new_page
  end

  pdf.font_size 9 do
    pdf.number_pages "Printed Date: #{PacificDate.today}", at: [pdf.bounds.left, 0], align: :left, page_filter: :all
    pdf.number_pages "TO Chinese School Student List", at: [pdf.bounds.left, 0], align: :right, page_filter: :all
  end
end
