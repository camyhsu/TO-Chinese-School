require 'csv'

class CsvImporter

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
      print_counter counter
    end
  end
  
end
