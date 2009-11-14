require 'csv'

class FacultyImporter

  def initialize(data_base_dir)
    @faculty_file = "#{data_base_dir}/faculty.csv"
    @family_id_map_file = "#{data_base_dir}/family_id_map.yml"
  end

  def import
    load_files
    verify_data_integrity
    return nil # turn of final dump of data in console
  end

  def verify_data_integrity
    no_person_counter = 0
    @faculty_records.each do |old_faculty_id, faculty_record|
      chinese_name = faculty_record[1].to_s
      person_found = Person.find_by_chinese_name(chinese_name)
      if person_found.nil?
        puts "***** No person record found for => #{chinese_name}  --  old_family_id => #{faculty_record[16]}"
        no_person_counter += 1
      else
        puts "#{chinese_name} has person record, with old_family_id => #{faculty_record[16]}"
      end
    end
  end
  

  private

  def load_files
    load_faculty_file
  end

  def load_faculty_file
    @faculty_records = {}
    open(@faculty_file) do |input_file|
      CSV::Reader.parse(input_file) do |csv_record|
        @faculty_records[csv_record[0].to_s] = csv_record
      end
      puts "#{@faculty_records.size} records loaded from faculty.csv"
      puts "record for 229 => " + @faculty_records['229'].inspect
      puts "record for 236 => " + @faculty_records['236'].inspect
    end
  end

end
