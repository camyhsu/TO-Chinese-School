class SchoolYearAddAutoClassAssignment < ActiveRecord::Migration
  def change
    add_column :school_years, :auto_class_assignment, :boolean, null: false, default: false
  end
end
