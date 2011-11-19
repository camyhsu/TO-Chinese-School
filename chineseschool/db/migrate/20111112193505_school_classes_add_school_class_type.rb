class SchoolClassesAddSchoolClassType < ActiveRecord::Migration
  def self.up
    add_column :school_classes, :school_class_type, :string
    
    SchoolClass.all.each do |school_class|
      if school_class.grade.nil?
        school_class.school_class_type = SchoolClass::SCHOOL_CLASS_TYPE_ELECTIVE
      elsif (('K' == school_class.grade.short_name) or ('1' == school_class.grade.short_name) or ('2' == school_class.grade.short_name)) and school_class.short_name.end_with?('C')
        school_class.school_class_type = SchoolClass::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION
      elsif school_class.short_name.end_with?('A')
        school_class.school_class_type = SchoolClass::SCHOOL_CLASS_TYPE_TRADITIONAL
      else
        school_class.school_class_type = SchoolClass::SCHOOL_CLASS_TYPE_SIMPLIFIED
      end
      school_class.save!
    end
  end

  def self.down
    remove_column :school_classes, :school_class_type
  end
end
