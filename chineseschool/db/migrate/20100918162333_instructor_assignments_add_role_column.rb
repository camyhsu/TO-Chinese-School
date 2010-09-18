class InstructorAssignmentsAddRoleColumn < ActiveRecord::Migration
  def self.up
    add_column :instructor_assignments, :role, :string
    remove_column :instructor_assignments, :primary
    remove_column :instructor_assignments, :assistant
  end

  def self.down
    remove_column :instructor_assignments, :role
    add_column :instructor_assignments, :primary, :boolean, :default => true
    add_column :instructor_assignments, :assistant, :boolean, :default => false
  end
end
