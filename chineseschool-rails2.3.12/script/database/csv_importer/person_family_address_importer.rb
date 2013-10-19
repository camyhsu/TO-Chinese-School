require 'csv'

class PersonFamilyAddressImporter
  
  def initialize(data_base_dir)
    @family_file = "#{data_base_dir}/family.csv"
    @student_file = "#{data_base_dir}/student.csv"
  end


  def import
    load_files
    verify_data_integrity
    save_new_family_records
    save_new_student_records
  end

  
  private

  def load_files
    load_family_file
    load_student_file
  end
  
  def verify_data_integrity
    collect_all_people
    check_name_duplication
    check_all_students_have_family
    nil # to kill temporary output
  end

  def save_new_family_records
    puts 'Saving New Family Records'
    family_id_map = {}
    @old_id_to_new_family_map = {}
    @family_records.each do |old_family_id, family_record|
      family = Family.new
      family.parent_one = family_record[:father]
      family.parent_two = family_record[:mother]
      family.address = family_record[:address]
      family.save!
      family_id_map[old_family_id] = family.id
      @old_id_to_new_family_map[old_family_id] = family
    end
    open('family_id_map.yml', 'w') {|f| YAML.dump(family_id_map, f) }
    puts 'New Family Records Saved'
  end

  def save_new_student_records
    puts 'Saving New Student Records'
    student_id_map = {}
    @student_records.each do |old_student_id, student_record|
      student = student_record[:person]
      family = @old_id_to_new_family_map[student_record[:old_family_id]]
      family.children << student
      family.save!
      student_id_map[old_student_id] = student.id
    end
    open('student_id_map.yml', 'w') {|f| YAML.dump(student_id_map, f) }
    puts 'New Student Records Saved'
  end


  # family_records is a hash of old_family_id to family_record
  # family_record is a hash of :father, :mother, :address
  def load_family_file
    @family_records = {}
    open(@family_file) do |input_file|
      CSV::Reader.parse(input_file) do |csv_record|
        @family_records[csv_record[0].to_s] = create_family_record(csv_record)
      end
      puts "#{@family_records.size} records loaded from family.csv"
      puts "record for 71601 => " + @family_records['71601'].inspect
      puts "record for 72531 => " + @family_records['72531'].inspect
    end
  end

  def create_family_record(csv_record)
    family_record = {}
    family_record[:father] = create_father_person(csv_record)
    family_record[:mother] = create_mother_person(csv_record)
    family_record[:address] = create_address(csv_record)
    family_record
  end

  def create_father_person(csv_record)
    father_person = Person.new
    father_person.english_last_name = csv_record[1].to_s
    father_person.english_first_name = csv_record[2].to_s
    father_person.chinese_name = csv_record[3].to_s
    father_person.gender = 'M'
    father_person.native_language = csv_record[6].to_s
    return nil if father_person.english_first_name.empty? and father_person.chinese_name.empty?
    father_person
  end

  def create_mother_person(csv_record)
    mother_person = Person.new
    mother_person.english_last_name = csv_record[1].to_s
    mother_person.english_first_name = csv_record[4].to_s
    mother_person.chinese_name = csv_record[5].to_s
    mother_person.gender = 'F'
    mother_person.native_language = csv_record[7].to_s
    return nil if mother_person.english_first_name.empty? and mother_person.chinese_name.empty?
    mother_person
  end

  def create_address(csv_record)
    address = Address.new
    address.street = csv_record[8].to_s
    address.city = csv_record[9].to_s
    address.state = csv_record[10].to_s
    address.zipcode = csv_record[11].to_s.chomp('-')
    address.home_phone = csv_record[12].to_s
    address.cell_phone = csv_record[13].to_s
    address.email = csv_record[15].to_s
    puts "No street in address for old_family_id => #{csv_record[0]}" if address.street.empty?
    address
  end

  
  # student_records is a hash of old_student_id to student_record
  # student_record is a hash of two items, :person and :old_family_id
  def load_student_file
    @student_records = {}
    open(@student_file) do |input_file|
      CSV::Reader.parse(input_file) do |csv_record|
        @student_records[csv_record[0].to_s] = create_student_record(csv_record)
      end
      puts "#{@student_records.size} records loaded from student.csv"
      puts "record for 716012 => " + @student_records['716012'].inspect
      puts "record for 725311 => " + @student_records['725311'].inspect
    end
  end

  def create_student_record(csv_record)
    student_record = {}
    student_record[:person] = create_student_person(csv_record)
    student_record[:old_family_id] = csv_record[7].to_s
    student_record
  end
  
  def create_student_person(csv_record)
    student_person = Person.new
    student_person.english_last_name = csv_record[2].to_s
    student_person.english_first_name = csv_record[3].to_s
    student_person.chinese_name = csv_record[1].to_s
    student_person.gender = csv_record[4].to_s
    student_person.birth_year = csv_record[6].to_i
    student_person.birth_month = csv_record[5].to_i
    return nil if student_person.english_last_name.empty? and student_person.english_first_name.empty? and student_person.chinese_name.empty?
    student_person
  end
  
  
  def collect_all_people
    @all_people = []
    nil_people_counter = 0
    @family_records.each do |old_family_id, family_record|
      if family_record[:father].nil?
        puts "Nil father for old_family_id => #{old_family_id}"
        nil_people_counter += 1
      else
        @all_people << family_record[:father]
      end
      if family_record[:mother].nil?
        puts "Nil mother for old_family_id => #{old_family_id}"
        nil_people_counter += 1
      else
        @all_people << family_record[:mother]
      end
    end
    @student_records.each do |student_id, student_record|
      if student_record[:person].nil?
        puts "Nil student for student_id => #{student_id}"
        nil_people_counter += 1
      else
        @all_people << student_record[:person]
      end
    end
    puts "#{@all_people.size} people collected"
    puts "#{nil_people_counter} nil people in csv"
  end

  def check_name_duplication
    puts "checking name duplication"
    people_array = Array.new(@all_people)
    while person_under_check = people_array.pop
      people_array.each do |person|
        if person.chinese_name == person_under_check.chinese_name and 
            person.english_last_name == person_under_check.english_last_name and 
            person.english_first_name == person_under_check.english_first_name
          puts "Name duplication found: #{person.english_last_name} #{person.english_first_name} #{person.chinese_name}"
        end
      end
    end
  end

  def check_all_students_have_family
    puts "checking that all students have family"
    @student_records.each do |student_id, student_record|
      puts "#{student_id} has no family" if @family_records[student_record[:old_family_id]].nil?
    end
  end
end
