class GradesAddJerseyNumberPrefix < ActiveRecord::Migration
  def self.up
    add_column :grades, :jersey_number_prefix, :string

    prefix_array = 'ZABCDEFGHIJKLMNOPQRSTUVWXYZ'.chars.to_a
    grades = Grade.all :order => 'id ASC'
    grades.each do |grade|
      grade.jersey_number_prefix = prefix_array[grade.id]
      grade.save!
    end
  end

  def self.down
    remove_column :grades, :jersey_number_prefix
  end
end
