require File.expand_path(File.dirname(__FILE__) + '/csv_importer')

class SchoolYearImporter < CsvImporter

  def initialize(csv_file)
    super
  end

  def save_one(record)
    school_year = SchoolYear.new
    school_year.id = record[0]
    school_year.name = record[1]
    school_year.description = record[2]
    school_year.start_date = Date.parse record[3]
    school_year.end_date = Date.parse record[4]
    school_year.save
  end

  def print_counter(counter)
    puts "#{counter} records imported for SchoolYear"
  end
end
