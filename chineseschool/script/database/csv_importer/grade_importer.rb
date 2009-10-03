require File.expand_path(File.dirname(__FILE__) + '/csv_importer')

class GradeImporter < CsvImporter

  def initialize(csv_file)
    super
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

  def print_counter(counter)
    puts "#{counter} records imported for Grade"
  end
end
