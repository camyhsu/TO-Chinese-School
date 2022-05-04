class AddReRegisterElectiveClassIdToRegistrationPreferences < ActiveRecord::Migration
  def change
    add_column :registration_preferences, :re_register_elective_class_id, :integer, default: 0
  end
end
