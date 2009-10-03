require 'csv'

class GradeImporter

  def initialize(csv_file)
    @csv_file = csv_file
  end

  def import
    open(@csv_file) do |input_file|
      counter = 0
      CSV::Reader.parse(input_file) do |record|
        save_one record
        counter += 1
      end
      puts "#{counter} records imported"
    end
  end

  def save_one(record)
    grade = Grade.new
    grade.id = record[0]
    grade.chinese_name = record[1]
    grade.english_name = record[2]
    grade.short_name = record[3]
    grade.next_grade = record[4]
    grade.save
  end
end
