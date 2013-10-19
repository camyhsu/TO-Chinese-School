require 'csv'

class FacultyImporter

  def initialize(data_base_dir)
    @faculty_file = "#{data_base_dir}/faculty.csv"
    @family_id_map_file = "#{data_base_dir}/family_id_map.yml"
  end

  def import
    load_files
    @faculty_records.each do |old_faculty_id, faculty_record|
      process_one_record old_faculty_id, faculty_record
    end
    return nil # turn off final dump of data in console
  end
  

  private

  def load_files
    load_faculty_file
    @family_id_map = open(@family_id_map_file) { |f| YAML.load(f) }
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

  def process_one_record(old_faculty_id, faculty_record)
    # find match by chinese name
    #
  end
  
  def verify_data_integrity
    no_person_counter = 0
    @faculty_records.each do |old_faculty_id, faculty_record|
      chinese_name = faculty_record[1].to_s
      old_family_id = faculty_record[16].to_s
      new_family_id = @family_id_map[old_family_id]
      person_found = Person.find_by_chinese_name(chinese_name)
      if person_found.nil?
        puts "***** No person record found for => #{chinese_name}"
        no_person_counter += 1
      else
        puts "#{chinese_name} has person record"
        match_csv_record_with person_found, faculty_record, new_family_id
      end
      
      puts "old_family_id => #{old_family_id}, new_family_id => #{new_family_id}"
    end
    puts "#{no_person_counter} records have no person in database"
  end

  def match_csv_record_with(person_found, faculty_record, new_family_id)
    puts "***** English first name does not match => person: #{person_found.english_first_name} record: #{faculty_record[2].to_s}" unless person_found.english_first_name == faculty_record[2].to_s
    puts "***** English last name does not match => person: #{person_found.english_last_name} record: #{faculty_record[3].to_s}" unless person_found.english_last_name == faculty_record[3].to_s
    #puts "Family ids match => #{person_found.family.id}" if person_found.family.id == new_family_id
  end
end
