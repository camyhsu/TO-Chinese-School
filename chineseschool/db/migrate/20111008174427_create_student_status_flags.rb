class CreateStudentStatusFlags < ActiveRecord::Migration
  def self.up
    create_table :student_status_flags do |t|
      t.integer :student_id
      t.integer :school_year_id
      t.boolean :registered, :null => false, :default => false

      t.timestamps
    end
    
    RegistrationPreference.all.each do |registration_preference|
      student_status_flag = StudentStatusFlag.new
      student_status_flag.student_id = registration_preference.student_id
      student_status_flag.school_year_id = registration_preference.school_year_id
      student_status_flag.registered = registration_preference.registration_completed
      student_status_flag.created_at = registration_preference.updated_at
      student_status_flag.updated_at = registration_preference.updated_at
      student_status_flag.save!
    end
    
    remove_column :registration_preferences, :registration_completed
  end

  def self.down
    add_column :registration_preferences, :registration_completed, :boolean, :null => false, :default => false
    
    StudentStatusFlag.all.each do |student_status_flag|
      registration_preference = RegistrationPreference.first :conditions => ['student_id = ? AND school_year_id = ?', student_status_flag.student_id, student_status_flag.school_year_id]
      unless registration_preference.nil?
        registration_preference.registration_completed = student_status_flag.registered
        unless registration_preference.save
          puts "registration preference id => #{registration_preference.id} errored out on update"
        end
      end
    end
    
    drop_table :student_status_flags
  end
end
