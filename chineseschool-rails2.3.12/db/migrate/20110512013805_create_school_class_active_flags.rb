class CreateSchoolClassActiveFlags < ActiveRecord::Migration
  def self.up
    create_table :school_class_active_flags do |t|
      t.integer :school_class_id
      t.integer :school_year_id
      t.boolean :active, :null => false, :default => true

      t.timestamps
    end
    
    add_index :school_class_active_flags, :school_class_id
    add_index :school_class_active_flags, :school_year_id

    current_school_year = SchoolYear.current_school_year
    SchoolClass.all.each do |school_class|
      school_class_active_flag = SchoolClassActiveFlag.new
      school_class_active_flag.school_class = school_class
      school_class_active_flag.school_year = current_school_year
      school_class_active_flag.active = school_class.active
      school_class_active_flag.save!
    end

    remove_column :school_classes, :active
  end

  def self.down
    add_column :school_classes, :active, :boolean
    SchoolClassActiveFlag.all.each do |school_class_active_flag|
      school_class_active_flag.school_class.active = school_class_active_flag
      school_class_active_flag.school_class.save!
    end
    
    remove_index :school_class_active_flags, :school_year_id
    remove_index :school_class_active_flags, :school_class_id
    drop_table :school_class_active_flags
  end
end
