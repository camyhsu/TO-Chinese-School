require File.expand_path(File.dirname(__FILE__) + '/csv_importer')

class SchoolClassImporter < CsvImporter

  def initialize(csv_file)
    super
  end

  def save_one(record)
    school_class = SchoolClass.new
    school_class.english_name = record[0]
    school_class.chinese_name = record[1]
    school_class.description = record[2]
    school_class.location = record[3]
    school_class.max_size = record[4].to_i
    school_class.min_age = record[5].to_i
    school_class.max_age = record[6].to_i
    school_class.active = (record[7] == 'true')
    school_class.grade_id = record[8].to_i unless record[8].nil?
    school_class.save
  end

  def print_counter(counter)
    puts "#{counter} records imported for School Class"
  end
end
