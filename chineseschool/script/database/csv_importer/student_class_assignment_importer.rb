require 'csv'

class StudentClassAssignmentImporter

  def initialize(data_base_dir)
    @old_student_record_file = "#{data_base_dir}/school_record_2009-2010.csv"
    @student_id_map_file = "#{data_base_dir}/student_id_map.yml"
  end

  def import
    load_files
    @old_student_records.each do |old_student_id, student_record|
      process_one_record old_student_id, student_record
    end
    return nil # turn off final dump of data in console
  end

  private

  def load_files
    load_old_student_record_file
    @student_id_map = open(@student_id_map_file) { |f| YAML.load(f) }
  end

  def load_old_student_record_file
    @old_student_records = {}
    open(@old_student_record_file) do |input_file|
      CSV::Reader.parse(input_file) do |csv_record|
        @old_student_records[csv_record[0].to_s] = csv_record
      end
      puts "#{@old_student_records.size} records loaded from school_record_2009-2010.csv"
    end
  end

  def process_one_record(old_student_id, student_record)
    student = Person.find_by_id @student_id_map[old_student_id].to_i
    if student.nil?
      puts "Could not find student for old id #{old_student_id}"
      return
    end
    previous_grade = Grade.find_by_id student_record[2].to_i
    if previous_grade.nil?
      puts "Student #{student.id} #{student.chinese_name} (#{old_student_id}) does not have previous grade"
      return
    end
    new_grade = previous_grade.next_grade
    if new_grade.nil?
      puts "Student #{student.id} #{student.chinese_name} (#{old_student_id}) does not have new grade"
      return
    end

    student_class_assignment = StudentClassAssignment.new
    student_class_assignment.student = student
    student_class_assignment.grade = new_grade
    
    school_class = find_school_class new_grade, student_record[3]
    if school_class.nil?
      puts "Student #{student.id} #{student.chinese_name} (#{old_student_id}) does not have matching school class - skip class assignment"
    else
      student_class_assignment.school_class = school_class
    end
    
    student_class_assignment.save!
  end

  def find_school_class(grade, old_class_identifier)
    grade.school_classes.detect do |school_class|
      school_class.english_name[-1..-1] == old_class_identifier and school_class.active?
    end
  end
end
